import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client
        .from('orders')
        .select('*, order_items(*, products(name))')
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
