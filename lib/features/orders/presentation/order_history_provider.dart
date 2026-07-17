import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_history_repository.dart';

final orderHistoryRepositoryProvider = Provider((ref) => OrderHistoryRepository());

final myOrdersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(orderHistoryRepositoryProvider).fetchMyOrders();
});
