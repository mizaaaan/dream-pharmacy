import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/order_review_provider.dart';
import 'order_review_screen.dart';

class PendingOrdersScreen extends ConsumerWidget {
  const PendingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(pendingOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No pending orders.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final customerName = order['users']?['full_name'] ?? 'Unknown';
              final items = order['order_items'] as List;
              final total = order['total_amount'];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(customerName),
                  subtitle: Text('${items.length} item(s) · ৳$total'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OrderReviewScreen(order: order)),
                    );
                    ref.invalidate(pendingOrdersProvider);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
