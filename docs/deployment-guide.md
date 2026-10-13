# diali — Deployment Guide

> Goal: a live HTTPS public website with the admin dashboard, backed by Supabase.
> Nothing here is reported as "done" until it is actually executed and verified.

## 0. Prerequisites

- Flutter SDK 3.47.x (Dart 3.13.x) — required for `flutter build web --release`.
- A Supabase project (free tier is enough) → https://supabase.com/dashboard
- A static host with SPA rewrites (Netlify / Vercel / Cloudflare Pages / Firebase Hosting).

## 1. Create and configure Supabase

1. Create a project; note **Project URL** and **anon (publishable) key** (Settings → API).
2. Apply the schema. Either link the CLI:

   ```bash
   supabase link --project-ref <ref>
   supabase db push          # applies supabase/migrations/*.sql in order
   # then run supabase/seed.sql in the SQL editor (or `supabase db reset` locally)
   ```

   or paste each `supabase/migrations/*.sql` into the SQL editor in filename order, then `seed.sql`.

3. Create the first **owner** account (Authentication → Users → Add user, email+password).
4. Insert the matching profile row (SQL editor):

   ```sql
   insert into public.profiles (id, full_name, role)
   select id, email, 'owner' from auth.users where email = 'you@example.com'
   on conflict (id) do update set role = 'owner';
   ```

5. (Recommended) Disable public sign-ups: Authentication → Providers → Email → *Disable sign ups*,
   since this is a private business app.

## 2. Local run

```bash
cd diali
flutter pub get

# Local/offline mode (mock repositories, no backend)
flutter run -d chrome

# Connected to Supabase (admin requires sign-in)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Never pass the `service_role` key. It is not needed and must never reach the browser.

## 3. Production web build

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key> \
  --dart-define=APP_ENV=production
```

Output: `build/web/`. Add a SPA fallback so deep links (`/products/123`, `/articles/x`) work:

- **Netlify** `netlify.toml`:
  ```toml
  [build]
    command = "flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=..."
    publish = "build/web"
  [[redirects]]
    from = "/*"
    to = "/index.html"
    status = 200
  ```
- **Vercel** `vercel.json`:
  ```json
  { "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }] }
  ```
- **Cloudflare Pages**: build `build/web`, add a `_redirects` file with `/* /index.html 200`.

Deploy `build/web` to any of these. The host provides HTTPS automatically.

## 4. Supabase auth redirect URLs

After you know the production origin, add it in Supabase → Authentication → URL Configuration:
`Site URL` = `https://your-domain`, and add `https://your-domain/**` to redirect URLs.
No third-party OAuth is configured, so no provider setup is required by default.

## 5. Post-deploy smoke tests

1. Public home loads over HTTPS; refresh on `/products` returns the same page (SPA fallback).
2. Open `/admin` while signed out → redirected to `/login`; wrong password is rejected; correct
   credentials reach the dashboard.
3. As `viewer`: product create/save returns a permission error from the server (not just hidden UI).
4. As `staff`: create/edit a product and a stock movement; verify `stock_qty` updates and cannot go
   negative.
5. Anonymous REST check:
   ```bash
   curl "https://<ref>.supabase.co/rest/v1/customers?select=*" \
     -H "apikey: <anon-key>" -H "Authorization: Bearer <anon-key>"
   # expected: [] or 401/403 — never customer rows
   ```
6. Upload a product image; verify it is public in the `products` bucket and that
   `resources` objects are not publicly listable.

## 6. Rollback

- Hosting: redeploy the previous `build/web` artifact (Netlify/Vercel keep deploy history).
- Database: migrations are additive. To roll back a migration, write a compensating migration
  rather than editing history; restore from a Supabase backup (Database → Backups) for data loss.
- Never run destructive git commands; `build/web` is reproducible from source + the two defines.

## 7. Environment separation

| Env | Supabase | Notes |
|---|---|---|
| Local offline | none | mock repositories, no auth gate |
| Local connected | local/cloud project | `--dart-define` |
| Production | production project | CI injects the two defines; anon key only |

## 8. What still requires the user

- Create the Supabase project and supply `SUPABASE_URL` + `SUPABASE_ANON_KEY`.
- Choose a host and connect the repository (or upload `build/web`).
- Add the production URL to Supabase auth settings.
- Insert the first owner profile (step 1.4).

Until these are done, the backend is **implemented and locally verified, but not deployed**.
