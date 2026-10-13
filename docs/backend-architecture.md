# BACKEND ARCHITECTURE
## diali — Business Platform

> **Update (productionization pass).** This document was originally a Phase-1 gate. It is now
> **implemented**:
> * State management is the **existing `ChangeNotifier` + `AppRepositories`**, not Riverpod
>   (Riverpod was only planned; introducing it would add a second system — avoided).
> * The schema is **single-business** (multi-tenancy removed; `organizations` dropped) per the
>   final requirements. See `docs/database-schema.md`.
> * `go_router` is added **only at the top level** to give the public site real URL routing;
>   the admin keeps its `IndexedStack`.
> * Supabase repositories live in `lib/data/supabase/` and implement the same interfaces as the
>   mocks; the composition root selects them when `SUPABASE_URL`/`SUPABASE_ANON_KEY` are provided.
> * Sections below that mention organizations/Riverpod are superseded by the two docs above.

---

## 1. TECHNOLOGY CHOICE

### Comparison Matrix

| Criterion | Supabase | Firebase | NestJS + PostgreSQL |
|---|---|---|---|
| Flutter SDK quality | ✅ Excellent | ✅ Good | ⚠️ Manual HTTP |
| PostgreSQL (relational) | ✅ Native | ❌ NoSQL | ✅ Native |
| Auth (built-in) | ✅ Yes | ✅ Yes | ❌ Manual |
| Row-level security | ✅ Built-in | ❌ Rules only | ⚠️ Manual |
| File storage | ✅ Built-in | ✅ Built-in | ❌ External |
| Realtime | ✅ Built-in | ✅ Built-in | ❌ Manual |
| REST API | ✅ Auto-generated | ❌ SDK only | ✅ Full control |
| Dashboard / Admin UI | ✅ Excellent | ⚠️ Limited | ❌ Build yourself |
| Local dev | ✅ Supabase CLI | ⚠️ Emulators | ✅ Docker |
| Cost | ✅ Free tier generous | ⚠️ Billing by read/write | 💰 Infrastructure cost |
| Migration system | ✅ SQL migrations | ❌ None | ✅ Full |
| Open source / self-host | ✅ Yes | ❌ No | ✅ Yes |

### ✅ CHOSEN: **Supabase**

**Reasons:**
- Relational database (PostgreSQL) — correct for Products/Orders/Customers with joins
- Row Level Security (RLS) — authorization logic lives in the database, not just the app
- Auto-generated REST API — no need to write CRUD endpoints manually
- Built-in auth (email, magic link, OAuth ready)
- Built-in file storage — for product images, documents, resources
- Excellent Flutter SDK (`supabase_flutter`)
- Realtime subscriptions — dashboard can update live
- Local development via Supabase CLI (`supabase start`)
- Free tier sufficient for early phases; self-hostable

---

## 2. ARCHITECTURE LAYERS

```
Flutter UI (Widgets)
        ↓
Feature ViewModels / State (Riverpod)
        ↓
Repository Interfaces  ← Flutter knows only these
        ↓
Mock Repositories │ Real Repositories  ← swappable
        ↓
Supabase Flutter SDK
        ↓
Supabase (PostgreSQL + Auth + Storage + Realtime + RLS)
```

### Flutter Folder Structure (data layer to add)

```
lib/
├── core/
│   ├── design_system/           (existing — preserve)
│   ├── navigation/              (existing — preserve)
│   ├── settings/                (existing — preserve)
│   ├── storage/                 (existing — preserve)
│   └── supabase/                ← NEW
│       └── supabase_client.dart
├── domain/                      ← NEW
│   ├── models/
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── order.dart
│   │   ├── order_item.dart
│   │   ├── customer.dart
│   │   ├── resource.dart
│   │   ├── form_definition.dart
│   │   ├── form_submission.dart
│   │   └── page_content.dart
│   └── repositories/            ← interfaces only
│       ├── product_repository.dart
│       ├── order_repository.dart
│       ├── customer_repository.dart
│       ├── resource_repository.dart
│       ├── form_repository.dart
│       └── page_repository.dart
├── data/                        ← NEW
│   ├── mock/                    ← used in Phase 2 (Frontend)
│   │   ├── mock_product_repository.dart
│   │   ├── mock_order_repository.dart
│   │   └── ...
│   └── supabase/                ← used in Phase 3 (Backend integration)
│       ├── supabase_product_repository.dart
│       ├── supabase_order_repository.dart
│       └── ...
└── features/                    (existing — extend with real widgets)
```

---

## 3. DATABASE SCHEMA

### Conventions
- All primary keys: `uuid` (gen_random_uuid())
- All timestamps: `timestamptz` with default `now()`
- All money: `numeric(12,2)` (not float)
- Soft deletes via `deleted_at timestamptz` where needed
- RLS enabled on all tables

---

