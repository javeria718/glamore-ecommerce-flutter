import 'package:ecom_app/features/auth_core/presentation/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'catalog_product.dart';

class CatalogRepository {
  CatalogRepository(this._client);

  final SupabaseClient _client;

  static const List<CatalogProduct> _fallbackProducts = <CatalogProduct>[
    CatalogProduct(
        title: "Girl's Watch",
        image: 'assets/images/w3.jpeg',
        price: 15.0,
        categorySlug: 'watches'),
    CatalogProduct(
        title: 'Blue Long Shirt',
        image: 'assets/images/5555.jpg',
        price: 20.0,
        categorySlug: 'dresses'),
    CatalogProduct(
        title: 'Black Modern Suit',
        image: 'assets/images/westerndress.jpg',
        price: 22.0,
        categorySlug: 'dresses'),
    CatalogProduct(
        title: 'Dull Gold Suit',
        image: 'assets/images/983.jpg',
        price: 25.0,
        categorySlug: 'dresses'),
    CatalogProduct(
        title: 'Swift Bag',
        image: 'assets/images/swiftbag.jpg',
        price: 26.0,
        categorySlug: 'bags'),
    CatalogProduct(
        title: 'Silver Watch',
        image: 'assets/images/w8.jpeg',
        price: 29.0,
        categorySlug: 'watches'),
    CatalogProduct(
        title: 'White Shoes',
        image: 'assets/images/white.jpg',
        price: 40.0,
        categorySlug: 'shoes'),
  ];

  static const Map<String, List<CatalogProduct>> _categoryFallback =
      <String, List<CatalogProduct>>{
    'dresses': <CatalogProduct>[
      CatalogProduct(
          title: 'Blue Long Shirt',
          image: 'assets/images/5555.jpg',
          price: 20.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Black Modern Suit',
          image: 'assets/images/westerndress.jpg',
          price: 22.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Dull Gold Suit',
          image: 'assets/images/983.jpg',
          price: 25.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'White Shirt',
          image: 'assets/images/222.jpg',
          price: 29.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Red Top',
          image: 'assets/images/123.jpg',
          price: 40.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Light Purple Dress',
          image: 'assets/images/565.jpg',
          price: 10.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Blue Frock',
          image: 'assets/images/96.jpg',
          price: 23.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Jumpsuit',
          image: 'assets/images/6666.jpg',
          price: 20.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Formal Dress',
          image: 'assets/images/w2.jpg',
          price: 15.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Red Dress',
          image: 'assets/images/dress.webp',
          price: 20.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Pink Dress',
          image: 'assets/images/122.jpg',
          price: 24.0,
          categorySlug: 'dresses'),
      CatalogProduct(
          title: 'Black Dress',
          image: 'assets/images/213.jpg',
          price: 24.0,
          categorySlug: 'dresses'),
    ],
    'shoes': <CatalogProduct>[
      CatalogProduct(
          title: 'Moonlight Walk',
          image: 'assets/images/s4.jpeg',
          price: 15.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Luxe Walk',
          image: 'assets/images/s2.jpeg',
          price: 20.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Fairy Feet',
          image: 'assets/images/s1.jpeg',
          price: 15.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Blossom Walk',
          image: 'assets/images/s7.jpeg',
          price: 20.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Sweet Stride',
          image: 'assets/images/s3.jpeg',
          price: 20.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Vogue Walk',
          image: 'assets/images/s5.jpeg',
          price: 20.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Luxe Kick',
          image: 'assets/images/s8.jpeg',
          price: 20.0,
          categorySlug: 'shoes'),
      CatalogProduct(
          title: 'Glam Step',
          image: 'assets/images/s6.jpeg',
          price: 20.0,
          categorySlug: 'shoes'),
    ],
    'watches': <CatalogProduct>[
      CatalogProduct(
          title: 'Blossom Belle',
          image: 'assets/images/w1.jpeg',
          price: 15.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Dress Watch',
          image: 'assets/images/w2.jpeg',
          price: 20.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Glitter Drop',
          image: 'assets/images/w3.jpeg',
          price: 15.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Sugar Shine',
          image: 'assets/images/w4.jpeg',
          price: 20.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Angel Hour',
          image: 'assets/images/w5.jpeg',
          price: 20.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Starry Glow',
          image: 'assets/images/w6.jpeg',
          price: 20.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Bonito Watch',
          image: 'assets/images/w8.jpeg',
          price: 20.0,
          categorySlug: 'watches'),
      CatalogProduct(
          title: 'Sweet Sparkle',
          image: 'assets/images/w77.jpeg',
          price: 20.0,
          categorySlug: 'watches'),
    ],
    'bags': <CatalogProduct>[
      CatalogProduct(
          title: 'Luxe Loop',
          image: 'assets/images/i.jpg',
          price: 1500.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Velvet Carry',
          image: 'assets/images/ii.jpg',
          price: 200.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Sugar Satchel',
          image: 'assets/images/iii.jpg',
          price: 15.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Signature Sling',
          image: 'assets/images/iv.jpg',
          price: 20.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Sweet Carry',
          image: 'assets/images/b8.jpeg',
          price: 15.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Urban Glow',
          image: 'assets/images/b7.jpeg',
          price: 20.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Chic Aura',
          image: 'assets/images/b6.jpeg',
          price: 15.0,
          categorySlug: 'bags'),
      CatalogProduct(
          title: 'Daisy Carry',
          image: 'assets/images/b5.jpeg',
          price: 20.0,
          categorySlug: 'bags'),
    ],
    'jewellery': <CatalogProduct>[
      CatalogProduct(
          title: 'Gold Bracelet',
          image: 'assets/images/j1.jpg',
          price: 6.0,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Platinum Earrings',
          image: 'assets/images/j4.jpg',
          price: 5.0,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Butterfly Necklace',
          image: 'assets/images/j6.jpg',
          price: 9.5,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Necklace',
          image: 'assets/images/j8.jpg',
          price: 8.2,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Set of Rings',
          image: 'assets/images/j3.jpg',
          price: 4.9,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Set of 3 Pendants',
          image: 'assets/images/j7.jpg',
          price: 20.0,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Golden Jhumka',
          image: 'assets/images/j5.jpg',
          price: 5.5,
          categorySlug: 'jewellery'),
      CatalogProduct(
          title: 'Bracelet',
          image: 'assets/images/j2.jpg',
          price: 4.5,
          categorySlug: 'jewellery'),
    ],
  };

