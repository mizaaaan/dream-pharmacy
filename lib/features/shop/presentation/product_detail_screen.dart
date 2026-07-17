import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/product.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartCount = ref.watch(cartProvider.select((items) =>
        items.fold(0, (sum, item) => sum + item.quantity)));

    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        title: const Text('Product Details'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.medication_outlined,
                        size: 64,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  )
                : const Icon(Icons.medication_outlined, size: 64, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
                ),
              ),
              if (product.prescriptionRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Rx Required',
                    style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          if (product.genericName != null) ...[
            const SizedBox(height: 4),
            Text(product.genericName!, style: const TextStyle(color: AppColors.inkSoft, fontSize: 14)),
          ],
          const SizedBox(height: 16),
          Text(
            '৳${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.teal),
          ),
          const SizedBox(height: 4),
          Text(
            product.inStock ? 'In stock (${product.stockQuantity} available)' : 'Out of stock',
            style: TextStyle(color: product.inStock ? AppColors.teal : AppColors.red, fontSize: 13),
          ),
          const Divider(height: 32, color: AppColors.line),
          if (product.description != null && product.description!.isNotEmpty) ...[
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 6),
            Text(product.description!, style: const TextStyle(color: AppColors.inkSoft, height: 1.4)),
            const SizedBox(height: 20),
          ],
          const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 8),
          _DetailRow(label: 'Category', value: product.category),
          if (product.strength != null) _DetailRow(label: 'Strength', value: product.strength!),
          if (product.dosageForm != null) _DetailRow(label: 'Form', value: product.dosageForm!),
          if (product.manufacturer != null) _DetailRow(label: 'Manufacturer', value: product.manufacturer!),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.teal),
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.teal),
                    onPressed: product.inStock && _quantity < product.stockQuantity
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                onPressed: product.inStock
                    ? () {
                        ref.read(cartProvider.notifier).addProductQuantity(product, _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$_quantity x ${product.name} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        context.pop();
                      }
                    : null,
                child: Text(product.inStock ? 'Add to Cart' : 'Out of Stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
