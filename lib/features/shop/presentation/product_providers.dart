import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';

const productPageSize = 20;

final productRepositoryProvider = Provider((ref) => ProductRepository());

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';
  void set(String value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class ProductListNotifier extends AsyncNotifier<List<Product>> {
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  @override
  Future<List<Product>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    final search = ref.watch(searchQueryProvider);
    _page = 0;
    _hasMore = true;
    final products = await ref.watch(productRepositoryProvider).fetchProducts(
          category: category,
          searchQuery: search,
          page: 0,
          pageSize: productPageSize,
        );
    if (products.length < productPageSize) _hasMore = false;
    return products;
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final current = state.value ?? [];
    _loadingMore = true;
    final nextPage = _page + 1;
    try {
      final category = ref.read(selectedCategoryProvider);
      final search = ref.read(searchQueryProvider);
      final more = await ref.read(productRepositoryProvider).fetchProducts(
            category: category,
            searchQuery: search,
            page: nextPage,
            pageSize: productPageSize,
          );
      _page = nextPage;
      if (more.length < productPageSize) _hasMore = false;
      state = AsyncData([...current, ...more]);
    } finally {
      _loadingMore = false;
    }
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<Product>>(ProductListNotifier.new);
