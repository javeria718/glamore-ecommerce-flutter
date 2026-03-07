import 'package:ecom_app/view/categories/category_products_page.dart';
import 'package:flutter/material.dart';

class Clothes extends StatelessWidget {
  const Clothes({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryProductsPage(
      slug: 'dresses',
      title: 'Clothes',
      searchHint: 'Search Clothes',
    );
  }
}
