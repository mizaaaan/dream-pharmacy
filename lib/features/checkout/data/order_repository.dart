import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cart/domain/cart_item.dart';

class OrderRepository {
  final _client = Supabase.instance.client;

  Future<String> createOrder({
    required List<CartItem> items,
    required String deliveryAddress,
    required bool requiresPrescriptionReview,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final total = items.fold(0.0, (sum, item) => sum + item.subtotal);

    final orderData = await _client.from('orders').insert({
      'customer_id': userId,
      'status': 'pending_review',
      'total_amount': total,
      'delivery_address': deliveryAddress,
      'requires_prescription_review': requiresPrescriptionReview,
    }).select().single();

    final orderId = orderData['id'] as String;

    final orderItems = items.map((item) => {
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'unit_price': item.product.price,
        }).toList();

    await _client.from('order_items').insert(orderItems);

    return orderId;
  }
}
