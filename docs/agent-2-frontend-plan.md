# Agent 2 — Frontend / UX / Responsive / a11y / Testing Plan

> Owner: Agent 2 (frontend). Backend, schema, RLS, storage and the Dart
> Supabase data layer are **Agent 1 owned**. This document records what Agent 2
> changed, what is shared, and what still needs coordination.

## 0. Coordination status

- `docs/agent-1-backend-plan.md` — **not present** in the tree.
- `docs/backend-contracts.md` — **not present** in the tree.

Because Agent 1 has not published a separate plan/contracts file, the working
contract is the code that already exists and is registered in
`docs/agent-integration.md` and `docs/backend-architecture.md`:

- Domain models in `lib/domain/models/*` (shape changes coordinated).
- Repository interfaces in `lib/domain/repositories/*`, all returning
  `Result<T>` (`Success<T>` / `Failure<AppError>`).
- `AppRepositories.instance` is the single composition root. Screens must never
  construct repositories directly.
- Settings go through `SettingsController`; no second persistence system.

**No frontend change in this plan alters a database schema, RLS policy, storage
policy or the Supabase data layer.** Any such change is explicitly left to
Agent 1.

## 1. Audit summary (baseline before changes)

- `flutter analyze` → clean.
- `flutter test` → 38 passing.
- `dart format --output=none --set-exit-if-changed .` → **not clean** (87 files
  written with the pre-tall-style formatter). Normalized in this pass.
- 12 of 17 feature files were hardcoded English; statuses, table headers,
  dialogs and empty/error strings were not translated.
- Mutation `Result`s were ignored on products/orders/customers/resources/forms/
  pages/store → failures displayed as success (notably store checkout).
- `Cancel Order` and image removal had no confirmation.
- Fixed dialog widths (480–600) could overflow narrow phones.
- Mobile card action buttons lacked tooltips/semantics.
- No error/success SnackBars after create/update/delete.

## 2. Changes made

### Shared infrastructure (`lib/shared/`)
- `utils/app_feedback.dart` — `AppFeedback.success/error` + `messageForResult`.
- `utils/dialog_sizing.dart` — viewport-clamped dialog widths.
- Localized defaults in `ErrorStateView`, `ResponsiveDataTable`,
  `SearchAndFilterBar` (callers may still override).

### Localization (`lib/l10n/app_{en,ar,fr}.arb`)
- Added the missing keys for the localized admin/store surfaces. Key sets remain
  identical across the three locales (parity test added).

### Pages
- Products, Orders, Customers, Store: localized, mutation feedback, delete/cancel
  confirmations, viewport-clamped dialogs, accessible mobile actions.
- Categories: localized remaining hardcoded labels; image removal confirmation.
- Resources / Forms / Pages: mutation feedback, clamped dialogs, mobile edit.
- Product details / gallery / image manager: localized labels.

### Tests
- See section 4.

## 3. Ownership notes (shared files touched)

| File | Previous owner | Action |
| --- | --- | --- |
| `lib/l10n/app_*.arb` + `generated/*` | Agent 1 | **Agent 2 added new keys** (parity preserved, regenerated) |
| `lib/shared/widgets/*` | Agent 1 | localized defaults; public API kept backward-compatible |
| `lib/domain/models/*` | Agent 1 | untouched |
| `lib/data/**`, `supabase/**` | Agent 1 | untouched |

## 4. Tests

| Test file | Covers |
| --- | --- |
| `test/localization_test.dart` | ARB key parity, placeholder parity, RTL/LTR, locale switch |
| `test/form_validation_test.dart` | product/customer form validation, delete confirmation |
| `test/feedback_test.dart` | success/error SnackBars after mutations |
| `test/responsive_layout_test.dart` | shell breakpoints + no overflow on 360/768/1400 |
| `test/states_test.dart` | loading / empty / error states |
| existing tests | kept green |

## 5. Known remaining work (not in this pass)

- Full localization of resources / forms / pages long-form copy (labels done,
  a few descriptive strings remain English).
- Server-side pagination wiring in the UI (repositories expose `PaginatedResult`;
  pages still request the first page).
- Live RLS / storage policy verification requires a Supabase project
  (`supabase start` or cloud) — **not verifiable locally**.
