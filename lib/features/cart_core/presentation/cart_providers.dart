import 'package:ecom_app/Model/cartModel';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cart_repository.dart';

class CartState {
  const CartState({required this.items, required this.isLoading});

  final List<CartItemModel> items;
  final bool isLoading;

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + (item.productPrice * item.numberOfItems));

  CartState copyWith({List<CartItemModel>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ref.watch(supabaseClientProvider));
});

class CartController extends StateNotifier<AsyncValue<CartState>> {
  CartController(this._repo)
      : super(const AsyncValue.data(CartState(items: <CartItemModel>[], isLoading: true))) {
    load();
  }

  final CartRepository _repo;

  Future<void> load() async {
    final current = state.value ?? const CartState(items: <CartItemModel>[], isLoading: true);
    state = AsyncValue.data(current.copyWith(isLoading: true));
    try {
      final items = await _repo.loadCart();
      state = AsyncValue.data(CartState(items: items, isLoading: false));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(CartItemModel item) async {
    final current = state.value ?? const CartState(items: <CartItemModel>[], isLoading: false);

    final updatedLocal = _optimisticAdd(current.items, item);
    state = AsyncValue.data(CartState(items: updatedLocal, isLoading: false));

    try {
      final remote = await _repo.addItem(item);
      state = AsyncValue.data(CartState(items: remote, isLoading: false));
    } catch (e, st) {
      state = AsyncValue.data(current);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> increment(String productName) async {
    await _run(() => _repo.increment(productName));
  }

  Future<void> decrement(String productName) async {
    await _run(() => _repo.decrement(productName));
  }

  Future<void> remove(String productName) async {
    await _run(() => _repo.remove(productName));
  }

  Future<void> clear() async {
    try {
      await _repo.clear();
      state = const AsyncValue.data(CartState(items: <CartItemModel>[], isLoading: false));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _run(Future<List<CartItemModel>> Function() action) async {
    try {
      final items = await action();
      state = AsyncValue.data(CartState(items: items, isLoading: false));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<CartItemModel> _optimisticAdd(List<CartItemModel> items, CartItemModel item) {
    final copy = <CartItemModel>[...items];
    final index = copy.indexWhere((element) => element.productName == item.productName);

    if (index == -1) {
      copy.add(item);
      return copy;
    }

    final existing = copy[index];
    copy[index] = CartItemModel(
      productName: existing.productName,
      customerName: existing.customerName,
      productPrice: existing.productPrice,
      numberOfItems: existing.numberOfItems + item.numberOfItems,
      productImage: existing.productImage,
    );
    return copy;
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, AsyncValue<CartState>>((ref) {
  return CartController(ref.watch(cartRepositoryProvider));
});
