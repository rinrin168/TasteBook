import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.author,
    this.isFavorite = false,
  });

  final String imagePath;
  final String title;
  final String author;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;
        final compactCard = hasBoundedHeight && constraints.maxHeight < 225;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: compactCard ? 1.34 : 1.16,
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  compactCard ? 8 : 10,
                  12,
                  compactCard ? 8 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: compactCard ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                          ),
                          if (!compactCard) ...[
                            const SizedBox(height: 4),
                            Text(
                              'By $author',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.black.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_right_alt_rounded,
                      color: AppColors.text,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
