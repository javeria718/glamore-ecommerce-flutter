import 'package:ecom_app/view/categories/category_products_page.dart';
import 'package:flutter/material.dart';

class Shoes extends StatelessWidget {
  const Shoes({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryProductsPage(
      slug: 'shoes',
      title: 'Shoes',
      searchHint: 'Search Shoes',
    );
  }
}