  Future<List<CatalogProduct>> fetchHomeProducts({String query = ''}) async {
    try {
      final rows = await _client
          .from('products')
          .select('title,image_url,price,categories(slug)')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(40);

      final products = _mapRows(rows as List);
      if (products.isEmpty) {
        return _homeSelection(_fallbackProducts, query);
      }

      return _homeSelection(products, query);
    } catch (_) {
      return _homeSelection(_fallbackProducts, query);
    }
  }

  Future<List<CatalogProduct>> fetchCategoryProducts({
    required String categorySlug,
    String query = '',
  }) async {
    final normalizedSlug = categorySlug.trim().toLowerCase();
    final fallbackForCategory =
        _categoryFallback[normalizedSlug] ?? const <CatalogProduct>[];

    try {
      final rows = await _client
          .from('products')
          .select('title,image_url,price,categories!inner(slug)')
          .eq('is_active', true)
          .eq('categories.slug', normalizedSlug)
          .order('created_at', ascending: false)
          .limit(80);

      final products = _mapRows(rows as List);
      if (products.isEmpty) {
        return _applySearch(fallbackForCategory, query);
      }
      return _applySearch(products, query);
    } catch (_) {
      return _applySearch(fallbackForCategory, query);
    }
  }

  List<CatalogProduct> _mapRows(List rows) {
    return rows
        .map((row) {
          final category = row['categories'] as Map<String, dynamic>?;
          return CatalogProduct(
            title: (row['title'] ?? '') as String,
            image: (row['image_url'] ?? 'assets/images/122.jpg') as String,
            price: ((row['price'] ?? 0) as num).toDouble(),
            categorySlug: (category?['slug'] ?? '') as String,
          );
        })
        .where((item) => item.title.isNotEmpty)
        .toList(growable: false);
  }

  List<CatalogProduct> _applySearch(List<CatalogProduct> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return items;
    }

    return items
        .where((item) => item.title.toLowerCase().contains(q))
        .toList(growable: false);
  }

  List<CatalogProduct> _homeSelection(
      List<CatalogProduct> items, String query) {
    final filtered = _applySearch(items, query);
    return _pickOnePerCategory(filtered, maxItems: 5);
  }

  List<CatalogProduct> _pickOnePerCategory(
    List<CatalogProduct> items, {
    required int maxItems,
  }) {
    const preferredOrder = <String>[
      'dresses',
      'shoes',
      'watches',
      'bags',
      'jewellery'
    ];

    final byCategory = <String, CatalogProduct>{};
    for (final item in items) {
      final slug = item.categorySlug.trim().toLowerCase();
      if (slug.isEmpty) continue;
      byCategory.putIfAbsent(slug, () => item);
    }

    final selected = <CatalogProduct>[];
    for (final slug in preferredOrder) {
      final item = byCategory[slug];
      if (item != null) {
        selected.add(item);
      }
      if (selected.length == maxItems) break;
    }

    if (selected.length < maxItems) {
      for (final item in items) {
        if (selected.length == maxItems) break;
        if (!selected.contains(item)) {
          selected.add(item);
        }
      }
    }

    return selected.take(maxItems).toList(growable: false);
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(supabaseClientProvider));
});
