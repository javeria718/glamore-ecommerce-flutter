import 'package:ecom_app/view/categories/category_products_page.dart';
import 'package:flutter/material.dart';

class Bags extends StatelessWidget {
  const Bags({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryProductsPage(
      slug: 'bags',
      title: 'Bags',
      searchHint: 'Search Bags',
    );
  }
}
