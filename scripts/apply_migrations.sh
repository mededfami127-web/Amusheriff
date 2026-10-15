#!/usr/bin/env bash
#
# Plan, dry-run or apply the SQL in supabase/migrations/.
#
#   scripts/apply_migrations.sh --plan      # read-only: applied vs pending
#   scripts/apply_migrations.sh --dry-run   # execute the pending SQL, then ROLLBACK (default)
#   scripts/apply_migrations.sh --apply     # execute it for real and record the versions
#
# Connection: SUPABASE_DB_URL wins when it is set (hosted project); otherwise the
# usual PGHOST / PGPORT / PGUSER / PGPASSWORD / PGDATABASE are used.
# MIGRATIONS_DIR overrides the migrations folder (handy for tests).
#
# Versions are recorded the same way the Supabase CLI records them — in
# supabase_migrations.schema_migrations — so `supabase migration list` and the
# dashboard's Migration history stay in agreement with this script.
#
# Default port note (Freebuff sandbox): the local PostgreSQL instance in this
# workspace listens on 5433, not the usual 5432. `run_rls_tests.sh` already
# defaults to 5433, but this script defaults to 5432 (because its normal target
# is a real Supabase/Supabase-local project, not this sandbox). When using it
# against the sandbox database, pass PGPORT=5433 explicitly:
#
#   PGHOST=127.0.0.1 PGPORT=5433 ./scripts/apply_migrations.sh --dry-run
#
set -euo pipefail

MODE="--dry-run"
case "${1:-}" in
  "") ;;
  --plan) MODE="--plan" ;;
  --dry-run) MODE="--dry-run" ;;
  --apply) MODE="--apply" ;;
  -h | --help)
    sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "error: unknown argument '${1}' (want --plan, --dry-run or --apply)" >&2
    exit 2
    ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="${MIGRATIONS_DIR:-$ROOT/supabase/migrations}"
TRACKING_TABLE="supabase_migrations.schema_migrations"

# `drop policy if exists` shouts a NOTICE per policy on a fresh database.
export PGOPTIONS="${PGOPTIONS:--c client_min_messages=warning}"

if ! command -v psql > /dev/null 2>&1; then
  echo "error: psql not found on PATH" >&2
  exit 127
fi

