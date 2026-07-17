import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shop/domain/product.dart';

class AdminRepository {
  final _client = Supabase.instance.client;

  Future<List<Product>> fetchAllProducts() async {
    final data = await _client.from('products').select().order('name');
    return (data as List).map((m) => Product.fromMap(m)).toList();
  }

  Future<void> addProduct({
    required String name,
    String? genericName,
    String? description,
    required String category,
    required bool prescriptionRequired,
    required double price,
    required int stockQuantity,
    String? dosageForm,
    String? strength,
    String? manufacturer,
  }) async {
    await _client.from('products').insert({
      'name': name,
      'generic_name': genericName,
      'description': description,
      'category': category,
      'prescription_required': prescriptionRequired,
      'price': price,
      'stock_quantity': stockQuantity,
      'dosage_form': dosageForm,
      'strength': strength,
      'manufacturer': manufacturer,
    });
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _client.from('products').update({
      'stock_quantity': newStock,
    }).eq('id', productId);
  }

  Future<void> toggleActive(String productId, bool isActive) async {
    await _client.from('products').update({
      'is_active': isActive,
    }).eq('id', productId);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }
  Future<void> inviteAdmin(String email) async {
    await _client.from('admin_invites').insert({
      'email': email,
      'invited_by': _client.auth.currentUser!.id,
    });
  }
}
