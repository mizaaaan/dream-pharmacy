import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/order_review_repository.dart';

final orderReviewRepositoryProvider = Provider((ref) => OrderReviewRepository());

final pendingOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(orderReviewRepositoryProvider).fetchPendingOrders();
});

enum ReviewAction { approve, reject }

class OrderReviewNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> reviewOrder({
    required String orderId,
    required ReviewAction action,
    String? rejectionReason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(orderReviewRepositoryProvider);
      if (action == ReviewAction.approve) {
        await repo.approveOrder(orderId);
      } else {
        await repo.rejectOrder(orderId, rejectionReason ?? 'Prescription invalid');
      }
    });
  }
}

final orderReviewProvider = AsyncNotifierProvider<OrderReviewNotifier, void>(OrderReviewNotifier.new);
