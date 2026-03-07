class CatalogProduct {
  const CatalogProduct({
    required this.title,
    required this.image,
    required this.price,
    required this.categorySlug,
  });

  final String title;
  final String image;
  final double price;
  final String categorySlug;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
