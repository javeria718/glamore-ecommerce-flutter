import 'dart:ui';

import 'package:ecom_app/Model/cartModel';
import 'package:ecom_app/features/cart_core/presentation/cart_providers.dart';
import 'package:ecom_app/view/cart/checkout.dart';
import 'package:ecom_app/widgets/cartitems.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartSidePanel extends ConsumerStatefulWidget {
  const CartSidePanel({super.key});

  @override
  ConsumerState<CartSidePanel> createState() => _CartSidePanelState();
}

class _CartSidePanelState extends ConsumerState<CartSidePanel> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartControllerProvider);

    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.90),
                  const Color(0xFFE7F8F5).withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                left: BorderSide(color: Colors.white.withValues(alpha: 0.88)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(-6, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _panelHeader(context),
                Expanded(
                  child: cartAsync.when(
                    data: (state) {
                      final List<CartItemModel> items = state.items;
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withValues(alpha: 0.60),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 116),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return CartItems(
                            name: item.productName,
                            price: (item.productPrice * item.numberOfItems)
                                .toStringAsFixed(2),
                            image: item.productImage,
                            quantity: item.numberOfItems,
                            onIncrement: () async {
                              await ref
                                  .read(cartControllerProvider.notifier)
                                  .increment(item.productName);
                            },
                            onDecrement: () async {
                              await ref
                                  .read(cartControllerProvider.notifier)
                                  .decrement(item.productName);
                            },
                            onDelete: () async {
                              await ref
                                  .read(cartControllerProvider.notifier)
                                  .remove(item.productName);
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text(error.toString())),
                  ),
                ),
                cartAsync.when(
                  data: (state) => _bottomBar(
                    context: context,
                    total: state.totalPrice,
                    count: state.items.length,
                    onCheckout: state.items.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CheckoutPage()),
                            );
                          },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.teal.withValues(alpha: 0.14)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: Colors.teal),
          const SizedBox(width: 8),
          const Text(
            'Your Cart',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF144743),
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar({
    required BuildContext context,
    required double total,
    required int count,
    required VoidCallback? onCheckout,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.86)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '$count item${count == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text(
                'Total',
                style: TextStyle(
                  color: Color(0xFF1A3F3C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.teal,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onCheckout,
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
