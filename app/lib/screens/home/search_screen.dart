import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/navigation/add_recipe_popup.dart';
import '../../widgets/navigation/bottom_navbar.dart';
import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  static const _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Drinks',
    'Other',
  ];

  static const _sortOptions = [
    'Newest',
    'Popularity',
  ];

  String _selectedCategory = 'All';
  String _selectedSort = 'Newest';
  List<RecipeModel> _results = [];
  bool _isSearching = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
    _controller.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    // Optional: Auto-search on typing could be triggered here.
    // For performance, we can trigger _performSearch() directly or on submit.
    // Let's do automatic search on text change for a premium real-time feel!
    _performSearch();
  }

  Future<void> _performSearch() async {
    try {
      final list = await RecipeService.instance.searchRecipes(
        _controller.text,
        category: _selectedCategory,
        sortBy: _selectedSort,
      );
      if (!mounted) return;
      setState(() {
        _results = list;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.tan,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header & Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Search recipes, authors, or ingredients',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _controller.clear();
                                _performSearch();
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Horizontal Category Chips
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return ChoiceChip(
                    selected: isSelected,
                    label: Text(category),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _isSearching = true;
                        });
                        _performSearch();
                      }
                    },
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                    backgroundColor: AppColors.card.withValues(alpha: 0.65),
                    selectedColor: AppColors.coffee,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Sort Selector bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  const Icon(Icons.sort_rounded, size: 18, color: AppColors.text),
                  const SizedBox(width: 6),
                  Text(
                    'Sort by:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedSort,
                    dropdownColor: AppColors.tan,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.text),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                    items: _sortOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedSort = newValue;
                          _isSearching = true;
                        });
                        _performSearch();
                      }
                    },
                  ),
                  const Spacer(),
                  Text(
                    '${_results.length} recipes found',
                    style: const TextStyle(
                      color: AppColors.coffee,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Results List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _isSearching
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.coffee),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 72,
                                    color: AppColors.text.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No recipes found',
                                    style: textTheme.titleLarge?.copyWith(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Try adjusting your search query or selecting a different category filter.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.coffee,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _results.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final recipe = _results[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                                    ),
                                  ).then((_) => _performSearch());
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: 'recipe-img-${recipe.id}',
                                        child: SizedBox(
                                          width: 110,
                                          height: 96,
                                          child: Image.asset(
                                            recipe.imagePath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w800,
                                                      height: 1.15,
                                                    ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'By ${recipe.authorName}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Colors.black.withValues(alpha: 0.72),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                recipe.category,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: AppColors.coffee,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavbar(
          currentIndex: 3,
          onAddTap: () => showAddRecipePopup(context),
          onHomeTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          onLibraryTap: () =>
              Navigator.of(context).pushReplacementNamed('/library'),
          onProfileTap: () =>
              Navigator.of(context).pushReplacementNamed('/profile'),
        ),
      ),
    );
  }
}
