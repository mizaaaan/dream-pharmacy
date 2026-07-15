import 'package:go_router/go_router.dart';
import 'route_guard.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/shop/presentation/product_list_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final role = await RouteGuard.currentRole();
    final goingToAdmin = state.matchedLocation.startsWith('/admin');
    final goingToAuth = state.matchedLocation.startsWith('/login');

    if (role == AppRole.guest && !goingToAuth) return '/login';
    if (goingToAdmin && role != AppRole.admin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/', builder: (c, s) => const ProductListScreen()),
    GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen()),
  ],
);