### 3.1 `profiles` — Extended user info
```sql
CREATE TYPE user_role AS ENUM ('owner', 'admin', 'staff', 'viewer');

CREATE TABLE profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   text NOT NULL DEFAULT '',
  avatar_url  text,
  -- Least privilege: defaults to 'viewer'. Roles are promoted by an owner.
  role        user_role NOT NULL DEFAULT 'viewer',
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
```

> Changing `profiles.role` is **owner-only** (enforced by the
> `enforce_profile_role_change` trigger added in
> `20261013140000_owner_only_roles_and_execute_hardening.sql`). New auth users are
> auto-provisioned with a `viewer` profile by the `handle_new_user` trigger.

---

### 3.2 `categories` — Product categories
```sql
CREATE TABLE categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  description text,
  parent_id   uuid REFERENCES categories(id),
  position    int  NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.3 `products` — Product catalogue
```sql
CREATE TABLE products (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  description   text,
  sku           text UNIQUE,
  category_id   uuid REFERENCES categories(id),
  price         numeric(12,2) NOT NULL DEFAULT 0,
  cost_price    numeric(12,2),
  stock_qty     int  NOT NULL DEFAULT 0,
  low_stock_threshold int NOT NULL DEFAULT 5,
  unit          text NOT NULL DEFAULT 'unit',
  image_url     text,
  status        text NOT NULL DEFAULT 'active'
                CHECK (status IN ('active', 'draft', 'archived')),
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.4 `customers` — Customer base
```sql
CREATE TABLE customers (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  email       text UNIQUE,
  phone       text,
  address     text,
  city        text,
  country     text,
  tier        text NOT NULL DEFAULT 'regular'
              CHECK (tier IN ('regular', 'vip')),
  notes       text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.5 `orders` — Customer orders
```sql
CREATE TABLE orders (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number  text NOT NULL UNIQUE,
  customer_id   uuid REFERENCES customers(id),
  status        text NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
  subtotal      numeric(12,2) NOT NULL DEFAULT 0,
  discount      numeric(12,2) NOT NULL DEFAULT 0,
  tax           numeric(12,2) NOT NULL DEFAULT 0,
  total         numeric(12,2) NOT NULL DEFAULT 0,
  notes         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.6 `order_items` — Line items per order
```sql
CREATE TABLE order_items (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id   uuid REFERENCES products(id),
  product_name text NOT NULL,  -- snapshot at order time
  product_sku  text,           -- snapshot
  unit_price   numeric(12,2) NOT NULL,
  qty          int NOT NULL CHECK (qty > 0),
  subtotal     numeric(12,2) NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.7 `resources` — Files and documents
```sql
CREATE TABLE resources (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name         text NOT NULL,
  description  text,
  type         text NOT NULL DEFAULT 'document'
               CHECK (type IN ('document', 'spreadsheet', 'image', 'folder', 'other')),
  storage_path text,
  storage_size bigint,
  mime_type    text,
  folder_id    uuid REFERENCES resources(id),
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.8 `form_definitions` — Form builder
```sql
CREATE TABLE form_definitions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL,
  description text,
  slug        text NOT NULL UNIQUE,
  status      text NOT NULL DEFAULT 'draft'
              CHECK (status IN ('draft', 'published', 'archived')),
  schema      jsonb NOT NULL DEFAULT '[]',
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.9 `form_submissions`
```sql
CREATE TABLE form_submissions (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id  uuid NOT NULL REFERENCES form_definitions(id) ON DELETE CASCADE,
  data     jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);
```

---

### 3.10 `page_contents`
```sql
CREATE TABLE page_contents (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title      text NOT NULL,
  slug       text NOT NULL UNIQUE,
  content    text,
  status     text NOT NULL DEFAULT 'draft'
             CHECK (status IN ('draft', 'published')),
  meta_title text,
  meta_desc  text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

---

## 4. RELATIONSHIPS

```
categories (self-referential tree via parent_id)
    ↓ 1:N
products
    ↓ 1:N (via order_items)
order_items ←→ orders
    ↑ N:1
customers → orders (1:N)

resources (self-referential: folder_id)

form_definitions → form_submissions (1:N)
```

---

## 5. AUTHENTICATION

| Flow | Supabase SDK call |
|---|---|
| Login | `signInWithPassword(email, password)` |
| Logout | `signOut()` |
| Session | JWT — auto-managed by SDK |
| Token refresh | Automatic |
| Password reset | `resetPasswordForEmail(email)` |

**Phase note**: Auth UI is added in Phase 4 (Integration). Phases 1–3 continue to open directly to Dashboard (current behavior preserved).

---

## 6. AUTHORIZATION (RBAC)

Roles: `owner`, `admin`, `staff`, `viewer`

| Action | owner | admin | staff | viewer |
|---|---|---|---|---|
| Products CRUD | ✅ | ✅ | view only | view only |
| Orders create/edit | ✅ | ✅ | ✅ | view only |
| Customers CRUD | ✅ | ✅ | create/edit | view only |
| Resources upload | ✅ | ✅ | ✅ | view only |
| Forms create | ✅ | ✅ | ❌ | view only |
| Pages create | ✅ | ✅ | ❌ | view only |
| Role management | ✅ | ❌ | ❌ | ❌ |

**Enforcement**: PostgreSQL RLS policies — database rejects unauthorized ops.

---

## 7. API CONTRACT (via Supabase SDK)

Supabase auto-generates REST from schema. Flutter uses SDK:

```dart
// List products (paginated, filtered)
supabase.from('products')
  .select('*, categories(name)')
  .ilike('name', '%query%')
  .eq('status', 'active')
  .order('created_at', ascending: false)
  .range(offset, offset + limit - 1)

// Create product
supabase.from('products').insert({...})

// Update product
supabase.from('products').update({...}).eq('id', id)

// Delete product
supabase.from('products').delete().eq('id', id)
```

---

## 8. RESULT / ERROR FORMAT

```dart
sealed class Result<T> {}
class Success<T> extends Result<T> { final T data; }
class Failure<T> extends Result<T> { final AppError error; }

class AppError {
  final String code;       // UNAUTHORIZED, NOT_FOUND, NETWORK_ERROR, ...
  final String message;
  final int? statusCode;
}
```

---

## 9. PAGINATION

**Strategy**: Offset pagination

```dart
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  bool get hasNext => (page * limit) < total;
}
```

Default page sizes: Products=20, Orders=20, Customers=20, Resources=30

---

## 10. FILE STORAGE

| Bucket | Public | Used for |
|---|---|---|
| `products` | ✅ | Product images |
| `resources` | ❌ | Resource files (signed URL) |
| `avatars` | ✅ | Profile avatars |

Limits: 10 MB max, MIME-type validated in Storage policies.

---

## 11. LOCAL vs REMOTE

| Data | Where |
|---|---|
| Theme / Language / Style | Local (Hive — existing) |
| Notification / Privacy prefs | Local (Hive — existing) |
| All business data | Remote (Supabase) |
| Auth session | Secure local (Supabase SDK) |

---

## 12. OFFLINE STRATEGY

- **Phase 3**: No offline writes. Show "no connection" state. In-memory cache per session.
- **Phase 4+**: Draft orders saved locally; disk cache for product catalogue.

---

## 13. SECURITY

- All API calls require JWT — Supabase enforces this
- No service-role key in Flutter app
- Secrets via `--dart-define` (never hardcoded)
- Input validated client-side + DB constraints
- File type/size validated in Storage policies
- RLS ensures users can only access their own business data

---

## 14. ENVIRONMENTS

| Env | Supabase | Flutter |
|---|---|---|
| Dev | `supabase start` (local Docker) | `--dart-define=SUPABASE_URL=http://localhost:54321` |
| Staging | Cloud project | `--dart-define=SUPABASE_URL=https://xxx.supabase.co` |
| Production | Cloud project | `--dart-define=SUPABASE_URL=https://yyy.supabase.co` |

---

## 15. NEW FLUTTER DEPENDENCIES TO ADD

```yaml
dependencies:
  supabase_flutter: ^2.x
  flutter_riverpod: ^2.x
  go_router: ^14.x
  cached_network_image: ^3.x
  image_picker: ^1.x
  file_picker: ^8.x

dev_dependencies:
  build_runner: ^2.x
```

---

## 16. BACKEND DEFINITION CHECKLIST

```
[x] Backend technology     → Supabase
[x] Database               → PostgreSQL (10 tables defined)
[x] Architecture           → Repository pattern, Mock → Real
[x] Entities               → profiles, categories, products, customers,
                              orders, order_items, resources,
                              form_definitions, form_submissions, page_contents
[x] Relationships          → Documented (section 4)
[x] Authentication         → Supabase Auth, JWT, auto-refresh
[x] Authorization          → RBAC, PostgreSQL RLS
[x] API contract           → Supabase SDK wrappers
[x] Error format           → sealed Result<T>
[x] Pagination             → Offset, configurable per entity
[x] Search + Filter + Sort → Server-side ilike + eq + order
[x] File storage           → Supabase Storage, 3 buckets
[x] Local vs remote        → Defined per data type
[x] Cache                  → In-memory Phase 3; disk Phase 4+
[x] Offline strategy       → Read-only offline Phase 3
[x] Security               → JWT, RLS, dart-define secrets
[x] Environments           → Local / Staging / Production
[x] Deployment             → Supabase cloud (managed)
```

---

> ✅ **Backend is fully defined.**
>
> **Next: Phase 2 — Complete Frontend** using Mock repositories.
> Backend implementation (Phase 3) begins only after all feature UIs pass quality gate.
