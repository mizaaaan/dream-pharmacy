import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/order_review_repository.dart';

const pendingOrdersPageSize = 15;

final orderReviewRepositoryProvider = Provider((ref) => OrderReviewRepository());

class PendingOrdersNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _page = 0;
    _hasMore = true;
    final orders = await ref.watch(orderReviewRepositoryProvider).fetchPendingOrders(
          page: 0,
          pageSize: pendingOrdersPageSize,
        );
    if (orders.length < pendingOrdersPageSize) _hasMore = false;
    return orders;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value ?? [];
    _loadingMore = true;
    final nextPage = _page + 1;
    try {
      final more = await ref.read(orderReviewRepositoryProvider).fetchPendingOrders(
            page: nextPage,
            pageSize: pendingOrdersPageSize,
          );
      _page = nextPage;
      if (more.length < pendingOrdersPageSize) _hasMore = false;
      state = AsyncData([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}

final pendingOrdersProvider =
    AsyncNotifierProvider<PendingOrdersNotifier, List<Map<String, dynamic>>>(PendingOrdersNotifier.new);

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
