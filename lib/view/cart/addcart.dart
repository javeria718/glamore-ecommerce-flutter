import 'package:ecom_app/Model/cartModel';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/cart_core/presentation/cart_providers.dart';
import 'package:ecom_app/view/cart/checkout.dart';
import 'package:ecom_app/view/home.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:ecom_app/widgets/cartitems.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddToCart extends ConsumerStatefulWidget {
  const AddToCart({super.key});

  @override
  ConsumerState<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends ConsumerState<AddToCart> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: frostedTealAppBar(
        context: context,
        title: 'Your Cart',
        onLeadingPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
      ),
      bottomNavigationBar: cartAsync.when(
        data: (state) => _CartBottomBar(
          totalPrice: state.totalPrice,
          itemCount: state.items.length,
          onCheckout: state.items.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutPage()),
                  );
                },
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      body: frostyLightBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final maxContentWidth = width >= 1500
                  ? 1200.0
                  : width >= 1200
                      ? 1040.0
                      : width >= 900
                          ? 880.0
                          : width;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: cartAsync.when(
                    data: (state) {
                      final List<CartItemModel> cartItems = state.items;
                      if (cartItems.isEmpty) {
                        return Center(
                          child: FrostedGlassCard(
                            maxWidth: 360,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.teal,
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Your cart is empty',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF184542),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add products to see them here.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withValues(alpha: 0.60),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(4, 10, 4, 118),
                        itemCount: cartItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = cartItems[index];
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  const _CartBottomBar({
    required this.totalPrice,
    required this.itemCount,
    required this.onCheckout,
  });

  final double totalPrice;
  final int itemCount;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: SizedBox(
        height: 106,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth >= 1200
                ? 980.0
                : constraints.maxWidth >= 900
                    ? 860.0
                    : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.90),
                          const Color(0xFFE8F8F5).withValues(alpha: 0.84),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.90)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$itemCount item${itemCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.58),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A3F3C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.teal,
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
                              minimumSize: const Size(0, 42),
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
