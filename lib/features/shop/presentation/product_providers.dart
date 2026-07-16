import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../domain/product.dart';

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

final productListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(searchQueryProvider);
  return ref.watch(productRepositoryProvider).fetchProducts(
        category: category,
        searchQuery: search,
      );
});
