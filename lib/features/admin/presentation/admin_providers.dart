import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../../shop/domain/product.dart';

const adminProductPageSize = 20;

final adminRepositoryProvider = Provider((ref) => AdminRepository());

class AllProductsNotifier extends AsyncNotifier<List<Product>> {
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  @override
  Future<List<Product>> build() async {
    _page = 0;
    _hasMore = true;
    final products = await ref.watch(adminRepositoryProvider).fetchAllProducts(
          page: 0,
          pageSize: adminProductPageSize,
        );
    if (products.length < adminProductPageSize) _hasMore = false;
    return products;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value ?? [];
    _loadingMore = true;
    final nextPage = _page + 1;
    try {
      final more = await ref.read(adminRepositoryProvider).fetchAllProducts(
            page: nextPage,
            pageSize: adminProductPageSize,
          );
      _page = nextPage;
      if (more.length < adminProductPageSize) _hasMore = false;
      state = AsyncData([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}

final allProductsProvider =
    AsyncNotifierProvider<AllProductsNotifier, List<Product>>(AllProductsNotifier.new);
