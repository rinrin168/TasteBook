import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common/section_title.dart';
import '../../widgets/common/recipe_image.dart';
import '../../widgets/navigation/add_recipe_popup.dart';
import '../../widgets/navigation/bottom_navbar.dart';
import '../../models/recipe_model.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

enum _LibraryTab { favorites, posted }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _LibraryTab _activeTab = _LibraryTab.favorites;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<List<RecipeModel>>(
      stream: _favoriteRecipesStream(),
      builder: (context, favSnapshot) {
        final favoritesList = favSnapshot.data ?? const [];
        return StreamBuilder<List<RecipeModel>>(
          stream: _postedRecipesStream(),
          builder: (context, postedSnapshot) {
            final postedList = postedSnapshot.data ?? const [];

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Library',
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Keep track of the recipes you love and the ones you create.',
                          style: TextStyle(
                            color: AppColors.coffee,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _LibraryTabs(
                          activeTab: _activeTab,
                          favoriteCount: favoritesList.length,
                          postedCount: postedList.length,
                          onFavoritesTap: () {
                            if (_activeTab != _LibraryTab.favorites) {
                              setState(() {
                                _activeTab = _LibraryTab.favorites;
                              });
                            }
                          },
                          onPostedTap: () {
                            if (_activeTab != _LibraryTab.posted) {
                              setState(() {
                                _activeTab = _LibraryTab.posted;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 22),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: _activeTab == _LibraryTab.favorites
                              ? Column(
                                  key: const ValueKey('favorites_tab'),
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SectionTitle(title: 'Favorite Recipes'),
                                    const SizedBox(height: 14),
                                    favSnapshot.connectionState == ConnectionState.waiting && favoritesList.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 24),
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          )
                                        : favoritesList.isEmpty
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 40),
                                                child: Text(
                                                  'No favorite recipes yet.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.coffee,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              )
                                            : ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: favoritesList.length,
                                                separatorBuilder: (context, index) =>
                                                    const SizedBox(height: 14),
                                                itemBuilder: (context, index) {
                                                  final recipe = favoritesList[index];
                                                  return _FavoriteRecipeTile(recipe: recipe);
                                                },
                                              ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('posted_tab'),
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SectionTitle(title: 'Recipes You Posted'),
                                    const SizedBox(height: 14),
                                    postedSnapshot.connectionState == ConnectionState.waiting && postedList.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 24),
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          )
                                        : postedList.isEmpty
                                            ? const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 40),
                                                child: Text(
                                                  'No posted recipes yet.',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: AppColors.coffee,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              )
                                            : ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: postedList.length,
                                                separatorBuilder: (context, index) =>
                                                    const SizedBox(height: 14),
                                                itemBuilder: (context, index) {
                                                  final recipe = postedList[index];
                                                  return _PostedRecipeTile(recipe: recipe);
                                                },
                                              ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                child: BottomNavbar(
                  currentIndex: 1,
                  onAddTap: () => showAddRecipePopup(context),
                  onHomeTap: () => Navigator.of(context).pushReplacementNamed('/home'),
                  onSearchTap: () =>
                      Navigator.of(context).pushReplacementNamed('/search'),
                  onProfileTap: () =>
                      Navigator.of(context).pushReplacementNamed('/profile'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<List<RecipeModel>> _favoriteRecipesStream() {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return Stream.value(const <RecipeModel>[]);
    }

    return RecipeService.instance.watchFavoriteRecipes(user.uid);
  }

  Stream<List<RecipeModel>> _postedRecipesStream() {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return Stream.value(const <RecipeModel>[]);
    }

    return RecipeService.instance.watchUserRecipes(user.uid);
  }
}

class _LibraryTabs extends StatelessWidget {
  const _LibraryTabs({
    required this.activeTab,
    required this.favoriteCount,
    required this.postedCount,
    required this.onFavoritesTap,
    required this.onPostedTap,
  });

  final _LibraryTab activeTab;
  final int favoriteCount;
  final int postedCount;
  final VoidCallback onFavoritesTap;
  final VoidCallback onPostedTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tan.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LibraryTabButton(
              label: 'Favorites',
              count: favoriteCount,
              active: activeTab == _LibraryTab.favorites,
              onTap: onFavoritesTap,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _LibraryTabButton(
              label: 'Your Recipes',
              count: postedCount,
              active: activeTab == _LibraryTab.posted,
              onTap: onPostedTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryTabButton extends StatelessWidget {
  const _LibraryTabButton({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = active ? AppColors.white : AppColors.text;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: active ? AppColors.white.withValues(alpha: 0.2) : AppColors.tan,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostedRecipeTile extends StatelessWidget {
  const _PostedRecipeTile({required this.recipe});

  final RecipeModel recipe;

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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Hero(
                tag: 'recipe-img-${recipe.id}',
                child: RecipeImage(
                  imagePath: recipe.imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${recipe.authorName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.coffee,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              onPressed: () {
                showAddRecipePopup(context, recipeToEdit: recipe);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteRecipeTile extends StatelessWidget {
  const _FavoriteRecipeTile({required this.recipe});

  final RecipeModel recipe;

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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.text.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Hero(
                tag: 'recipe-img-${recipe.id}',
                child: RecipeImage(
                  imagePath: recipe.imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${recipe.authorName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.coffee,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.favorite,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
