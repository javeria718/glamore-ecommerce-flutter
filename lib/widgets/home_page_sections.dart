import 'dart:ui';

import 'package:ecom_app/Model/cartModel';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/features/cart_core/presentation/cart_providers.dart';
import 'package:ecom_app/features/catalog_core/data/catalog_product.dart';
import 'package:ecom_app/features/catalog_core/presentation/catalog_providers.dart';
import 'package:ecom_app/view/cart/checkout.dart';
import 'package:ecom_app/view/cart/product_dialog.dart';
import 'package:ecom_app/view/categories/bags.dart';
import 'package:ecom_app/view/categories/clothes.dart';
import 'package:ecom_app/view/categories/jewelery.dart';
import 'package:ecom_app/view/categories/shoes.dart';
import 'package:ecom_app/view/categories/watches.dart';
import 'package:ecom_app/widgets/cartitems.dart';
import 'package:ecom_app/widgets/custom_categories.dart';
import 'package:ecom_app/widgets/products_con.dart';
import 'package:ecom_app/widgets/searchcontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTabContent extends ConsumerWidget {
  const HomeTabContent({
    super.key,
    required this.searchController,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final TextEditingController searchController;
  final Set<String> favorites;
  final ValueChanged<String> onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryInfo = <Map<String, dynamic>>[
      {
        'image': 'assets/images/213.jpg',
        'title': 'Dresses',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Clothes()),
            ),
      },
      {
        'image': 'assets/images/shoeee.jpeg',
        'title': 'Shoes',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Shoes()),
            ),
      },
      {
        'image': 'assets/images/w1.jpeg',
        'title': 'Watches',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Watches()),
            ),
      },
      {
        'image': 'assets/images/bags.png',
        'title': 'Bags',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Bags()),
            ),
      },
      {
        'image': 'assets/images/j3.jpg',
        'title': 'Jewellery',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Jewelery()),
            ),
      },
    ];

    final productsAsync = ref.watch(homeProductsProvider);
    return frostyLightBackground(
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = _maxContentWidth(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    CustomSearchBar(
                      controller: searchController,
                      onChanged: (value) => ref
                          .read(homeSearchQueryProvider.notifier)
                          .state = value,
                      hintText: 'Search Products',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: SizedBox(
                        height: 118,
                        child: LayoutBuilder(
                          builder: (context, rowConstraints) {
                            const estimatedItemWidth = 110.0;
                            final needsScroll =
                                categoryInfo.length * estimatedItemWidth >
                                    rowConstraints.maxWidth;

                            if (needsScroll) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: categoryInfo.length,
                                itemBuilder: (context, index) {
                                  final item = categoryInfo[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: CustomCategories(
                                      image: item['image'] as String,
                                      title: item['title'] as String,
                                      onPressed: item['onTap'] as VoidCallback,
                                    ),
                                  );
                                },
                              );
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: categoryInfo.map((item) {
                                  return CustomCategories(
                                    image: item['image'] as String,
                                    title: item['title'] as String,
                                    onPressed: item['onTap'] as VoidCallback,
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 52,
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.withValues(alpha: 0.92),
                            const Color(0xFF0A8E86).withValues(alpha: 0.88),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30)),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: Text(
                          'Trending Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: productsAsync.when(
                        data: (items) => _ProductsGrid(
                          products: items,
                          favorites: favorites,
                          onFavoriteTap: onFavoriteTap,
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                            child: Text('Could not load products: $error')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OffersTabContent extends ConsumerWidget {
  const OffersTabContent({
    super.key,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final Set<String> favorites;
  final ValueChanged<String> onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeProductsProvider);
    return frostyLightBackground(
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = _maxContentWidth(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: productsAsync.when(
                  data: (items) => ListView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    children: items.take(14).map((item) {
                      final id = item.title;
                      final isFavorite = favorites.contains(id);
                      return _PromoTile(
                        item: item,
                        favorite: isFavorite,
                        discountLabel:
                            '${10 + (item.title.length % 4) * 5}% OFF',
                        onFavoriteTap: () => onFavoriteTap(id),
                      );
                    }).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Could not load offers: $error')),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FavoritesTabContent extends ConsumerWidget {
  const FavoritesTabContent({
    super.key,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final Set<String> favorites;
  final ValueChanged<String> onFavoriteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(homeProductsProvider);
    return frostyLightBackground(
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = _maxContentWidth(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: productsAsync.when(
                  data: (items) {
                    final filtered = items
                        .where((item) => favorites.contains(item.title))
                        .toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No favorites yet'));
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      children: filtered.map((item) {
                        return _PromoTile(
                          item: item,
                          favorite: true,
                          discountLabel: 'Saved',
                          onFavoriteTap: () => onFavoriteTap(item.title),
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Could not load favorites: $error')),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CartTabContent extends ConsumerWidget {
  const CartTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartControllerProvider);
    return frostyLightBackground(
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = _maxContentWidth(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: cartAsync.when(
                  data: (state) {
                    if (state.items.isEmpty) {
                      return const Center(child: Text('Your cart is empty'));
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final CartItemModel item = state.items[index];
                              return CartItems(
                                name: item.productName,
                                price: (item.productPrice * item.numberOfItems)
                                    .toStringAsFixed(2),
                                image: item.productImage,
                                quantity: item.numberOfItems,
                                onIncrement: () => ref
                                    .read(cartControllerProvider.notifier)
                                    .increment(item.productName),
                                onDecrement: () => ref
                                    .read(cartControllerProvider.notifier)
                                    .decrement(item.productName),
                                onDelete: () => ref
                                    .read(cartControllerProvider.notifier)
                                    .remove(item.productName),
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const Spacer(),
                                  Text(
                                      '\$${state.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.teal)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LayoutBuilder(
                                builder: (context, buttonConstraints) {
                                  final isWide = buttonConstraints.maxWidth >= 700;
                                  return Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: isWide ? 220 : double.infinity,
                                      child: FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            foregroundColor: Colors.white),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const CheckoutPage())),
                                        child: const Text('Proceed to Checkout'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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
    );
  }
}

class FrostedBottomNav extends StatelessWidget {
  const FrostedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <({IconData icon, IconData selected, String label})>[
    (icon: Icons.home_outlined, selected: Icons.home_rounded, label: 'Home'),
    (
      icon: Icons.local_offer_outlined,
      selected: Icons.local_offer,
      label: 'Offers'
    ),
    (
      icon: Icons.shopping_cart_outlined,
      selected: Icons.shopping_cart,
      label: 'Cart'
    ),
    (
      icon: Icons.favorite_border_rounded,
      selected: Icons.favorite_rounded,
      label: 'Favorite'
    ),
    (
      icon: Icons.settings_outlined,
      selected: Icons.settings,
      label: 'Settings'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
            ),
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = currentIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(selected ? item.selected : item.icon,
                            color: selected ? Colors.teal : Colors.black54),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? Colors.teal : Colors.black54,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  const _ProductsGrid({
    required this.products,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final List<CatalogProduct> products;
  final Set<String> favorites;
  final ValueChanged<String> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _responsiveColumns(constraints.maxWidth);
        final childAspectRatio = constraints.maxWidth < 600
            ? 0.70
            : constraints.maxWidth < 900
                ? 0.74
                : 0.80;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final item = products[index];
            return ProductInfo(
              link: item.image,
              title: item.title,
              price: item.formattedPrice,
              isFavorite: favorites.contains(item.title),
              onFavoriteTap: () => onFavoriteTap(item.title),
            );
          },
        );
      },
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({
    required this.item,
    required this.favorite,
    required this.discountLabel,
    required this.onFavoriteTap,
  });

  final CatalogProduct item;
  final bool favorite;
  final String discountLabel;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(item.image,
                width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(discountLabel,
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.formattedPrice,
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavoriteTap,
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ProductDialog(
                    image: item.image, title: item.title, price: item.price),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}

double _maxContentWidth(double width) {
  if (width >= 1500) return 1320.0;
  if (width >= 1200) return 1120.0;
  if (width >= 900) return 900.0;
  return width;
}

int _responsiveColumns(double width) {
  if (width < 600) return 2;
  final columns = (width / 230).floor();
  return columns.clamp(2, 6);
}
