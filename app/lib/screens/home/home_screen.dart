import 'package:flutter/material.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/recipe_image.dart';
import '../../widgets/navigation/add_recipe_popup.dart';
import '../../widgets/navigation/bottom_navbar.dart';
import '../../core/constants/app_colors.dart';
import '../../models/recipe_model.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<RecipeModel>>(
          stream: RecipeService.instance.watchRecentRecipes(),
          builder: (context, snapshot) {
            final backendRecipes = snapshot.data ?? const <RecipeModel>[];
            final displayRecipes = backendRecipes.isEmpty
                ? RecipeService.defaultRecipes
                : backendRecipes;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TasteBook',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                    fontSize: 28,
                                  ),
                            ),
                            Text(
                              'Your premium cooking guide',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.coffee,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.text.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 36,
                            width: 36,
                            fit: BoxFit.contain,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'Popular Recipes This Week'),
                  const SizedBox(height: 10),
                  _HorizontalRecipeRail(
                    recipes: displayRecipes,
                    heroTagPrefix: 'popular-',
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Spring Produce Recipes'),
                  const SizedBox(height: 10),
                  _HorizontalRecipeRail(
                    recipes: _rotateRecipes(displayRecipes, 2),
                    heroTagPrefix: 'spring-',
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'One Pan No Dishes!'),
                  const SizedBox(height: 10),
                  _HorizontalRecipeRail(
                    recipes: _rotateRecipes(displayRecipes, 4),
                    heroTagPrefix: 'onepan-',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavbar(
          currentIndex: 0,
          onAddTap: () => showAddRecipePopup(context),
          onLibraryTap: () =>
              Navigator.of(context).pushReplacementNamed('/library'),
          onSearchTap: () =>
              Navigator.of(context).pushReplacementNamed('/search'),
          onProfileTap: () =>
              Navigator.of(context).pushReplacementNamed('/profile'),
        ),
      ),
    );
  }

  List<RecipeModel> _rotateRecipes(
    List<RecipeModel> recipes,
    int offset,
  ) {
    if (recipes.isEmpty) return RecipeService.defaultRecipes;
    return List<RecipeModel>.generate(
      recipes.length,
      (index) => recipes[(index + offset) % recipes.length],
      growable: false,
    );
  }
}

class _HorizontalRecipeRail extends StatelessWidget {
  const _HorizontalRecipeRail({required this.recipes, this.heroTagPrefix = ''});

  final List<RecipeModel> recipes;
  final String heroTagPrefix;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 295,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recipes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _RecipeRailCard(recipe: recipe, heroTagPrefix: heroTagPrefix);
        },
      ),
    );
  }
}

class _RecipeRailCard extends StatelessWidget {
  const _RecipeRailCard({required this.recipe, this.heroTagPrefix = ''});

  final RecipeModel recipe;
  final String heroTagPrefix;

  String _timeLabel(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes.clamp(1, 59)}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'budget':
        return AppColors.sage;
      case 'affordable':
        return AppColors.accent;
      case 'one pot':
        return AppColors.blueAccent;
      default:
        return AppColors.coffee;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(recipe.category);
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: '${heroTagPrefix}recipe-img-${recipe.id}',
                  child: RecipeImage(
                    imagePath: recipe.imagePath,
                    width: 190,
                    height: 154,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: catColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      recipe.category,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      final currentUser = AuthService.instance.currentUser;
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please sign in to favorite recipes.')),
                        );
                        return;
                      }
                      try {
                        await RecipeService.instance.toggleFavorite(
                          recipeId: recipe.id,
                          userId: currentUser.uid,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AuthService.instance.currentUser != null &&
                                recipe.favoriteUserIds.contains(AuthService.instance.currentUser!.uid)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: AuthService.instance.currentUser != null &&
                                recipe.favoriteUserIds.contains(AuthService.instance.currentUser!.uid)
                            ? Colors.redAccent
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 12, color: AppColors.coffee.withValues(alpha: 0.8)),
                      const SizedBox(width: 3),
                      Text(
                        _timeLabel(recipe.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.coffee,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '4.8',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${recipe.authorName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.coffee,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
