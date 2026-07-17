import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_providers.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationRepositoryProvider).markAllRead(),
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          final sorted = [...notifications]..sort(
              (a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = sorted[index];
              final isRead = n['is_read'] == true;
              return ListTile(
                tileColor: isRead ? null : AppColors.band,
                leading: Icon(
                  n['title'] == 'Order Approved' ? Icons.check_circle : Icons.cancel,
                  color: n['title'] == 'Order Approved' ? AppColors.teal : AppColors.red,
                ),
                title: Text(n['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n['body']),
                onTap: () {
                  if (!isRead) {
                    ref.read(notificationRepositoryProvider).markRead(n['id']);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
