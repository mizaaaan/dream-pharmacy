import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_history_provider.dart';
import '../../../core/theme/app_theme.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(String isoString) {
  try {
    final d = DateTime.parse(isoString).toLocal();
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_months[d.month - 1]} ${d.year}, $hour12:$minute $ampm';
  } catch (_) {
    return isoString;
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  const _StatusInfo(this.label, this.color);
}

_StatusInfo _statusInfo(String status) {
  switch (status) {
    case 'approved':
      return const _StatusInfo('Approved', AppColors.teal);
    case 'rejected':
      return const _StatusInfo('Rejected', AppColors.red);
    case 'pending_review':
    default:
      return const _StatusInfo('Pending Review', AppColors.amber);
  }
}

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        title: const Text('My Orders'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Error loading orders: $e', style: const TextStyle(color: AppColors.red)),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text("You haven't placed any orders yet.", style: TextStyle(color: AppColors.inkSoft)),
            );
          }
          final notifier = ref.read(myOrdersProvider.notifier);
          return RefreshIndicator(
            color: AppColors.red,
            onRefresh: () async => ref.invalidate(myOrdersProvider),
            child: NotificationListener<ScrollNotification>(
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
                final status = _statusInfo(order['status'] as String? ?? 'pending_review');
                final items = order['order_items'] as List;
                final total = order['total_amount'];
                final createdAt = order['created_at'] as String?;
                final rejectionReason = order['rejection_reason'] as String?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          createdAt != null ? _formatDate(createdAt) : 'Order',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(color: status.color, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${items.length} item(s) · ৳$total',
                        style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
                      ),
                    ),
                    children: [
                      const Divider(color: AppColors.line),
                      ...items.map((item) {
                        final productName = item['products']?['name'] ?? 'Unknown item';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item['quantity']}x $productName',
                                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                              ),
                              Text(
                                '৳${item['unit_price']}',
                                style: const TextStyle(color: AppColors.ink, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (status.label == 'Rejected' && rejectionReason != null && rejectionReason.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Reason: $rejectionReason',
                            style: const TextStyle(color: AppColors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            ),
          );
        },
      ),
    );
  }
}
