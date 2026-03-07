import 'package:flutter/material.dart';

class CustomCategories extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback? onPressed;

  const CustomCategories({
    super.key,
    required this.image,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = (screenWidth * 0.045).clamp(28.0, 42.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundImage: AssetImage(image),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: avatarRadius * 2,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
