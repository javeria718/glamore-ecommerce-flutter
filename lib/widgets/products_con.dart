import 'package:ecom_app/view/cart/product_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class ProductInfo extends StatelessWidget {
  final String link;
  final String title;
  final String price;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ProductInfo({
    super.key,
    required this.link,
    required this.title,
    required this.price,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final fontSize = screenWidth < 420 ? 16.0 : 18.0;
    final iconSize = screenWidth < 420 ? 18.0 : 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Take width of the Grid item from LayoutBuilder
        final itemWidth = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          link,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: itemWidth * 0.06,
                        vertical: itemWidth * 0.025,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: itemWidth * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                price,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: fontSize,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              Row(
                                children: [
                                  if (onFavoriteTap != null)
                                    InkWell(
                                      onTap: onFavoriteTap,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: EdgeInsets.all(itemWidth * 0.03),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors.teal.withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: iconSize,
                                          color: isFavorite
                                              ? Colors.redAccent
                                              : Colors.teal.shade700,
                                        ),
                                      ),
                                    ),
                                  if (onFavoriteTap != null)
                                    SizedBox(width: itemWidth * 0.025),
                                  InkWell(
                                    onTap: () {
                                      final parsedPrice = double.tryParse(
                                              price.replaceAll(
                                                  RegExp(r'[^0-9.]'), '')) ??
                                          0.0;

                                      showDialog(
                                        context: context,
                                        builder: (_) => ProductDialog(
                                          image: link,
                                          title: title,
                                          price: parsedPrice,
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: EdgeInsets.all(itemWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        size: iconSize,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
