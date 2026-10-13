# diali — Security Review

> Reflects the state of the repository. Distinguishes what is **implemented**,
> what is **tested locally**, and what **requires the live Supabase project**.

## 1. Authentication

- **Implemented**: Supabase Auth integration in `lib/core/supabase/` and an admin sign-in gate
  (`/login`). When Supabase is configured, `/admin` requires a session; when it is not configured,
  the app runs in local/offline mode and opens the admin directly (development only).
- **Session handling**: delegated to `supabase_flutter` (secure storage per platform, automatic JWT
  refresh). No tokens are written to Hive or to ordinary storage.
- **Credentials**: `SUPABASE_URL` and `SUPABASE_ANON_KEY` are injected via `--dart-define`.
  The **anon/publishable key is safe for the client**; the **service-role key is never shipped**.

## 2. Authorization

- Role lives in `profiles.role` (`owner | admin | staff | viewer`), never in the UI.
- `owner`/`admin` can manage configuration, templates, users; `staff` can manage operational data;
  `viewer` is read-only.
- Enforcement is **server-side** through RLS helper functions (`is_admin()`, `is_staff()`,
  `has_profile()`), not by hiding buttons.

## 3. Row Level Security

RLS is **enabled on every table**. Default is deny. Policies:

| Actor | Can read | Can write |
|---|---|---|
| `anon` (public visitor) | active products, published pages/articles, categories, page categories, published templates, site settings, published forms | insert `form_submissions` for a **published** form only |
| `viewer` (signed-in) | all business data | nothing |
| `staff` | all business data | operational tables (products, orders, customers, resources, tracking, stock) |
| `admin`/`owner` | all business data | everything incl. templates, site settings, app settings, profiles |

Changing `profiles.role` is **owner-only**. A `BEFORE UPDATE` trigger
(`enforce_profile_role_change`) rejects role changes from the client roles
(`anon`/`authenticated`) unless the actor's role is `owner`; privileged contexts
(the SQL editor / migrations as `postgres`, and `service_role`) remain able to
bootstrap the first owner and repair roles.

Tables with **no** public read policy: `customers`, `orders`, `order_items`, `locations`,
`stock_movements`, `tracking_events`, `resources`, `app_settings`, `profiles`.

> **Status**: policies are written and reviewed in the migration, and were exercised against a real
> PostgreSQL 14 instance using a Supabase-compatible shim (`auth.uid()`, `storage.buckets`,
> `storage.objects`, `anon`/`authenticated`/`service_role` roles) — 75 assertions across
> `anon`/`viewer`/`staff`/`admin`/`owner`, all security-relevant expectations held. This run also
> caught a real bug: an initial owner-only role trigger would have blocked role changes from the
> SQL editor/`service_role` too, making the first owner impossible to bootstrap; it was corrected by
> scoping the guard to the client roles. This verifies the
> **SQL/RLS logic**; it does **not** replace testing against a real Supabase project. Still unverified
> against the live stack: GoTrue/PostgREST JWT-to-claim wiring, the Storage API and signed URLs,
> `service_role` behaviour, and Supabase's exact default GRANTs (see `deployment-guide.md`).
> Re-run the checks on a cloud project before public launch.

## 4. Storage security

| Bucket | Visibility | Read | Write |
|---|---|---|---|
| `products` | public | anyone | staff |
| `site` | public | anyone | admin |
| `avatars` | public | anyone | owner of `uid/` prefix |
| `resources` | private | staff only | staff only |

File size and MIME types are constrained at the bucket level (`file_size_limit`,
`allowed_mime_types`). Uploaded names are sanitized client-side (see `StorageService`).

## 5. Data integrity

- Money uses `numeric(12,2)`; non-negative check constraints.
- `order_items.qty > 0`.
- Inventory changes flow only through `stock_movements`; the trigger prevents negative stock.
- `place_order` is a single transaction so orders, items and stock stay consistent.
- Unique constraints on `sku`, `slug`, `order_number`, `email` prevent duplicates.

## 6. Client-side hardening

- No secrets in source (verified by search). `.env`/keys are git-ignored.
- Image uploads validated by size/type before upload; local `ImageService` enforces a 12 MB cap.
- `AppImage` supports safe fallbacks and does not execute content.
- Article/page content renders as **plain text** (no HTML/markdown injection path currently enabled).

## 7. Known limitations / follow-ups

1. **RLS not live-tested** here — run `supabase test`/manual anon-key checks after project setup.
2. Public form submission is anonymous; consider rate limiting / CAPTCHA for spam.
3. `app_settings` tax/currency are client-consumed; re-validate on the server if financial accuracy is
   critical.
4. Android release manifest must include `INTERNET` (added) and a real signing key before store release.
5. Admin sign-in currently supports email/password; add password reset and MFA as needed.
6. Content is plain text; if rich text is enabled later, sanitize server-side.
7. ~~`anon` may still hold EXECUTE on `place_order` via default grants.~~ **Resolved** in
   `20261013140000_owner_only_roles_and_execute_hardening.sql`: `REVOKE EXECUTE ... FROM anon`
   (verified: `anon` no longer has EXECUTE; `authenticated` still does, guarded by `is_staff()`).
8. ~~An `admin` can promote their own profile to `owner`.~~ **Resolved** in
   `20261013140000_owner_only_roles_and_execute_hardening.sql`: role changes now require `owner`
   (verified: `admin` self-promotion and promoting others both rejected; `owner` succeeds).
9. `app_settings` is readable by any signed-in profile (`has_profile()`), including `viewer`. This is
   consistent with "viewer = read-only business data" but the wording "private to signed-in staff"
   above is loose.

## 8. Secret scanning result

```
search lib/ web/ for: service_role, secret, password=, apiKey  → none found
.env / *.key / key.properties are git-ignored and absent from VCS
```
