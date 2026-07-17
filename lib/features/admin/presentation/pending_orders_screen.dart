import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/order_review_provider.dart';
import 'order_review_screen.dart';
import '../../../core/theme/app_theme.dart';

class PendingOrdersScreen extends ConsumerWidget {
  const PendingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(pendingOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Pending Orders'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text('No pending orders.', style: TextStyle(color: AppColors.inkSoft)),
            );
          }
          final notifier = ref.read(pendingOrdersProvider.notifier);
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                notifier.loadMore();
              }
              return false;
            },
            child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length + (notifier.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final order = orders[index];
              final customerName = order['users']?['full_name'] ?? 'Unknown';
              final items = order['order_items'] as List;
              final total = order['total_amount'];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.line),
                ),
                child: ListTile(
                  title: Text(customerName, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
                  subtitle: Text('${items.length} item(s) · ৳$total', style: const TextStyle(color: AppColors.inkSoft)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.navy),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OrderReviewScreen(order: order)),
                    );
                    ref.invalidate(pendingOrdersProvider);
                  },
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }
}
