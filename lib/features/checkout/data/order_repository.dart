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

    final itemsPayload = items
        .map((item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
              'unit_price': item.product.price,
            })
        .toList();

    // place_order is a Postgres function that validates stock, creates the
    // order + order_items, and decrements stock atomically in one transaction.
    final orderId = await _client.rpc('place_order', params: {
      'p_customer_id': userId,
      'p_delivery_address': deliveryAddress,
      'p_requires_prescription_review': requiresPrescriptionReview,
      'p_items': itemsPayload,
    });

    return orderId as String;
  }
}
