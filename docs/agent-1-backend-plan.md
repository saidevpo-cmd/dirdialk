# Agent 1 — Backend Plan (Execution Plan)
## دور: Backend, Database, Security, Data Architecture

### 1. الهدف
تحليل كامل للمشروع الحالي، توثيق المشاكل، واستكمال ما يلزم لجعله جاهز للتشغيل والاختبار والنشر على GitHub مع ضمان حفظ البيانات والمنطق.

### 2. نطاق العمل
- Supabase + PostgreSQL migrations، RLS، Storage policies
- Domain Models، Repository Interfaces، Implementations (Mock + Supabase)
- Data persistence (Hive) + authoritative sources
- Security، validation، error handling (Result<AppError>)
- Testing، verification، cleanup

### 3. الحالة الحالية (مؤكدة)
- Flutter 3.47.5 / Dart 3.13.4
- flutter analyze: نظيف
- flutter test: 38 tests passed
- Supabase schema موجود (migrations 3 + seed)
- Supabase repos موجودة (products, categories, orders, customers, pages, forms, resources, templates, locations, tracking, site_settings)
- AppRepositories يختار Remote عند توفر --dart-define
- Auth + RLS مستندين في docs

### 4. المهام المطلوبة
1. توثيق البنية الحالية (تم جزئياً)
2. مراجعة Models والمطابقات مع DB (mappers)
3. مراجعة Repositories interfaces + implementations
4. التحقق من حفظ البيانات (Hive vs remote) ومنطق CRUD
5. فحص RLS/Storage consistency مع schema
6. إضافة/تحديث اختبارات backend/domain/repo
7. Clean up (unused، hygiene، .gitignore)
8. التحقق النهائي (analyze + tests + build check)

### 5. معايير القبول
- flutter analyze نظيف
- جميع الاختبارات تمر
- لا توجد أسرار (service-role)
- migrations صحيحة، لا يتم تعديل migrations مطبقة
- RLS مفهومة ومتوثقة
- الكود قابل للتشغيل بدون Supabase (offline) ومع Supabase
