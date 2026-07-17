import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_history_repository.dart';

const myOrdersPageSize = 15;

final orderHistoryRepositoryProvider = Provider((ref) => OrderHistoryRepository());

class MyOrdersNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _page = 0;
    _hasMore = true;
    final orders = await ref.watch(orderHistoryRepositoryProvider).fetchMyOrders(
          page: 0,
          pageSize: myOrdersPageSize,
        );
    if (orders.length < myOrdersPageSize) _hasMore = false;
    return orders;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value ?? [];
    _loadingMore = true;
    final nextPage = _page + 1;
    try {
      final more = await ref.read(orderHistoryRepositoryProvider).fetchMyOrders(
            page: nextPage,
            pageSize: myOrdersPageSize,
          );
      _page = nextPage;
      if (more.length < myOrdersPageSize) _hasMore = false;
      state = AsyncData([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}

final myOrdersProvider =
    AsyncNotifierProvider<MyOrdersNotifier, List<Map<String, dynamic>>>(MyOrdersNotifier.new);
