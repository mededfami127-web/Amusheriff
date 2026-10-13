#!/usr/bin/env bash
#
# Creates the single ASM owner account and flags it as admin.
#
# Public e-mail sign-up is disabled in Supabase Auth (supabase/config.toml), and
# `profiles.is_admin` can only be flipped by SQL run as the project owner —
# never by a client call. This script performs both steps and verifies the
# result.
#
# Usage:
#   ./scripts/create_admin.sh owner@example.com 'A-Very-Strong-Passphrase-1'
#   ./scripts/create_admin.sh --promote-only owner@example.com
#
# Environment:
#   SUPABASE_URL                https://<ref>.supabase.co
#   SUPABASE_SERVICE_ROLE_KEY   Project Settings → API → service_role
#                               (server-side only — never ship this to clients)
#   SUPABASE_DB_URL             Project Settings → Database → Connection string
#   PSQL                        psql binary to use (default: psql)
#   CURL                        curl binary to use (default: curl)
#
# Why account creation goes through the Admin API rather than SQL: GoTrue needs
# rows in both `auth.users` *and* `auth.identities` (and a bcrypt password hash)
# for password sign-in to work. Hand-rolling that insert is fragile and breaks
# between GoTrue versions, so we let Supabase create the account and only do the
# promotion ourselves in SQL.
#
set -euo pipefail

SUPABASE_URL="${SUPABASE_URL:-}"
SERVICE_ROLE_KEY="${SUPABASE_SERVICE_ROLE_KEY:-}"
DB_URL="${SUPABASE_DB_URL:-}"
PSQL=${PSQL:-psql}
CURL=${CURL:-curl}

usage() {
  cat <<'USAGE'
Create (or promote) the ASM owner account.

  ./scripts/create_admin.sh <email> <password>      create + promote
  ./scripts/create_admin.sh --promote-only <email>  promote an existing user

Environment:
  SUPABASE_URL               https://<ref>.supabase.co
  SUPABASE_SERVICE_ROLE_KEY  Project Settings → API → service_role
  SUPABASE_DB_URL            Project Settings → Database → Connection string
  PSQL, CURL                 binary overrides (default: psql, curl)

The service-role key is only used to talk to the Auth Admin API on your machine.
It must never be embedded in the Flutter app — the app ships the anon key only.
USAGE
}

die() { echo "error: $*" >&2; exit 64; }

if [[ $# -lt 1 ]]; then
  usage
  exit 64
fi

PROMOTE_ONLY=0
if [[ "$1" == "--promote-only" ]]; then
  PROMOTE_ONLY=1
  shift
fi

EMAIL="${1:-}"
PASSWORD="${2:-}"

[[ -n "$EMAIL" ]] || { usage; exit 64; }
[[ -n "$DB_URL" ]] || die "SUPABASE_DB_URL is not set (Project Settings → Database → Connection string)."

if [[ "$PROMOTE_ONLY" -eq 0 ]]; then
  [[ -n "$PASSWORD" ]] || die "a password is required when creating the account."
  [[ -n "$SUPABASE_URL" ]] || die "SUPABASE_URL is not set (needed to create the Auth user)."
  [[ -n "$SERVICE_ROLE_KEY" ]] || die "SUPABASE_SERVICE_ROLE_KEY is not set (needed to create the Auth user)."
fi

# Single-quote escaping for SQL, backslash/quote escaping for JSON.
sql_escape() { printf '%s' "${1//\'/\'\'}"; }
json_escape() { local s=${1//\\/\\\\}; printf '%s' "${s//\"/\\\"}"; }

psql_run() { "$PSQL" "$DB_URL" -v ON_ERROR_STOP=1 -qtAX -c "$1"; }

if [[ "$PROMOTE_ONLY" -eq 0 ]]; then
  echo "── creating Auth user $EMAIL via the Admin API"
  payload="{\"email\":\"$(json_escape "$EMAIL")\",\"password\":\"$(json_escape "$PASSWORD")\",\"email_confirm\":true}"

  response=$("$CURL" -sS -X POST "${SUPABASE_URL%/}/auth/v1/admin/users" \
    -H "apikey: $SERVICE_ROLE_KEY" \
    -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
    -H 'Content-Type: application/json' \
    -d "$payload" \
    -w $'\n%{http_code}') || die "could not reach ${SUPABASE_URL}/auth/v1/admin/users"

  status="${response##*$'\n'}"
  body="${response%$'\n'*}"

  case "$status" in
    200|201)
      echo "   created."
      ;;
    409|422)
      # Already registered — fall through and just promote it.
      echo "   user already exists; continuing to promote."
      ;;
    401|403)
      echo "$body" >&2
      die "the service-role key was rejected. Double-check SUPABASE_SERVICE_ROLE_KEY."
      ;;
    *)
      echo "$body" >&2
      die "Auth Admin API returned HTTP $status."
      ;;
  esac
fi

echo "── promoting $EMAIL to admin (direct SQL, as the project owner)"
PROMOTED=$(psql_run "$(cat <<SQL
update public.profiles p
   set is_admin = true
  from (select id from auth.users where email = '$(sql_escape "$EMAIL")') t
 where p.id = t.id
returning p.id;
SQL
)")

if [[ -z "$PROMOTED" ]]; then
  echo "error: no account found for $EMAIL, or its profile row is missing." >&2
  echo "       Confirm the user exists, then re-run with --promote-only." >&2
  exit 1
fi

UID_VALUE="$PROMOTED"

echo "── verifying"
psql_run "$(cat <<SQL
select 'uid=' || u.id || ' is_admin=' || p.is_admin
  from auth.users u
  join public.profiles p on p.id = u.id
 where u.email = '$(sql_escape "$EMAIL")';
SQL
)"

cat <<NEXT

Done. Sign in from Settings → Admin in the app, then change the password.

The equivalent manual one-liner, should you ever need it:
  update public.profiles set is_admin = true where id = '$UID_VALUE';

To revoke admin access later:
  update public.profiles set is_admin = false where id = '$UID_VALUE';
NEXT
