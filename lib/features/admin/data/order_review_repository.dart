import 'package:supabase_flutter/supabase_flutter.dart';

class OrderReviewRepository {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPendingOrders() async {
    final data = await _client
        .from('orders')
        .select('*, users!orders_customer_id_fkey(full_name, phone), order_items(*, products(name)), prescriptions(*)')
        .eq('status', 'pending_review')
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<String> getPrescriptionSignedUrl(String filePath) async {
    return _client.storage.from('prescriptions').createSignedUrl(filePath, 3600);
  }

  Future<void> approveOrder(String orderId) async {
    final adminId = _client.auth.currentUser!.id;
    await _client.from('orders').update({
      'status': 'approved',
      'admin_reviewed_by': adminId,
      'admin_reviewed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    final adminId = _client.auth.currentUser!.id;
    await _client.from('orders').update({
      'status': 'rejected',
      'admin_reviewed_by': adminId,
      'admin_reviewed_at': DateTime.now().toIso8601String(),
      'rejection_reason': reason,
    }).eq('id', orderId);
  }
}
