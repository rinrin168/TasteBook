import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorFallback(),
      );
    } else if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorFallback(),
      );
    } else {
      if (kIsWeb) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _errorFallback(),
        );
      } else {
        return Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _errorFallback(),
        );
      }
    }
  }

  Widget _errorFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
