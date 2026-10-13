# Backend Contracts
## Repository Interfaces (stable contracts)

All return `Future<Result<T>>`. Domain models under `lib/domain/models/`.

### Core
- ProductRepository: list({search,status,categoryId,page,limit}), getById, create, update, delete, categories, stats
- CategoryRepository: all, list, getById, getBySlug, create, update, delete, stats
- CustomerRepository: list, getById, getByEmail, create, update, delete, stats
- OrderRepository: list({search,status,page,limit}), getById, getByNumber, create, update, delete, stats, addItem, updateItem, removeItem
- ResourceRepository: list({search,category,type,published,page,limit}), getById, create, update, delete, stats
- PageRepository: list, getById, getBySlug, create, update, delete, publish, unpublish, stats
- FormRepository: definitions, getDefinition, createDefinition, updateDefinition, deleteDefinition, submissions, submit, stats
- LocationRepository: all, list, getById, create, update, delete, setDefault
- TrackingRepository: events, addEvent, updateStatus, stats
- TemplateRepository: list, getById, getBySlug, create, update, delete, publish
- SiteSettingsRepository: get, save

### Types
- Result<T> (Success/Failure)
- AppError (network, notFound, validation, unauthorized, forbidden, conflict, unknown)
- PaginatedResult<T>

### Rules
- Keep contracts minimal and aligned with current mocks + Supabase impl
- Do not break existing callers
- Prefer idempotent operations
- Validate server-side for business ops
