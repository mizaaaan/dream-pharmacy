# Dream Pharmacy — Project Context Brief

*Paste this whole file as your first message to any new Claude session that needs to work on this app.*

## What this is
A Flutter Web e-commerce app for an online pharmacy, backed by Supabase (Postgres + Auth + Storage), deployed on Vercel with GitHub Actions auto-deploy. Zero-cost hosting stack.

## Links
- **Live app:** https://dream-pharmacy.vercel.app
- **GitHub repo:** https://github.com/mizaaaan/dream-pharmacy
- **Supabase project:** dream-pharmacy (project ref: `dtcljkscqrovsnfvdubd`)
- **Dev environment:** GitHub Codespaces (no local machine used)

## Tech stack
- Flutter Web, Riverpod 3.x for state management (uses `Notifier`/`AsyncNotifier`/`NotifierProvider` — **not** the older `StateProvider`/`StateNotifier` API, which is removed in this version)
- go_router for routing with role-based redirects
- supabase_flutter for backend (auth, database, storage)
- file_picker (v11+, uses `FilePicker.pickFiles()` — **not** `FilePicker.platform.pickFiles()`, that getter was removed)

## Folder structure
```
lib/
  core/
    config/supabase_config.dart       # Supabase init
    router/app_router.dart            # go_router + role-based redirect + auth refresh listener
    router/route_guard.dart           # checks user role from `users` table
  features/
    auth/          # login, signup, auth state provider
    shop/           # product catalog: model, repository, providers, search/filter UI
    cart/           # cart item model, Notifier-based cart provider, cart screen
    checkout/        # order repository, prescription upload service, checkout screen
    admin/
      data/          # admin_repository.dart (product CRUD), order_review_repository.dart
      presentation/  # admin_dashboard_screen, inventory_management_screen,
                      # pending_orders_screen, order_review_screen
                      # providers/order_review_provider.dart
```

## Database schema (Supabase Postgres)
Tables: `users` (role: customer/admin), `products`, `orders`, `order_items`, `prescriptions`.
Full RLS enabled on every table. **Important gotcha already fixed:** the original `users` RLS policy caused infinite recursion (a policy on `users` querying `users` to check admin role). Fixed via a `security definer` helper function `public.is_admin()` that bypasses RLS internally — used in `products`, `orders`, and `users` policies. If touching RLS again, keep using this pattern, don't go back to inline `exists (select ... from users)` inside a `users` table policy.

Storage: private bucket `prescriptions`, path convention `{user_id}/{order_id}/{filename}`, with folder-based RLS policies (2 policies: upload-own, read-own-or-admin).

## What's fully built and tested
- Auth: signup/login/logout, auto-creates `users` row via Postgres trigger on `auth.users` insert
- Role-based routing: `/admin` blocked for non-admins, redirects handled reactively via `GoRouterRefreshStream` tied to Supabase auth state changes
- Product catalog: search, category filter chips (otc/prescription/supplement/medical_device), 11 seeded medicines
- Shopping cart: add/remove/adjust quantity, running total, badge count in app bar
- Checkout: delivery address, order summary, conditional prescription upload (only shown if cart has `prescription_required` items), writes to `orders` + `order_items` + `prescriptions` tables
- Admin inventory management: view all products, edit stock via dialog, add new medicine via form dialog
- Admin order review: pending orders list, tap to view full order + uploaded prescription image (via signed URL) + Approve/Reject buttons, writes back to `orders.status`
- CI/CD: `.github/workflows/deploy.yml` — every push to `main` auto-builds Flutter web and deploys to Vercel via `vercel --prod`, using GitHub repo secrets (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`)

## Test admin account
Email: `admin@dreampharmacy.com` — role manually set to `admin` in the `users` table via Supabase Table Editor (there's no admin invite/promotion flow built yet — this is done by hand).

## Known gaps — NOT built yet (functional MVP, not production-polished)
- **Visual design:** everything uses default Flutter Material widgets. No custom theme/branding, no logo, no product photos (image_url column exists but unused). This is the main thing to address next.
- No product detail screen (tapping a product adds straight to cart)
- No customer order history/tracking screen
- No stock validation at checkout (can order more than available)
- No email/SMS notifications on order approval/rejection
- No admin invite system (manual DB edit only)
- No pagination (fine now, will matter at scale)

## How this was built
Entirely from a GitHub Codespace (browser-based, zero local machine), using `cat > file << 'EOF' ... EOF` heredocs pasted into the terminal to create/overwrite Dart files one at a time, then `flutter build web --release --dart-define=...` to compile, then a local Python HTTP server to preview in the Codespace browser tab before pushing. Supabase SQL changes were run through the Supabase dashboard's SQL Editor, not via CLI/migrations.

## Workflow preference for continuing this project
The person building this prefers **one small step at a time** — a single command or action per message, confirmed with actual output/screenshot before moving to the next step, rather than large multi-step blocks. They communicate briefly and directly, and work primarily from a mobile browser.
