#!/usr/bin/env bash
#
# Runs the ASM RLS acceptance suite against a throwaway PostgreSQL database.
#
# It provisions a local stand-in for the Supabase platform (roles, auth schema,
# storage schema), applies the real migrations and seed, then executes the
# assertions in tests/rls/rls_tests.sql. Any failed assertion aborts with a
# non-zero exit code, so this doubles as a CI gate.
#
# Requires: PostgreSQL 15+ (the migrations use `security_invoker` views and
# `gen_random_uuid()`), and a superuser connection.
#
#   PGHOST=127.0.0.1 PGPORT=5433 PGUSER=postgres ./scripts/run_rls_tests.sh
#
set -euo pipefail

PGHOST="${PGHOST:-127.0.0.1}"
PGPORT="${PGPORT:-5433}"
PGUSER="${PGUSER:-postgres}"
DB="${DB:-asm_rls_test}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v psql >/dev/null 2>&1; then
  echo "error: psql not found on PATH" >&2
  exit 127
fi

# `drop policy if exists` emits a NOTICE per policy on a fresh database;
# suppress notices so the assertion report stays readable.
export PGOPTIONS="${PGOPTIONS:-} -c client_min_messages=warning"

psql_admin() {
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -v ON_ERROR_STOP=1 "$@"
}

psql_db() {
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB" -v ON_ERROR_STOP=1 "$@"
}

echo "── rebuilding database '$DB' on $PGHOST:$PGPORT"
psql_admin -q -c "drop database if exists $DB with (force);"
psql_admin -q -c "create database $DB;"

apply() {
  local file="$1"
  echo "── applying $(realpath --relative-to="$ROOT" "$file")"
  psql_db -q -f "$file"
}

apply "$ROOT/tests/rls/00_supabase_shim.sql"

# Migrations run in lexicographic order, which is why they are timestamped.
for migration in "$ROOT"/supabase/migrations/*.sql; do
  apply "$migration"
done

apply "$ROOT/supabase/seed.sql"

echo "── running RLS assertions"
psql_db -f "$ROOT/tests/rls/rls_tests.sql"

echo "── cleaning up"
psql_admin -q -c "drop database if exists $DB with (force);"
