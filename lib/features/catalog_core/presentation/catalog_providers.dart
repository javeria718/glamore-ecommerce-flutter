import 'package:ecom_app/features/catalog_core/data/catalog_product.dart';
import 'package:ecom_app/features/catalog_core/data/catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeSearchQueryProvider = StateProvider<String>((ref) => '');

final homeProductsProvider = FutureProvider.autoDispose<List<CatalogProduct>>((ref) {
  final query = ref.watch(homeSearchQueryProvider);
  return ref.watch(catalogRepositoryProvider).fetchHomeProducts(query: query);
});

final categorySearchQueryProvider = StateProvider.family<String, String>((ref, slug) => '');

final categoryProductsProvider =
    FutureProvider.autoDispose.family<List<CatalogProduct>, String>((ref, slug) {
  final query = ref.watch(categorySearchQueryProvider(slug));
  return ref.watch(catalogRepositoryProvider).fetchCategoryProducts(
        categorySlug: slug,
        query: query,
      );
});

class FavoriteProductsController extends StateNotifier<Set<String>> {
  FavoriteProductsController() : super(<String>{});

  void toggle(String productId) {
    final next = <String>{...state};
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    state = next;
  }
}

final favoriteProductIdsProvider =
    StateNotifierProvider<FavoriteProductsController, Set<String>>((ref) {
  return FavoriteProductsController();
});
