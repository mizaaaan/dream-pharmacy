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
- supabase_flutter for backend (auth, database, storage, realtime streams)
- file_picker (v11+, uses `FilePicker.pickFiles()` — **not** `FilePicker.platform.pickFiles()`, that getter was removed)

## Folder structure
## Database schema (Supabase Postgres)
Tables: `users` (role: customer/admin), `products`, `orders`, `order_items`, `prescriptions`, `admin_invites`, `notifications`.
Full RLS enabled on every table. **Important gotcha already fixed:** the original `users` RLS policy caused infinite recursion (a policy on `users` querying `users` to check admin role). Fixed via a `security definer` helper function `public.is_admin()` that bypasses RLS internally — used in `products`, `orders`, `users`, and `admin_invites` policies. If touching RLS again, keep using this pattern, don't go back to inline `exists (select ... from users)` inside a `users` table policy.

Storage: private bucket `prescriptions`, path convention `{user_id}/{order_id}/{filename}`, with folder-based RLS policies (2 policies: upload-own, read-own-or-admin).

### Admin invites
`admin_invites` table (`email`, `invited_by`, `used_at`) holds pending invites. The `handle_new_user()` trigger function (fires on `auth.users` insert) checks this table by email on signup — if a matching unused invite exists, the new user is created with `role = 'admin'` and the invite is marked used; otherwise `role = 'customer'` as before.

### Notifications
`notifications` table (`user_id`, `order_id`, `title`, `body`, `is_read`). A trigger `on_order_status_change` (function `notify_order_status_change()`) fires `after update on orders` whenever `status` changes to `approved` or `rejected`, and inserts a row for the customer. The Flutter app reads this via a Supabase realtime `.stream()` so the bell badge updates live.

### Stock validation
Checkout goes through a `place_order` RPC (Postgres function) that validates stock atomically and rejects the order if requested quantity exceeds available stock, instead of trusting client-side cart state. Cart quantity is also capped at available stock in the UI.

## What's fully built and tested
- Auth: signup/login/logout, auto-creates `users` row via Postgres trigger on `auth.users` insert (role determined by `admin_invites` check, see above)
- Role-based routing: `/admin` blocked for non-admins, redirects handled reactively via `GoRouterRefreshStream` tied to Supabase auth state changes
- Product catalog: search, category filter chips (otc/prescription/supplement/medical_device), paginated fetch (20/page) with infinite scroll on the storefront grid
- Product detail screen: tapping a product opens a full detail view (image, name, Rx badge, price, stock status, description, category/strength/form/manufacturer, quantity picker, Add to Cart) — no longer adds straight to cart
- Shopping cart: add/remove/adjust quantity, running total, badge count in app bar
- Checkout: delivery address, order summary, conditional prescription upload (only shown if cart has `prescription_required` items), atomic stock validation via `place_order` RPC, writes to `orders` + `order_items` + `prescriptions` tables
- Customer order history: "My Orders" screen accessible from the storefront app bar
- In-app notifications: bell icon with live unread-count badge in the storefront app bar; notifications screen lists order approval/rejection messages, tap to mark read, "mark all read" action
- Admin inventory management: view all products, edit stock via dialog, add new medicine via form dialog
- Admin order review: pending orders list, tap to view full order + uploaded prescription image (via signed URL) + Approve/Reject buttons, writes back to `orders.status` (which triggers the customer notification)
- Admin invite system: "Invite Admin" screen on the admin dashboard, enter an email, that person becomes admin automatically the next time they sign up with that email — no more manual DB edits needed for new admins
- CI/CD: `.github/workflows/deploy.yml` — every push to `main` auto-builds Flutter web and deploys to Vercel via `vercel --prod`, using GitHub repo secrets (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`)

## Test admin account
Email: `admin@dreampharmacy.com` — original account still has role `admin` set manually in the `users` table via Supabase Table Editor. New admins going forward should use the in-app "Invite Admin" flow instead of manual DB edits.

## Visual design — DONE
Custom brand theme built and applied across the entire app:
- `lib/core/theme/app_theme.dart` — `AppColors` palette (red `#E2231A` for customer-facing primary actions/AppBars, navy `#1F3A63` for the admin area, teal `#2CA89C` for success/totals/prices, amber `#C98A2B` for warnings/Rx flags, plus ink/inkSoft/paper/band/line neutrals) and `AppTheme.light()` (Hind for body text, Barlow Condensed for headlines, via `google_fonts`), wired into `MaterialApp.router` in `app.dart`.
- Customer-facing screens (red branding): storefront AppBar + product cards + product detail + cart screen + checkout screen + order history + notifications + login screen + signup screen — all themed with `AppColors`.
- Admin screens (navy branding, visually distinct from customer side): admin dashboard, inventory management, pending orders, order review, invite admin — navy AppBars, navy accents, teal "Approve" button, red "Reject" button.
- App icons (`web/icons/*.png`, `web/favicon.png`) are already custom-branded — red cross + stethoscope + pill mark logo, "DREAM PHARMACY" wordmark, "To the satisfaction of Almighty" tagline. Not default Flutter placeholders.
- No in-app product photos yet (image_url column exists but unused).

## web/index.html — DONE
- Branded loading splash screen (`#splash` div): shows the app logo (`icons/Icon-512.png`) + a spinning loader on a light background, auto-removed via the `flutter-first-frame` browser event once the Flutter app renders.
- `theme-color` meta tag set to brand red.
- Open Graph + Twitter Card meta tags added for link-preview cards (WhatsApp/Facebook/Twitter shares now show logo + description instead of a bare link).
- `preconnect` hints added for the Supabase project domain and Google Fonts domains to shave a little off first-load time.
- `manifest.json` was already correctly branded (name, red theme/background color, all 4 icon sizes) — untouched.

## Known gaps — NOT built yet
- No product photos (image_url column exists, unused)
- No email/SMS notifications (in-app notifications only, via the `notifications` table)
- No pagination on admin inventory list or order history list (only the customer storefront grid is paginated so far)

## How this was built
Entirely from a GitHub Codespace (browser-based, zero local machine), using `cat > file << 'EOF' ... EOF` heredocs pasted into the terminal to create/overwrite Dart files one at a time, then `flutter build web --release --dart-define=...` to compile, then `git push` to trigger GitHub Actions auto-deploy to Vercel. Supabase SQL changes (tables, RLS policies, trigger functions) were run through the Supabase dashboard's SQL Editor, not via CLI/migrations.

## Workflow preference for continuing this project
The person building this prefers **one small step at a time** — a single command or action per message, confirmed with actual output/screenshot before moving to the next step, rather than large multi-step blocks — up until a feature's backend/SQL groundwork is confirmed working, at which point they prefer the remaining file edits + build + commit + push bundled into **one full command block** to run at once, confirming only the final green GitHub Actions checkmark (or pasting the error if something breaks). They communicate briefly and directly, and work primarily from a mobile browser.
