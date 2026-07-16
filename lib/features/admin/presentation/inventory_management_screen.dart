import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_providers.dart';
import '../../../core/theme/app_theme.dart';

class InventoryManagementScreen extends ConsumerWidget {
  const InventoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.band,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Inventory Management'),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('No products yet.', style: TextStyle(color: AppColors.inkSoft)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.line),
                ),
                child: ListTile(
                  title: Text(p.name, style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${p.category} · Stock: ${p.stockQuantity} · ৳${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.inkSoft),
                  ),
                  trailing: p.prescriptionRequired
                      ? const Icon(Icons.medical_services, color: AppColors.amber)
                      : null,
                  onTap: () => _showEditStockDialog(context, ref, p.id, p.name, p.stockQuantity),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        onPressed: () => _showAddProductDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }

  void _showEditStockDialog(BuildContext context, WidgetRef ref, String productId, String name, int currentStock) {
    final controller = TextEditingController(text: '$currentStock');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update stock: $name'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stock quantity'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: () async {
              final newStock = int.tryParse(controller.text) ?? currentStock;
              await ref.read(adminRepositoryProvider).updateStock(productId, newStock);
              ref.invalidate(allProductsProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    String category = 'otc';
    bool prescriptionRequired = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: const [
                    DropdownMenuItem(value: 'otc', child: Text('OTC')),
                    DropdownMenuItem(value: 'prescription', child: Text('Prescription')),
                    DropdownMenuItem(value: 'supplement', child: Text('Supplement')),
                    DropdownMenuItem(value: 'medical_device', child: Text('Medical Device')),
                  ],
                  onChanged: (v) => setState(() => category = v ?? 'otc'),
                ),
                SwitchListTile(
                  activeThumbColor: AppColors.navy,
                  title: const Text('Requires Prescription'),
                  value: prescriptionRequired,
                  onChanged: (v) => setState(() => prescriptionRequired = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
              onPressed: () async {
                await ref.read(adminRepositoryProvider).addProduct(
                      name: nameController.text.trim(),
                      category: category,
                      prescriptionRequired: prescriptionRequired,
                      price: double.tryParse(priceController.text) ?? 0,
                      stockQuantity: int.tryParse(stockController.text) ?? 0,
                    );
                ref.invalidate(allProductsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
