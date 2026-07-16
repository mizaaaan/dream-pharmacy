import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/order_review_provider.dart';
import '../../../core/theme/app_theme.dart';

class OrderReviewScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const OrderReviewScreen({super.key, required this.order});

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  String? _signedUrl;
  bool _loadingImage = true;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrescriptionImage();
  }

  Future<void> _loadPrescriptionImage() async {
    final prescriptions = widget.order['prescriptions'] as List?;
    if (prescriptions != null && prescriptions.isNotEmpty) {
      final filePath = prescriptions.first['file_url'] as String;
      final url = await ref.read(orderReviewRepositoryProvider).getPrescriptionSignedUrl(filePath);
      if (mounted) setState(() { _signedUrl = url; _loadingImage = false; });
    } else {
      setState(() => _loadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final customerName = order['users']?['full_name'] ?? 'Unknown';
    final phone = order['users']?['phone'] ?? 'N/A';
    final address = order['delivery_address'] ?? '';
    final items = order['order_items'] as List;
    final total = order['total_amount'];
    final reviewState = ref.watch(orderReviewProvider);

    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Review Order'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Customer: $customerName', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          Text('Phone: $phone', style: const TextStyle(color: AppColors.inkSoft)),
          Text('Address: $address', style: const TextStyle(color: AppColors.inkSoft)),
          const Divider(height: 32, color: AppColors.line),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          ...items.map((item) {
            final productName = item['products']?['name'] ?? 'Unknown';
            return Text(
              '${item['quantity']}x $productName — ৳${item['unit_price']}',
              style: const TextStyle(color: AppColors.inkSoft),
            );
          }),
          const SizedBox(height: 8),
          Text('Total: ৳$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.teal)),
          const Divider(height: 32, color: AppColors.line),
          const Text('Prescription', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          if (_loadingImage)
            const Center(child: CircularProgressIndicator())
          else if (_signedUrl == null)
            const Text('No prescription attached.', style: TextStyle(color: AppColors.inkSoft))
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(_signedUrl!, errorBuilder: (c, e, s) => const Text('Could not load image. It may be a PDF — open link separately.')),
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Rejection reason (if rejecting)',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.navy, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: reviewState.isLoading
                      ? null
                      : () async {
                          await ref.read(orderReviewProvider.notifier).reviewOrder(
                                orderId: order['id'],
                                action: ReviewAction.reject,
                                rejectionReason: _reasonController.text.trim(),
                              );
                          if (mounted) Navigator.of(context).pop();
                        },
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                  onPressed: reviewState.isLoading
                      ? null
                      : () async {
                          await ref.read(orderReviewProvider.notifier).reviewOrder(
                                orderId: order['id'],
                                action: ReviewAction.approve,
                              );
                          if (mounted) Navigator.of(context).pop();
                        },
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
