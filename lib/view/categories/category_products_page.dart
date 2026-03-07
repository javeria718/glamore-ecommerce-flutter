import 'package:ecom_app/features/catalog_core/data/catalog_product.dart';
import 'package:ecom_app/features/catalog_core/presentation/catalog_providers.dart';
import 'package:ecom_app/auth/frosted_glass.dart';
import 'package:ecom_app/widgets/appbar_category.dart';
import 'package:ecom_app/widgets/drawer.dart';
import 'package:ecom_app/widgets/products_con.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryProductsPage extends ConsumerStatefulWidget {
  const CategoryProductsPage({
    super.key,
    required this.slug,
    required this.title,
    required this.searchHint,
  });

  final String slug;
  final String title;
  final String searchHint;

  @override
  ConsumerState<CategoryProductsPage> createState() =>
      _CategoryProductsPageState();
}

class _CategoryProductsPageState extends ConsumerState<CategoryProductsPage> {
  late final TextEditingController _searchController;
  _SortOption _sortOption = _SortOption.recommended;
  _PriceFilter _priceFilter = _PriceFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(categoryProductsProvider(widget.slug));
    final favorites = ref.watch(favoriteProductIdsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: Drawer(child: appDrawer(context)),
      appBar: categoryBar(context, widget.title, Icons.shopping_cart_outlined),
      body: frostyLightBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final maxContentWidth = width >= 1500
                ? 1320.0
                : width >= 1200
                    ? 1120.0
                    : width >= 900
                        ? 900.0
                        : width;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _CategoryControlsCard(
                        controller: _searchController,
                        productLabel: widget.title,
                        sortOption: _sortOption,
                        priceFilter: _priceFilter,
                        onChanged: (value) {
                          ref
                              .read(categorySearchQueryProvider(widget.slug)
                                  .notifier)
                              .state = value;
                        },
                        onSortChanged: (value) {
                          setState(() => _sortOption = value);
                        },
                        onFilterChanged: (value) {
                          setState(() => _priceFilter = value);
                        },
                        onClearFilters: () {
                          _searchController.clear();
                          ref
                              .read(categorySearchQueryProvider(widget.slug)
                                  .notifier)
                              .state = '';
                          setState(() {
                            _sortOption = _SortOption.recommended;
                            _priceFilter = _PriceFilter.all;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                        child: productsAsync.when(
                          data: (items) {
                            final viewItems = _prepareItems(items);
                            return _CategoryProductsGrid(
                              items: viewItems,
                              favorites: favorites,
                              onFavoriteTap: (id) => ref
                                  .read(favoriteProductIdsProvider.notifier)
                                  .toggle(id),
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, _) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Could not load products: $error'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<CatalogProduct> _prepareItems(List<CatalogProduct> items) {
    final filtered = switch (_priceFilter) {
      _PriceFilter.all => items,
      _PriceFilter.under25 => items.where((item) => item.price < 25).toList(),
      _PriceFilter.between25And50 =>
        items.where((item) => item.price >= 25 && item.price <= 50).toList(),
      _PriceFilter.between50And100 =>
        items.where((item) => item.price > 50 && item.price <= 100).toList(),
      _PriceFilter.above100 => items.where((item) => item.price > 100).toList(),
    };

    final sorted = [...filtered];
    switch (_sortOption) {
      case _SortOption.recommended:
        break;
      case _SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case _SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case _SortOption.nameAToZ:
        sorted.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return sorted;
  }
}

int _responsiveColumns(double width) {
  if (width < 600) return 2;
  final columns = (width / 230).floor();
  return columns.clamp(2, 6);
}

class _CategoryProductsGrid extends StatelessWidget {
  const _CategoryProductsGrid({
    required this.items,
    required this.favorites,
    required this.onFavoriteTap,
  });

  final List<CatalogProduct> items;
  final Set<String> favorites;
  final ValueChanged<String> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No products found'),
      );
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
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

enum _SortOption {
  recommended('Recommended'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  nameAToZ('Name: A to Z');

  const _SortOption(this.label);
  final String label;
}

enum _PriceFilter {
  all('All Prices'),
  under25('Under \$25'),
  between25And50('\$25-\$50'),
  between50And100('\$50-\$100'),
  above100('Above \$100');

  const _PriceFilter(this.label);
  final String label;
}

class _CategoryControlsCard extends StatelessWidget {
  const _CategoryControlsCard({
    required this.controller,
    required this.productLabel,
    required this.sortOption,
    required this.priceFilter,
    required this.onChanged,
    required this.onSortChanged,
    required this.onFilterChanged,
    required this.onClearFilters,
  });

  final TextEditingController controller;
  final String productLabel;
  final _SortOption sortOption;
  final _PriceFilter priceFilter;
  final ValueChanged<String> onChanged;
  final ValueChanged<_SortOption> onSortChanged;
  final ValueChanged<_PriceFilter> onFilterChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              const Color(0xFFE8F8F5).withValues(alpha: 0.92),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search $productLabel',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: controller.text.isEmpty
                        ? const Icon(Icons.tune_rounded)
                        : IconButton(
                            onPressed: onClearFilters,
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.95),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 1.6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (compact)
                  Column(
                    children: [
                      _SortDropdown(
                          value: sortOption, onChanged: onSortChanged),
                      const SizedBox(height: 8),
                      _FilterDropdown(
                          value: priceFilter, onChanged: onFilterChanged),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: onClearFilters,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _SortDropdown(
                            value: sortOption, onChanged: onSortChanged),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown(
                            value: priceFilter, onChanged: onFilterChanged),
                      ),
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _SortOption value;
  final ValueChanged<_SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_SortOption>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Sort by',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
        ),
      ),
      items: _SortOption.values
          .map(
            (option) => DropdownMenuItem<_SortOption>(
              value: option,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.value, required this.onChanged});

  final _PriceFilter value;
  final ValueChanged<_PriceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_PriceFilter>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Price range',
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.95),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.withValues(alpha: 0.2)),
        ),
      ),
      items: _PriceFilter.values
          .map(
            (option) => DropdownMenuItem<_PriceFilter>(
              value: option,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
