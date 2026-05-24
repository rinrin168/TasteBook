import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/recipe_model.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';

Future<RecipeModel?> showAddRecipePopup(BuildContext context, {RecipeModel? recipeToEdit}) {
  return showModalBottomSheet<RecipeModel?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return FractionallySizedBox(
        heightFactor: 0.96,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              color: AppColors.tan,
              child: _AddRecipeFormSheet(recipeToEdit: recipeToEdit),
            ),
          ),
        ),
      );
    },
  );
}

class _AddRecipeFormSheet extends StatefulWidget {
  const _AddRecipeFormSheet({this.recipeToEdit});

  final RecipeModel? recipeToEdit;

  @override
  State<_AddRecipeFormSheet> createState() => _AddRecipeFormSheetState();
}

class _AddRecipeFormSheetState extends State<_AddRecipeFormSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  static const _categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Sweet',
    'Salty',
    'Quick',
    'Take Time',
    'Drinks',
    'Other',
  ];

  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      final recipe = widget.recipeToEdit!;
      _nameController.text = recipe.title;
      _descriptionController.text = recipe.description;
      _ingredientsController.text = recipe.ingredients;
      _instructionsController.text = recipe.instructions;
      if (_categories.contains(recipe.category)) {
        _selectedCategory = recipe.category;
      } else {
        _selectedCategory = 'Other';
        _otherCategoryController.text = recipe.category;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _otherCategoryController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _postRecipe() async {
    if (_isSubmitting) return;

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to post a recipe.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final categoryStr = _selectedCategory ??
          (_otherCategoryController.text.trim().isNotEmpty
              ? _otherCategoryController.text.trim()
              : 'Other');

      RecipeModel? updatedRecipe;
      if (widget.recipeToEdit != null) {
        // Edit mode (Update)
        updatedRecipe = widget.recipeToEdit!.copyWith(
          title: _nameController.text.trim(),
          category: categoryStr,
          description: _descriptionController.text.trim(),
          ingredients: _ingredientsController.text.trim(),
          instructions: _instructionsController.text.trim(),
        );
        await RecipeService.instance.updateRecipe(updatedRecipe);
      } else {
        // Create mode
        await RecipeService.instance.createRecipe(
          RecipeModel(
            id: '',
            title: _nameController.text.trim(),
            authorName: user.displayName?.isNotEmpty == true
                ? user.displayName!
                : 'You',
            authorId: user.uid,
            category: categoryStr,
            description: _descriptionController.text.trim(),
            ingredients: _ingredientsController.text.trim(),
            instructions: _instructionsController.text.trim(),
            imagePath: 'assets/images/img1.jpg',
            createdAt: DateTime.now(),
            favoriteUserIds: const [],
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(updatedRecipe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.recipeToEdit != null
              ? 'Recipe updated successfully.'
              : 'Recipe posted successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tan,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.recipeToEdit != null ? 'Edit Recipe' : 'New Recipes',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.text,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/img1.jpg',
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text(
                      'Add Photos',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Recipe Detail',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel('Name'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _nameController,
                  hintText: 'example name',
                ),
                const SizedBox(height: 12),
                _FieldLabel('Description'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _descriptionController,
                  hintText: 'example description',
                ),
                const SizedBox(height: 12),
                _FieldLabel('Categories'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in _categories)
                      ChoiceChip(
                        selected: _selectedCategory == category,
                        label: Text(category),
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        labelStyle: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.background,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _FieldLabel('Other'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _otherCategoryController,
                  hintText: 'example description',
                ),
                const SizedBox(height: 12),
                _FieldLabel('Ingredients'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _ingredientsController,
                  hintText: 'example Ingredients',
                ),
                const SizedBox(height: 12),
                _FieldLabel('Cooking Instructions'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _instructionsController,
                  hintText: 'example instruction........',
                  maxLines: 5,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: BorderSide(
                              color: AppColors.white.withValues(alpha: 0.6),
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: AppColors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _postRecipe,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.text,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            _isSubmitting
                                ? (widget.recipeToEdit != null ? 'Saving...' : 'Posting...')
                                : (widget.recipeToEdit != null ? 'Save' : 'Post'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RecipeInput extends StatelessWidget {
  const _RecipeInput({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
