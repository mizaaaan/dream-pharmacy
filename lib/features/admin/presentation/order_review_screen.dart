import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/order_review_provider.dart';

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
      appBar: AppBar(title: const Text('Review Order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Customer: $customerName', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Phone: $phone'),
          Text('Address: $address'),
          const Divider(height: 32),
          const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ...items.map((item) {
            final productName = item['products']?['name'] ?? 'Unknown';
            return Text('${item['quantity']}x $productName — ৳${item['unit_price']}');
          }),
          const SizedBox(height: 8),
          Text('Total: ৳$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 32),
          const Text('Prescription', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingImage)
            const Center(child: CircularProgressIndicator())
          else if (_signedUrl == null)
            const Text('No prescription attached.')
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(_signedUrl!, errorBuilder: (c, e, s) => const Text('Could not load image. It may be a PDF — open link separately.')),
            ),
          const SizedBox(height: 24),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Rejection reason (if rejecting)',
              border: OutlineInputBorder(),
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
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
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
