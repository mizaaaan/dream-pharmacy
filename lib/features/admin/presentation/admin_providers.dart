import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../../shop/domain/product.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

final allProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  return ref.watch(adminRepositoryProvider).fetchAllProducts();
});
