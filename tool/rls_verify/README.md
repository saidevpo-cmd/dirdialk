# RLS verification harness

Runs the diali **RLS / authorization / storage-policy** assertions against a
throwaway local PostgreSQL instance, so security regressions are caught in CI
or on a dev machine without needing a Supabase project.

## What it does

1. Creates a temporary PostgreSQL cluster (`initdb`, unix-socket, ephemeral).
2. Applies [`supabase_shim.sql`](supabase_shim.sql) — the parts of a Supabase
   project the migrations depend on: roles `anon` / `authenticated` /
   `service_role`, `auth.users`, `auth.uid()`/`role()`/`email()`,
   `storage.buckets`, `storage.objects`, `storage.foldername()`, and
   Supabase-style default GRANTs.
3. Applies every migration in `supabase/migrations/` in order, then `seed.sql`.
4. Runs [`rls_tests.sql`](rls_tests.sql), which acts as `anon` / `viewer` /
   `staff` / `admin` / `owner` via `SET ROLE` + JWT claims and asserts the
   expected reads, writes, denials and `place_order` behaviour.

Exits non-zero if any assertion fails.

## Usage

```bash
# PostgreSQL server binaries must be available:
#   - on PATH, or
#   - pointed to via PG_BIN
tool/rls_verify/run.sh

# custom port / binary location
PG_BIN=/usr/lib/postgresql/16/bin PGPORT=55440 tool/rls_verify/run.sh
```

A passing run ends with a summary table and `RLS verification PASSED`.

## What this covers

- `anon` cannot read any private table (`customers`, `orders`, `order_items`,
  `locations`, `stock_movements`, `tracking_events`, `resources`,
  `form_submissions`, `product_images`, `app_settings`, `profiles`) and cannot
  read the private `resources` storage bucket.
- `anon` can read only published/active public content, and can submit to a
  published form only.
- `viewer` is read-only and cannot change roles; `staff` has operational write
  but no config access; `admin`/`owner` manage configuration.
- `profiles.role` changes are owner-only for client roles, while `postgres`
  (SQL editor) and `service_role` can still bootstrap/repair roles.
- `place_order` validates input server-side, keeps stock/ledger consistent, and
  is not executable by `anon`.
- `track_order` lets an anonymous visitor look up an order only with **both** the
  order number and the checkout phone, returns a PII-free projection, returns the
  same `NULL` for a wrong phone and an unknown order (no enumeration oracle),
  rejects malformed input, and throttles repeated anonymous lookups. The
  `order_tracking_attempts` throttle ledger is not readable or writable by
  `anon`/`authenticated` at the privilege level.
- RLS is enabled on every table; the `resources` bucket is private with an
  explicit MIME allow-list; `profiles.role` defaults to `viewer`.

## What this does NOT cover (important)

This validates the **SQL/RLS logic** on real PostgreSQL. It is **not** a real
Supabase project and does **not** exercise:

- GoTrue token issuance or PostgREST's JWT → claims wiring;
- the Storage API, signed URLs, or CORS;
- `service_role` behaviour end-to-end;
- Supabase's exact live default GRANTs / dashboard-managed settings.

Re-run the equivalent checks against a real project (`supabase start` or a cloud
project) before a public launch. See `docs/security-review.md` for the current
status and open follow-ups.
