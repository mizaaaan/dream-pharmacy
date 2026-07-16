import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'route_guard.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/shop/presentation/product_list_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  redirect: (context, state) async {
    final role = await RouteGuard.currentRole();
    final goingToAdmin = state.matchedLocation.startsWith('/admin');
    final goingToAuth = state.matchedLocation.startsWith('/login');

    if (role == AppRole.guest && !goingToAuth) return '/login';
    if (role != AppRole.guest && goingToAuth) return '/';
    if (goingToAdmin && role != AppRole.admin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/', builder: (c, s) => const ProductListScreen()),
    GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
    GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen()),
  ],
);
