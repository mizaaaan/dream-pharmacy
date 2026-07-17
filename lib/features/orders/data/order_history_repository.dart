import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMyOrders({int page = 0, int pageSize = 15}) async {
    final userId = _client.auth.currentUser!.id;
    final from = page * pageSize;
    final to = from + pageSize - 1;
    final data = await _client
        .from('orders')
        .select('*, order_items(*, products(name))')
        .eq('customer_id', userId)
        .order('created_at', ascending: false)
        .range(from, to);
    return List<Map<String, dynamic>>.from(data);
  }
}
