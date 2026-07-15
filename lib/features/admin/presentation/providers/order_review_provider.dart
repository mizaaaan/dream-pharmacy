import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ReviewAction { approve, reject }

class OrderReviewNotifier extends AsyncNotifier<void> {
  final _client = Supabase.instance.client;

  @override
  FutureOr<void> build() {
    // no initial async work needed
  }

  Future<void> reviewOrder({
    required String orderId,
    required ReviewAction action,
    String? rejectionReason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final adminId = _client.auth.currentUser!.id;
      await _client.from('orders').update({
        'status': action == ReviewAction.approve ? 'approved' : 'rejected',
        'admin_reviewed_by': adminId,
        'admin_reviewed_at': DateTime.now().toIso8601String(),
        if (action == ReviewAction.reject)
          'rejection_reason': rejectionReason ?? 'Prescription invalid',
      }).eq('id', orderId);
    });
  }
}

final orderReviewProvider =
    AsyncNotifierProvider<OrderReviewNotifier, void>(OrderReviewNotifier.new);

final pendingOrdersProvider = StreamProvider.autoDispose((ref) {
  final client = Supabase.instance.client;
  return client
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('status', 'pending_review')
      .order('created_at');
});
