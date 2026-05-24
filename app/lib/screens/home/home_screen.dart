import 'package:flutter/material.dart';
import '../../widgets/common/section_title.dart';
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
      backgroundColor: AppColors.tan,
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
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                    child: Text(
                      'TasteBook',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SectionTitle(title: 'Popular Recipes This Week'),
                  const SizedBox(height: 14),
                  _HorizontalRecipeRail(recipes: displayRecipes),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'Spring Produce Recipes'),
                  const SizedBox(height: 14),
                  _HorizontalRecipeRail(
                    recipes: _rotateRecipes(displayRecipes, 2),
                  ),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'One Pan No Dishes!'),
                  const SizedBox(height: 14),
                  _HorizontalRecipeRail(
                    recipes: _rotateRecipes(displayRecipes, 4),
                  ),
                  const SizedBox(height: 18),
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
  const _HorizontalRecipeRail({required this.recipes});

  final List<RecipeModel> recipes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: recipes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _RecipeRailCard(recipe: recipe);
        },
      ),
    );
  }
}

class _RecipeRailCard extends StatelessWidget {
  const _RecipeRailCard({required this.recipe});

  final RecipeModel recipe;

  String _timeLabel(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes.clamp(1, 59)} mins';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours == 1 ? '' : 's'}';
    }
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: SizedBox(
        width: 178,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Hero(
                    tag: 'recipe-img-${recipe.id}',
                    child: Image.asset(
                      recipe.imagePath,
                      width: 178,
                      height: 176,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF79D7E7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          size: 16,
                          color: AppColors.text,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.category,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
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
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _timeLabel(recipe.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 14,
                  color: AppColors.text,
                ),
                const SizedBox(width: 4),
                Text(
                  '100%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
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
                height: 1.08,
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
    );
  }
}
