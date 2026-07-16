import 'package:flutter/material.dart';
import '../../domain/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (product.prescriptionRequired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Rx', style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              if (product.genericName != null)
                Text(product.genericName!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 8),
              if (product.strength != null || product.dosageForm != null)
                Text(
                  [product.strength, product.dosageForm].where((e) => e != null).join(' · '),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('৳${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    product.inStock ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                      color: product.inStock ? Colors.green : Colors.red,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
