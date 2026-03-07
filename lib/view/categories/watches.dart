import 'package:ecom_app/view/categories/category_products_page.dart';
import 'package:flutter/material.dart';

class Watches extends StatelessWidget {
  const Watches({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryProductsPage(
      slug: 'watches',
      title: 'Watches',
      searchHint: 'Search Watches',
    );
  }
}
