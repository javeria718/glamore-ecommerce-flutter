import 'package:ecom_app/view/categories/category_products_page.dart';
import 'package:flutter/material.dart';

class Jewelery extends StatelessWidget {
  const Jewelery({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryProductsPage(
      slug: 'jewellery',
      title: 'Jewellery',
      searchHint: 'Search Jewellery',
    );
  }
}
