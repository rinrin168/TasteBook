import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../models/recipe_model.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import '../../widgets/navigation/add_recipe_popup.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final RecipeModel recipe;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late RecipeModel _recipe;
  bool _isFavorite = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _currentUser = AuthService.instance.currentUser;
    if (_currentUser != null) {
      _isFavorite = _recipe.favoriteUserIds.contains(_currentUser!.uid);
    }
  }

  void _toggleFavorite() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to favorite recipes.')),
      );
      return;
    }

    final uid = _currentUser!.uid;
    
    // Copy to a mutable list to prevent crash if original list is unmodifiable
    final updatedFavorites = List<String>.from(_recipe.favoriteUserIds);
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        if (!updatedFavorites.contains(uid)) {
          updatedFavorites.add(uid);
        }
      } else {
        updatedFavorites.remove(uid);
      }
      _recipe = _recipe.copyWith(favoriteUserIds: updatedFavorites);
    });

    try {
      await RecipeService.instance.toggleFavorite(
        recipeId: _recipe.id,
        userId: uid,
      );
    } catch (e) {
      // Revert if error
      final revertedFavorites = List<String>.from(_recipe.favoriteUserIds);
      setState(() {
        _isFavorite = !_isFavorite;
        if (_isFavorite) {
          if (!revertedFavorites.contains(uid)) {
            revertedFavorites.add(uid);
          }
        } else {
          revertedFavorites.remove(uid);
        }
        _recipe = _recipe.copyWith(favoriteUserIds: revertedFavorites);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorite status: $e')),
      );
    }
  }

  void _editRecipe() {
    showAddRecipePopup(
      context,
      recipeToEdit: _recipe,
    );
    // Listen to changes if needed, but since sheet pops, we can refresh when modal closes
    // Actually, we could watch or listen, but a simpler way is refreshing this screen's state if we set a listener.
    // However, since it is backed by Firestore snapshots in parent screens, we can just pop or reload.
    // Let's pop back to library/home on change, or simply popped and show a notice.
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.tan,
          title: const Text(
            'Delete Recipe',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this recipe? This action cannot be undone.',
            style: TextStyle(color: AppColors.text),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.coffee, fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                _deleteRecipe();
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRecipe() async {
    if (_currentUser == null) return;
    try {
      await RecipeService.instance.deleteRecipe(_recipe.id, _currentUser!.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe deleted successfully.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor = _currentUser != null && _recipe.authorId == _currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.tan,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.tan,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe-img-${_recipe.id}',
                child: Image.asset(
                  _recipe.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.tan,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF79D7E7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _recipe.category,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        _timeLabel(_recipe.createdAt),
                        style: const TextStyle(
                          color: AppColors.coffee,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Recipe Title
                  Text(
                    _recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Recipe Author
                  Text(
                    'By ${_recipe.authorName}',
                    style: const TextStyle(
                      color: AppColors.coffee,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons for Author
                  if (isAuthor) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _editRecipe,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Recipe'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.text, width: 1.5),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _confirmDelete,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Divider(color: AppColors.outline, thickness: 1),
                  const SizedBox(height: 12),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _recipe.description.isNotEmpty ? _recipe.description : 'No description provided.',
                    style: const TextStyle(
                      color: AppColors.text,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _recipe.ingredients.isNotEmpty ? _recipe.ingredients : 'No ingredients specified.',
                    style: const TextStyle(
                      color: AppColors.text,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  const Text(
                    'Cooking Instructions',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _recipe.instructions.isNotEmpty ? _recipe.instructions : 'No cooking instructions specified.',
                    style: const TextStyle(
                      color: AppColors.text,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes.clamp(1, 59)} mins ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours == 1 ? '' : 's'} ago';
    }
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
}
