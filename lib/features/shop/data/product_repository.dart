import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/product.dart';

class ProductRepository {
  final _client = Supabase.instance.client;

  Future<List<Product>> fetchProducts({
    String? category,
    String? searchQuery,
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = _client.from('products').select().eq('is_active', true);
    if (category != null && category != 'all') {
      query = query.eq('category', category);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }
    final from = page * pageSize;
    final to = from + pageSize - 1;
    final data = await query.order('name').range(from, to);
    return (data as List).map((m) => Product.fromMap(m)).toList();
  }
}
