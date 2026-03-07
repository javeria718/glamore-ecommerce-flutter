import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:ecom_app/features/order_core/data/order_repository.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(supabaseClientProvider).auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(context: context, title: 'Order History'),
      body: frostyLightBackground(
        child: SafeArea(
          top: false,
          child: user == null
              ? const Center(child: Text('Please login to view your orders.'))
              : FutureBuilder<List<OrderHistoryItem>>(
                  future: ref.read(orderRepositoryProvider).fetchUserOrders(userId: user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Could not load orders: ${snapshot.error}'));
                    }

                    final orders = snapshot.data ?? const <OrderHistoryItem>[];
                    if (orders.isEmpty) {
                      return Center(
                        child: FrostedGlassCard(
                          maxWidth: 350,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_outlined, color: Colors.teal, size: 44),
                              const SizedBox(height: 10),
                              const Text(
                                'No orders yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B4542),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Placed orders will appear here.',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.56),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final item = orders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.70),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Order #${item.id.substring(0, item.id.length > 8 ? 8 : item.id.length)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A3F3C),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(item.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withValues(alpha: 0.60),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${item.firstName} ${item.lastName} | ${item.itemsCount} item(s)',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.68),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.address}, ${item.city}, ${item.country}',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.64),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Payment: ${item.paymentMethod}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${item.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
