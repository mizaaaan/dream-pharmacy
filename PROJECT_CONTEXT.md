# Dream Pharmacy — Project Context Brief

*Paste this whole file as your first message to any new Claude session that needs to work on this app.*

## What this is
A Flutter Web e-commerce app for an online pharmacy, backed by Supabase (Postgres + Auth + Storage + Edge Functions), deployed on Vercel with GitHub Actions auto-deploy. Zero-cost hosting stack (Resend email is on its free tier too).

## Links
- **Live app:** https://dream-pharmacy.vercel.app
- **GitHub repo:** https://github.com/mizaaaan/dream-pharmacy
- **Supabase project:** dream-pharmacy (project ref: `dtcljkscqrovsnfvdubd`)
- **Dev environment:** GitHub Codespaces (no local machine used)

## Tech stack
- Flutter Web, Riverpod 3.x for state management (uses `Notifier`/`AsyncNotifier`/`NotifierProvider` — **not** the older `StateProvider`/`StateNotifier` API, which is removed in this version)
- go_router for routing with role-based redirects
- supabase_flutter for backend (auth, database, storage, realtime streams)
- Supabase Edge Functions (Deno) for server-side logic that needs secrets (email sending)
- Resend for transactional email (free tier, currently test mode — no verified domain yet, so email only reaches the Resend account owner's signup address)
- file_picker (v11+, uses `FilePicker.pickFiles()` — **not** `FilePicker.platform.pickFiles()`, that getter was removed) and image_picker, both used for prescription and product image uploads

## Folder structure
## Database schema (Supabase Postgres)
Tables: `users` (role: customer/admin), `products`, `orders`, `order_items`, `prescriptions`, `admin_invites`, `notifications`.
Full RLS enabled on every table. **Important gotcha already fixed:** the original `users` RLS policy caused infinite recursion (a policy on `users` querying `users` to check admin role). Fixed via a `security definer` helper function `public.is_admin()` that bypasses RLS internally — used in `products`, `orders`, `users`, and `admin_invites` policies. If touching RLS again, keep using this pattern, don't go back to inline `exists (select ... from users)` inside a `users` table policy.

Extensions: `pg_net` enabled (used to call the email Edge Function from a trigger).

Storage buckets:
- `prescriptions` (private) — path convention `{user_id}/{order_id}/{filename}`, folder-based RLS (upload-own, read-own-or-admin)
- `product-images` (public) — anyone can view; only admins (via `is_admin()`) can insert/update/delete

### Admin invites
`admin_invites` table (`email`, `invited_by`, `used_at`) holds pending invites. The `handle_new_user()` trigger function (fires on `auth.users` insert) checks this table by email on signup — if a matching unused invite exists, the new user is created with `role = 'admin'` and the invite is marked used; otherwise `role = 'customer'` as before.

### Notifications (in-app + email)
`notifications` table (`user_id`, `order_id`, `title`, `body`, `is_read`). Trigger `on_order_status_change` (function `notify_order_status_change()`) fires `after update on orders` whenever `status` changes to `approved` or `rejected`. It does two things:
1. Inserts a row into `notifications` — read live in the Flutter app via a Supabase realtime `.stream()`, shown as a bell icon with unread badge
2. Calls `net.http_post` to the `send-order-email` Edge Function, which emails the customer via Resend

### Stock validation
Checkout goes through a `place_order` RPC (Postgres function) that validates stock atomically and rejects the order if requested quantity exceeds available stock, instead of trusting client-side cart state. Cart quantity is also capped at available stock in the UI.

### Product photos
Admins upload a photo per product from the Inventory Management screen (camera icon per row) — uploads to the `product-images` bucket, stores the public URL on `products.image_url`. Shown as a thumbnail on storefront product cards and full-size on the product detail screen. New products can also get a photo assigned after creation via the same flow.

## What's fully built and tested
- Auth: signup/login/logout, auto-creates `users` row via Postgres trigger on `auth.users` insert (role determined by `admin_invites` check, see above)
- Role-based routing: `/admin` blocked for non-admins, redirects handled reactively via `GoRouterRefreshStream` tied to Supabase auth state changes
- Product catalog: search, category filter chips (otc/prescription/supplement/medical_device), paginated fetch (20/page) with infinite scroll on the storefront grid, image thumbnails on cards
- Product detail screen: full detail view (image, name, Rx badge, price, stock status, description, category/strength/form/manufacturer, quantity picker, Add to Cart)
- Shopping cart: add/remove/adjust quantity, running total, badge count in app bar
- Checkout: delivery address, order summary, conditional prescription upload, atomic stock validation via `place_order` RPC, writes to `orders` + `order_items` + `prescriptions`
- Customer order history: paginated "My Orders" screen with infinite scroll, expandable order cards, status badges, rejection reason shown when applicable
- In-app notifications: bell icon with live unread-count badge; notifications screen, tap to mark read, "mark all read"
- Email notifications: customer gets an email via Resend when their order is approved/rejected (currently test mode — see Known gaps)
- Admin inventory management: paginated product list with infinite scroll, per-product photo upload, edit stock via dialog, add new medicine via form dialog
- Admin order review: pending orders list, view full order + prescription image (signed URL) + Approve/Reject, triggers both in-app and email notification to the customer
- Admin invite system: "Invite Admin" screen, enter an email, that person becomes admin automatically on their next signup with that email
- CI/CD: `.github/workflows/deploy.yml` — every push to `main` auto-builds Flutter web and deploys to Vercel via `vercel --prod`, using GitHub repo secrets (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`)
- Supabase CLI is linked to the project from the Codespace (`npx supabase link`), used for deploying Edge Functions and managing secrets (`npx supabase secrets set`)

## Test admin account
Email: `admin@dreampharmacy.com` — role set manually in the `users` table. New admins going forward should use the in-app "Invite Admin" flow instead.

## Visual design — DONE
Custom brand theme (`lib/core/theme/app_theme.dart`): red `#E2231A` for customer-facing UI, navy `#1F3A63` for admin, teal `#2CA89C` for success/totals/prices, amber `#C98A2B` for warnings/Rx, via `AppColors` + `AppTheme.light()` (Hind body / Barlow Condensed headlines via google_fonts). Applied across every screen including the newer ones (order history, notifications, invite admin). Custom app icons and branded splash screen in `web/index.html` also done.

## Known gaps — NOT built yet
- **Resend is in test mode** — no verified domain, so emails currently only reach the Resend account owner's own signup address, not real customers. Needs a domain pointed at Resend to go live for all customers.
- No SMS notifications (explicitly skipped — no free-tier SMS option, project stays zero-cost)
- No pagination on the admin "Pending Orders" review screen (only inventory list and customer order history are paginated so far)

## How this was built
Entirely from a GitHub Codespace (browser-based, zero local machine), using `cat > file << 'EOF' ... EOF` heredocs and small `python3` scripts (for surgical multi-line edits to existing files) pasted into the terminal, then `flutter build web --release --dart-define=...` to compile, then `git push` to trigger GitHub Actions auto-deploy to Vercel. Supabase SQL changes (tables, RLS policies, trigger functions, extensions) were run through the Supabase dashboard's SQL Editor. Edge Functions were deployed via the Supabase CLI (`npx supabase functions deploy <name> --no-verify-jwt`) after linking the project with `npx supabase link --project-ref dtcljkscqrovsnfvdubd`. Secrets for Edge Functions (e.g. `RESEND_API_KEY`) are set via `npx supabase secrets set`, never committed to the repo.

## Workflow preference for continuing this project
The person building this prefers **one small step at a time** — a single command or action per message, confirmed with actual output/screenshot before moving to the next step, rather than large multi-step blocks — up until a feature's backend/SQL/CLI groundwork is confirmed working, at which point they prefer the remaining file edits + build + commit + push bundled into **one full command block** to run at once, confirming only the final green GitHub Actions checkmark (or pasting the error if something breaks). They communicate briefly and directly, and work primarily from a mobile browser.
