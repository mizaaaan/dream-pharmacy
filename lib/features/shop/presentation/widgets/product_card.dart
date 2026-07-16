import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (product.prescriptionRequired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Rx', style: TextStyle(color: AppColors.redDark, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              if (product.genericName != null) ...[
                const SizedBox(height: 2),
                Text(product.genericName!, style: TextStyle(color: AppColors.inkSoft, fontSize: 12)),
              ],
              const SizedBox(height: 8),
              if (product.strength != null || product.dosageForm != null)
                Text(
                  [product.strength, product.dosageForm].where((e) => e != null).join(' · '),
                  style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('৳${product.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink)),
                  Text(
                    product.inStock ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                      color: product.inStock ? AppColors.teal : AppColors.redDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
