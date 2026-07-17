import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
import '../../../core/theme/app_theme.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        title: const Text('Your Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(color: AppColors.inkSoft),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final atMaxStock = item.quantity >= item.product.stockQuantity;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            item.product.name,
                            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '৳${item.product.price.toStringAsFixed(2)} each',
                            style: const TextStyle(color: AppColors.inkSoft),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.teal),
                                onPressed: () => cartNotifier.updateQuantity(
                                    item.product.id, item.quantity - 1),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.teal),
                                onPressed: atMaxStock
                                    ? null
                                    : () => cartNotifier.updateQuantity(
                                        item.product.id, item.quantity + 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.red),
                                onPressed: () => cartNotifier.removeProduct(item.product.id),
                              ),
                            ],
                          ),
                        ),
                        if (atMaxStock)
                          const Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(
                              'Max available stock reached',
                              style: TextStyle(color: AppColors.amber, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ৳${cartNotifier.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.teal,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                    onPressed: () => context.push('/checkout'),
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            ),
    );
  }
}
