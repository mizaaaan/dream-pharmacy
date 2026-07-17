import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final notificationListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).value ?? [];
  return notifications.where((n) => n['is_read'] == false).length;
});
