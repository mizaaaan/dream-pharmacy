import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/app_user.dart';

class RouteGuard {
  static final _client = Supabase.instance.client;

  static Future<AppRole> currentRole() async {
    final session = _client.auth.currentSession;
    if (session == null) return AppRole.guest;

    final data = await _client
        .from('users')
        .select('role')
        .eq('id', session.user.id)
        .maybeSingle();

    if (data == null) return AppRole.customer;
    return data['role'] == 'admin' ? AppRole.admin : AppRole.customer;
  }
}
