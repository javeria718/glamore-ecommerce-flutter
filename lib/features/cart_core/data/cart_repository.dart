import 'package:ecom_app/Model/cartModel';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepository {
  CartRepository(this._client);

  final SupabaseClient _client;
  final Map<String, CartItemModel> _localItems = <String, CartItemModel>{};

  String get _uid => _client.auth.currentUser?.id ?? '';

  static const Map<String, String> _imageByProductName = <String, String>{
    "Girl's Watch": 'assets/images/w3.jpeg',
    'Blue Long Shirt': 'assets/images/5555.jpg',
    'Black Modern Suit': 'assets/images/westerndress.jpg',
    'Dull Gold Suit': 'assets/images/983.jpg',
    'Swift Bag': 'assets/images/swiftbag.jpg',
    'Silver Watch': 'assets/images/w8.jpeg',
    'White Shoes': 'assets/images/white.jpg',
    'Smart Watch': 'assets/images/w1.jpeg',
    'Classic Watch': 'assets/images/w2.jpeg',
    'Man Watch': 'assets/images/w3.jpeg',
    'Hand Bag': 'assets/images/iv.jpg',
    'Gold Bracelet': 'assets/images/j1.jpg',
    'Platinum Earrings': 'assets/images/j4.jpg',
    'Butterfly Necklace': 'assets/images/j6.jpg',
    'Necklace': 'assets/images/j8.jpg',
    'Set of Rings': 'assets/images/j3.jpg',
    'Golden Jhumka': 'assets/images/j5.jpg',
    'Bracelet': 'assets/images/j2.jpg',
    'Nike Shoes': 'assets/images/s4.jpeg',
    'Nike Shoes S4': 'assets/images/s4.jpeg',
    'Nike Shoes S5': 'assets/images/s5.jpeg',
    'Nike Shoes S6': 'assets/images/s6.jpeg',
    'Nike Shoes S7': 'assets/images/s7.jpeg',
    'Nike Shoes S8': 'assets/images/s8.jpeg',
  };

  String _guessImage(String productName) {
    final direct = _imageByProductName[productName];
    if (direct != null) return direct;

    final normalized = productName.toLowerCase();
    if (normalized.contains('shoe')) return 'assets/images/s4.jpeg';
    if (normalized.contains('watch')) return 'assets/images/w1.jpeg';
    if (normalized.contains('bag')) return 'assets/images/iv.jpg';
    if (normalized.contains('jewel') ||
        normalized.contains('ring') ||
        normalized.contains('necklace') ||
        normalized.contains('bracelet') ||
        normalized.contains('earring')) {
      return 'assets/images/j3.jpg';
    }
    if (normalized.contains('dress') || normalized.contains('suit')) {
      return 'assets/images/213.jpg';
    }
    return 'assets/images/iv.jpg';
  }

  bool _isMissingTableError(Object error) {
    if (error is! PostgrestException) return false;
    return error.code == 'PGRST205' || error.code == '42P01';
  }

  List<CartItemModel> _localSnapshot() {
    return _localItems.values.toList(growable: false);
  }

  List<CartItemModel> _localAdd(CartItemModel item) {
    final existing = _localItems[item.productName];
    _localItems[item.productName] = existing == null
        ? item
        : CartItemModel(
            productName: existing.productName,
            customerName: existing.customerName,
            productPrice: existing.productPrice,
            numberOfItems: existing.numberOfItems + item.numberOfItems,
            productImage: existing.productImage,
          );
    return _localSnapshot();
  }

  List<CartItemModel> _localIncrement(String productName) {
    final existing = _localItems[productName];
    if (existing == null) return _localSnapshot();

    _localItems[productName] = CartItemModel(
      productName: existing.productName,
      customerName: existing.customerName,
      productPrice: existing.productPrice,
      numberOfItems: existing.numberOfItems + 1,
      productImage: existing.productImage,
    );
    return _localSnapshot();
  }

  List<CartItemModel> _localDecrement(String productName) {
    final existing = _localItems[productName];
    if (existing == null) return _localSnapshot();

    if (existing.numberOfItems <= 1) {
      _localItems.remove(productName);
    } else {
      _localItems[productName] = CartItemModel(
        productName: existing.productName,
        customerName: existing.customerName,
        productPrice: existing.productPrice,
        numberOfItems: existing.numberOfItems - 1,
        productImage: existing.productImage,
      );
    }
    return _localSnapshot();
  }

  List<CartItemModel> _localRemove(String productName) {
    _localItems.remove(productName);
    return _localSnapshot();
  }

  Future<String> _activeCartId() async {
    if (_uid.isEmpty) {
      throw Exception('Please login first');
    }

    final existing = await _client
        .from('carts')
        .select('id')
        .eq('user_id', _uid)
        .eq('status', 'active')
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final created = await _client
        .from('carts')
        .insert({'user_id': _uid, 'status': 'active'})
        .select('id')
        .single();

    return created['id'] as String;
  }

  Future<List<CartItemModel>> loadCart() async {
    if (_uid.isEmpty) {
      return const <CartItemModel>[];
    }

    try {
      final cart = await _client
          .from('carts')
          .select('id')
          .eq('user_id', _uid)
          .eq('status', 'active')
          .maybeSingle();

      if (cart == null) {
        return _localSnapshot();
      }

      List rows;
      try {
        rows = await _client
            .from('cart_items')
            .select(
                'product_name,customer_name,unit_price,quantity,product_image')
            .eq('cart_id', cart['id']);
      } on PostgrestException {
        rows = await _client
            .from('cart_items')
            .select('product_name,customer_name,unit_price,quantity')
            .eq('cart_id', cart['id']);
      }

      final items = (rows)
          .map(
            (row) => CartItemModel(
              productName: (row['product_name'] ?? '') as String,
              customerName: (row['customer_name'] ?? '') as String,
              productPrice: ((row['unit_price'] ?? 0) as num).toDouble(),
              numberOfItems: (row['quantity'] ?? 0) as int,
              productImage: (row['product_image'] ??
                  _guessImage((row['product_name'] ?? '') as String)) as String,
            ),
          )
          .toList(growable: false);

      _localItems
        ..clear()
        ..addEntries(items.map((e) => MapEntry(e.productName, e)));

      return items;
    } catch (e) {
      if (_isMissingTableError(e)) {
        return _localSnapshot();
      }
      rethrow;
    }
  }

  Future<List<CartItemModel>> addItem(CartItemModel item) async {
    try {
      final cartId = await _activeCartId();

      Map<String, dynamic>? existing;
      var supportsImageColumn = true;
      try {
        existing = await _client
            .from('cart_items')
            .select('id,quantity,product_image')
            .eq('cart_id', cartId)
            .eq('product_name', item.productName)
            .maybeSingle();
      } on PostgrestException {
        supportsImageColumn = false;
        existing = await _client
            .from('cart_items')
            .select('id,quantity')
            .eq('cart_id', cartId)
            .eq('product_name', item.productName)
            .maybeSingle();
      }

      if (existing == null) {
        try {
          await _client.from('cart_items').insert({
            'cart_id': cartId,
            'product_name': item.productName,
            'customer_name': item.customerName,
            'unit_price': item.productPrice,
            'quantity': item.numberOfItems,
            'product_image': item.productImage,
          });
        } on PostgrestException {
          await _client.from('cart_items').insert({
            'cart_id': cartId,
            'product_name': item.productName,
            'customer_name': item.customerName,
            'unit_price': item.productPrice,
            'quantity': item.numberOfItems,
          });
        }
      } else {
        final nextQty = (existing['quantity'] as int) + item.numberOfItems;
        final updates = <String, dynamic>{'quantity': nextQty};
        final existingImage = supportsImageColumn
            ? (existing['product_image'] as String?)?.trim()
            : null;
        if (supportsImageColumn &&
            (existingImage == null || existingImage.isEmpty)) {
          updates['product_image'] = item.productImage;
        }
        await _client
            .from('cart_items')
            .update(updates)
            .eq('id', existing['id']);
      }

      return loadCart();
    } catch (e) {
      if (_isMissingTableError(e)) {
        return _localAdd(item);
      }
      rethrow;
    }
  }

  Future<List<CartItemModel>> increment(String productName) async {
    try {
      final cartId = await _activeCartId();
      final existing = await _client
          .from('cart_items')
          .select('id,quantity')
          .eq('cart_id', cartId)
          .eq('product_name', productName)
          .single();

      await _client
          .from('cart_items')
          .update({'quantity': (existing['quantity'] as int) + 1}).eq(
              'id', existing['id']);

      return loadCart();
    } catch (e) {
      if (_isMissingTableError(e)) {
        return _localIncrement(productName);
      }
      rethrow;
    }
  }

  Future<List<CartItemModel>> decrement(String productName) async {
    try {
      final cartId = await _activeCartId();
      final existing = await _client
          .from('cart_items')
          .select('id,quantity')
          .eq('cart_id', cartId)
          .eq('product_name', productName)
          .single();

      final current = existing['quantity'] as int;
      if (current <= 1) {
        await _client.from('cart_items').delete().eq('id', existing['id']);
      } else {
        await _client
            .from('cart_items')
            .update({'quantity': current - 1}).eq('id', existing['id']);
      }

      return loadCart();
    } catch (e) {
      if (_isMissingTableError(e)) {
        return _localDecrement(productName);
      }
      rethrow;
    }
  }

  Future<List<CartItemModel>> remove(String productName) async {
    try {
      final cartId = await _activeCartId();
      await _client
          .from('cart_items')
          .delete()
          .eq('cart_id', cartId)
          .eq('product_name', productName);

      return loadCart();
    } catch (e) {
      if (_isMissingTableError(e)) {
        return _localRemove(productName);
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    _localItems.clear();
    if (_uid.isEmpty) return;

    try {
      final cart = await _client
          .from('carts')
          .select('id')
          .eq('user_id', _uid)
          .eq('status', 'active')
          .maybeSingle();

      if (cart == null) {
        return;
      }

      await _client.from('cart_items').delete().eq('cart_id', cart['id']);
    } catch (e) {
      if (_isMissingTableError(e)) return;
      rethrow;
    }
  }
}
