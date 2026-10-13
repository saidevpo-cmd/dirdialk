#!/usr/bin/env bash
# =====================================================================
# diali — RLS verification runner
# ---------------------------------------------------------------------
# Spins up a throwaway local PostgreSQL cluster, applies the diali
# migrations plus the Supabase shim, and runs the RLS assertion suite.
# Exits non-zero if any assertion fails.
#
# Requirements: PostgreSQL server binaries (initdb, pg_ctl, psql).
#   - If they are on PATH, nothing else is needed.
#   - Otherwise set PG_BIN=/path/to/postgresql/bin
#
# Usage:  tool/rls_verify/run.sh
# =====================================================================
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../.." && pwd)"
MIG_DIR="$REPO_ROOT/supabase/migrations"
SEED="$REPO_ROOT/supabase/seed.sql"

# ---------- locate PostgreSQL binaries ----------
PGBIN="${PG_BIN:-}"
if [[ -z "$PGBIN" ]] && command -v pg_ctl >/dev/null 2>&1; then
  PGBIN="$(dirname "$(command -v pg_ctl)")"
fi
if [[ -z "$PGBIN" || ! -x "$PGBIN/pg_ctl" || ! -x "$PGBIN/psql" || ! -x "$PGBIN/initdb" ]]; then
  echo "ERROR: PostgreSQL server binaries (initdb/pg_ctl/psql) not found." >&2
  echo "Install postgresql-server, or set PG_BIN=/path/to/postgresql/bin" >&2
  exit 2
fi
PSQL="$PGBIN/psql"

# ---------- throwaway cluster ----------
PORT="${PGPORT:-55433}"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/diali-rls.XXXXXX")"
SOCK="$WORK/sock"
mkdir -p "$SOCK"

cleanup() {
  "$PGBIN/pg_ctl" -D "$WORK/data" stop -m immediate >/dev/null 2>&1 || true
  rm -rf "$WORK"
}
trap cleanup EXIT

echo "==> initdb ($WORK/data)"
"$PGBIN/initdb" -D "$WORK/data" -U postgres --auth=trust -E UTF8 --locale=C >"$WORK/initdb.log" 2>&1

echo "==> starting postgres on port $PORT (socket $SOCK)"
"$PGBIN/pg_ctl" -D "$WORK/data" \
  -o "-p $PORT -k $SOCK -c listen_addresses=''" \
  -l "$WORK/server.log" start >/dev/null

PSQL_BASE=("$PSQL" -h "$SOCK" -p "$PORT" -U postgres -q)

# wait for readiness
for _ in $(seq 1 30); do
  if "$PGBIN/pg_isready" -h "$SOCK" -p "$PORT" >/dev/null 2>&1; then break; fi
  sleep 0.5
done

echo "==> applying Supabase shim"
"${PSQL_BASE[@]}" -v ON_ERROR_STOP=1 -d postgres -f "$HERE/supabase_shim.sql" >/dev/null

echo "==> applying migrations"
for f in "$MIG_DIR"/*.sql; do
  echo "    - $(basename "$f")"
  "${PSQL_BASE[@]}" -v ON_ERROR_STOP=1 -d postgres -f "$f" >/dev/null
done

echo "==> applying seed"
"${PSQL_BASE[@]}" -v ON_ERROR_STOP=1 -d postgres -f "$SEED" >/dev/null

echo "==> running RLS assertions"
echo
"${PSQL_BASE[@]}" -d postgres -f "$HERE/rls_tests.sql"
echo
echo "==> RLS verification PASSED"
