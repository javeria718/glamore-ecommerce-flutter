import 'package:ecom_app/Model/order_model.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderHistoryItem {
  const OrderHistoryItem({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.shippingFee,
    required this.paymentMethod,
    required this.itemsCount,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.city,
    required this.country,
  });

  final String id;
  final DateTime createdAt;
  final double totalAmount;
  final double shippingFee;
  final String paymentMethod;
  final int itemsCount;
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String country;
}

class OrderRepository {
  OrderRepository(this._client);

  final SupabaseClient _client;

  Future<void> placeOrder(OrderModel order) async {
    await _client.from('orders').insert({
      'user_id': order.userId,
      'email': order.email,
      'first_name': order.firstName,
      'last_name': order.lastName,
      'address': order.address,
      'phone': order.phone,
      'city': order.city,
      'country': order.country,
      'payment_method': order.paymentMethod,
      'shipping_fee': order.shippingFee,
      'total_amount': order.totalAmount,
      'items': order.items,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<OrderHistoryItem>> fetchUserOrders({required String userId}) async {
    final response = await _client
        .from('orders')
        .select(
            'id,created_at,total_amount,shipping_fee,payment_method,items,first_name,last_name,address,city,country')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map<OrderHistoryItem>((row) {
      final rawItems = row['items'];
      final itemsCount = rawItems is List ? rawItems.length : 0;

      final createdAtRaw = row['created_at']?.toString();
      final createdAt = createdAtRaw == null
          ? DateTime.now()
          : DateTime.tryParse(createdAtRaw) ?? DateTime.now();

      return OrderHistoryItem(
        id: row['id']?.toString() ?? '',
        createdAt: createdAt,
        totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0,
        shippingFee: (row['shipping_fee'] as num?)?.toDouble() ?? 0,
        paymentMethod: row['payment_method']?.toString() ?? 'Unknown',
        itemsCount: itemsCount,
        firstName: row['first_name']?.toString() ?? '',
        lastName: row['last_name']?.toString() ?? '',
        address: row['address']?.toString() ?? '',
        city: row['city']?.toString() ?? '',
        country: row['country']?.toString() ?? '',
      );
    }).toList();
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(supabaseClientProvider));
});