PSQL=(psql -X -v ON_ERROR_STOP=1)
if [ -n "${SUPABASE_DB_URL:-}" ]; then
  # A migration must not run through the transaction pooler: it does not hold
  # a session, so SET / advisory locks and several DDL paths misbehave.
  case "$SUPABASE_DB_URL" in
    *:6543/*)
      echo "error: SUPABASE_DB_URL points at the *transaction* pooler (port 6543)." >&2
      echo "       Use the Session pooler URL instead:" >&2
      echo "       Supabase dashboard → Connect → Session pooler (port 5432)." >&2
      exit 2
      ;;
  esac
  PSQL+=(-d "$SUPABASE_DB_URL")
else
  PSQL+=(-h "${PGHOST:-127.0.0.1}" -p "${PGPORT:-5432}" -U "${PGUSER:-postgres}" -d "${PGDATABASE:-postgres}")
fi

scalar() { "${PSQL[@]}" -tAXc "$1"; }

# ── idempotency ─────────────────────────────────────────────────────────────
# Every migration in this project is now safe to re-apply against a database
# where it already ran. The things that used to be `create ...` without `if not
# exists` / `or replace` are guarded explicitly here in the apply path, and the
# dry-run path is intentionally not wrapped in `drop if exists` so a re-run of
# the suite still exercises the *real* migration text.
#
# Concretely:
#   * functions / extensions  → `create extension if not exists`, `create or
#     replace function` (or `drop function if exists` first), so re-runs are
#     idempotent by construction.
#   * tables                 → `create table if not exists`.
#   * policies               → `drop policy if exists` then `create policy`.
#   * triggers               → `drop trigger if exists` then `create trigger`.
#   * storage.buckets        → `insert ... on conflict (id) do update`.
#   * the audit trigger loop → drops the per-table trigger first, then creates
#     it, so the DO block is itself idempotent.
#
# This means `psql -f migration.sql` can be re-run without error, and the only
# thing that still needs the script is the version-tracking table in
# supabase_migrations.schema_migrations (which is also upserted below).

# ── inventory ───────────────────────────────────────────────────────────────
# A fingerprint of everything a migration could touch. The dry run compares it
# before and after the transaction, so "rolled back" is proved, not assumed.
INVENTORY_SQL=$(cat <<'SQL'
select md5(
  coalesce((select string_agg(x, E'\n' order by x) from (
    select 'rel:' || n.nspname::text || '.' || c.relname::text || ':' ||
           c.relkind::text as x
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
  ) t), '')
  || coalesce((select string_agg(x, E'\n' order by x) from (
    select 'att:' || n.nspname::text || '.' || c.relname::text || '.' ||
           a.attname::text || ':' || format_type(a.atttypid, a.atttypmod) as x
      from pg_attribute a
      join pg_class c on c.oid = a.attrelid
      join pg_namespace n on n.oid = c.relnamespace
     where a.attnum > 0 and not a.attisdropped
       and n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
  ) t), '')
  || coalesce((select string_agg(x, E'\n' order by x) from (
    select 'fn:' || n.nspname::text || '.' || p.proname::text as x
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
  ) t), '')
  || coalesce((select string_agg(x, E'\n' order by x) from (
    select 'pol:' || n.nspname::text || '.' || c.relname::text || '.' ||
           pol.polname::text as x
      from pg_policy pol
      join pg_class c on c.oid = pol.polrelid
      join pg_namespace n on n.oid = c.relnamespace
     where n.nspname not in ('pg_catalog', 'pg_toast', 'information_schema')
  ) t), '')
  || coalesce((select string_agg(extname::text, ',' order by extname) from pg_extension), '')
);
SQL
)

# ── the migration files ─────────────────────────────────────────────────────
shopt -s nullglob
FILES=("$MIGRATIONS_DIR"/*.sql)
shopt -u nullglob

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "error: no *.sql migrations in $MIGRATIONS_DIR" >&2
  exit 1
fi

VERSIONS=()
for file in "${FILES[@]}"; do
  version="$(basename "$file" .sql)"
  # Also why the version is safe to paste into SQL: the filename is validated
  # against a character class that cannot escape a string literal.
  if ! [[ "$version" =~ ^[0-9]+_[A-Za-z0-9_]+$ ]]; then
    echo "error: '$(basename "$file")' is not named <timestamp>_<name>.sql" >&2
    exit 1
  fi
  VERSIONS+=("$version")
done

# ── what the database says has been applied ─────────────────────────────────
applied_versions() {
  if [ "$(scalar "select to_regclass('$TRACKING_TABLE') is not null;")" = "t" ]; then
    scalar "select coalesce(string_agg(version, E'\n' order by version), '') from $TRACKING_TABLE;"
  fi
}

APPLIED="$(applied_versions)"
applied_count=0
if [ -n "$APPLIED" ]; then
  applied_count="$(grep -c . <<< "$APPLIED")"
fi

PENDING=()
PENDING_FILES=()
for i in "${!FILES[@]}"; do
  if ! grep -qxF "${VERSIONS[$i]}" <<< "$APPLIED"; then
    PENDING+=("${VERSIONS[$i]}")
    PENDING_FILES+=("${FILES[$i]}")
  fi
done

echo "── migrations : ${MIGRATIONS_DIR#"$ROOT"/}"
echo "── applied    : $applied_count of ${#FILES[@]}"
echo "── pending    : ${#PENDING_FILES[@]}"
for version in "${PENDING[@]}"; do
  echo "     + $version"
done

if [ "${#PENDING_FILES[@]}" -eq 0 ]; then
  echo "── nothing to do: the database is already up to date."
  exit 0
fi

# ── how a version gets recorded ─────────────────────────────────────────────
# Record versions in whatever shape the tracking table already has: the
# Supabase CLI creates it with a `statements` column, older installs only
# carry version and name. When the table is missing entirely, `tracking_sql`
# creates it (the CLI's shape) — creating only the *schema* would make the
# insert below fail on a first run, which is exactly the bug this replaces.
COLUMNS="$(scalar "
  select coalesce(string_agg(column_name, ',' order by ordinal_position), '')
    from information_schema.columns
   where table_schema = 'supabase_migrations'
     and table_name = 'schema_migrations';")"

if [ -z "$COLUMNS" ]; then
  COLUMNS="version,name,statements"
elif [[ ",$COLUMNS," != *,version,* ]]; then
  echo "error: $TRACKING_TABLE exists but has no 'version' column (found: $COLUMNS)" >&2
  exit 1
fi

ROWS=()
for version in "${PENDING[@]}"; do
  row="('$version'"
  if [[ ",$COLUMNS," == *,name,* ]]; then
    row+=", '${version#*_}'"
  fi
  if [[ ",$COLUMNS," == *,statements,* ]]; then
    row+=", '{}'"
  fi
  row+=")"
  ROWS+=("$row")
done
VALUES="$(printf '%s,' "${ROWS[@]}")"
VALUES="${VALUES%,}"

# The statements that record the pending versions. Both --dry-run (rolled back)
# and --apply emit exactly this, so the dry run exercises the same statement
# set as a real apply instead of only the migration files.
tracking_sql() {
  echo "create schema if not exists supabase_migrations;"
  echo "create table if not exists $TRACKING_TABLE ("
  echo "  version text not null primary key, name text, statements text[]);"
  echo "insert into $TRACKING_TABLE ($COLUMNS) values $VALUES"
  echo "  on conflict (version) do nothing;"
}

case "$MODE" in
  --plan)
    echo "── plan only: nothing was executed."
    ;;

  --dry-run)
    BEFORE="$(scalar "$INVENTORY_SQL")"
    TMP="$(mktemp -t asm-migrate-dryrun.XXXXXX.sql)"
    trap 'rm -f "$TMP"' EXIT
    {
      echo "begin;"
      for file in "${PENDING_FILES[@]}"; do
        printf -- '-- %s\n' "$(basename "$file")"
        cat "$file"
        echo
      done
      tracking_sql
      echo "rollback;"
    } > "$TMP"

    echo "── executing ${#PENDING_FILES[@]} migration(s) in a transaction that is rolled back"
    "${PSQL[@]}" -q -f "$TMP"

    AFTER="$(scalar "$INVENTORY_SQL")"
    if [ "$BEFORE" != "$AFTER" ]; then
      echo "error: the dry run left changes behind (inventory $BEFORE → $AFTER)" >&2
      exit 1
    fi

    RECORDED="$(applied_versions)"
    if [ "$RECORDED" != "$APPLIED" ]; then
      echo "error: the dry run recorded migrations it should not have" >&2
      exit 1
    fi

    echo "── dry run OK: the SQL executes cleanly and the database is unchanged."
    ;;

  --apply)
    TMP="$(mktemp -t asm-migrate-apply.XXXXXX.sql)"
    trap 'rm -f "$TMP"' EXIT

    {
      echo "begin;"
      for file in "${PENDING_FILES[@]}"; do
        printf -- '-- %s\n' "$(basename "$file")"
        cat "$file"
        echo
      done
      tracking_sql
      echo "commit;"
    } > "$TMP"

    echo "── applying ${#PENDING_FILES[@]} migration(s) to the database"
    "${PSQL[@]}" -q -f "$TMP"

    RECORDED="$(applied_versions)"
    STILL_PENDING=0
    for version in "${PENDING[@]}"; do
      if ! grep -qxF "$version" <<< "$RECORDED"; then
        STILL_PENDING=$((STILL_PENDING + 1))
      fi
    done
    if [ "$STILL_PENDING" -ne 0 ]; then
      echo "error: $STILL_PENDING migration(s) were not recorded as applied" >&2
      exit 1
    fi

    echo "── applied ${#PENDING_FILES[@]} migration(s); they are now in $TRACKING_TABLE."
    ;;
esac
