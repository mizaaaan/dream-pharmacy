import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../cart/presentation/cart_provider.dart';
import '../data/order_repository.dart';
import '../data/prescription_upload_service.dart';
import '../../../core/theme/app_theme.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  Uint8List? _prescriptionBytes;
  String? _prescriptionFileName;
  bool _placing = false;
  String? _error;

  Future<void> _pickPrescription() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _prescriptionBytes = result.files.single.bytes;
        _prescriptionFileName = result.files.single.name;
      });
    }
  }

  Future<void> _placeOrder(bool needsPrescription) async {
    if (_addressController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a delivery address.');
      return;
    }
    if (needsPrescription && _prescriptionBytes == null) {
      setState(() => _error = 'Please upload a prescription for the restricted items in your cart.');
      return;
    }

    setState(() { _placing = true; _error = null; });

    try {
      final cartItems = ref.read(cartProvider);
      final orderId = await OrderRepository().createOrder(
        items: cartItems,
        deliveryAddress: _addressController.text.trim(),
        requiresPrescriptionReview: needsPrescription,
      );

      if (needsPrescription && _prescriptionBytes != null) {
        final ext = _prescriptionFileName!.split('.').last;
        await PrescriptionUploadService().upload(
          orderId: orderId,
          fileBytes: _prescriptionBytes!,
          fileExtension: ext,
        );
      }

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() => _error = 'Failed to place order: $e');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final needsPrescription = cartItems.any((item) => item.product.prescriptionRequired);
    final total = cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter your full delivery address',
              filled: true,
              fillColor: AppColors.paper,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.line),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          ...cartItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.product.name} x${item.quantity}', style: TextStyle(color: AppColors.ink)),
                    Text('৳${item.subtotal.toStringAsFixed(2)}', style: TextStyle(color: AppColors.inkSoft)),
                  ],
                ),
              )),
          Divider(color: AppColors.line),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink)),
              Text('৳${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink)),
            ],
          ),
          if (needsPrescription) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your cart contains prescription-only medicine. Please upload a valid prescription.',
                    style: TextStyle(color: AppColors.redDark),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _pickPrescription,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_prescriptionFileName ?? 'Upload Prescription'),
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: AppColors.redDark)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _placing ? null : () => _placeOrder(needsPrescription),
              child: _placing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }
}
