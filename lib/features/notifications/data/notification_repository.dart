import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> watchNotifications() {
    final userId = _client.auth.currentUser!.id;
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at');
  }

  Future<void> markRead(String notificationId) async {
    await _client.from('notifications').update({
      'is_read': true,
    }).eq('id', notificationId);
  }

  Future<void> markAllRead() async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('notifications').update({
      'is_read': true,
    }).eq('user_id', userId).eq('is_read', false);
  }
}
