import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../models/recipe_model.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import '../../services/storage_service.dart';

class NewRecipeScreen extends StatefulWidget {
  const NewRecipeScreen({super.key});

  static const routeName = '/new_recipe';

  @override
  State<NewRecipeScreen> createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends State<NewRecipeScreen> {
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
  XFile? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
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
      String finalImagePath = 'assets/images/img1.jpg';
      if (_selectedImage != null) {
        finalImagePath = await StorageService.instance.uploadRecipeImage(
          _selectedImage!,
          user.uid,
        );
      }

      await RecipeService.instance.createRecipe(
        RecipeModel(
          id: '',
          title: _nameController.text.trim(),
          authorName: user.displayName?.isNotEmpty == true
              ? user.displayName!
              : 'You',
          authorId: user.uid,
          category:
              _selectedCategory ??
              (_otherCategoryController.text.trim().isNotEmpty
                  ? _otherCategoryController.text.trim()
                  : 'Other'),
          description: _descriptionController.text.trim(),
          ingredients: _ingredientsController.text.trim(),
          instructions: _instructionsController.text.trim(),
          imagePath: finalImagePath,
          createdAt: DateTime.now(),
          favoriteUserIds: const [],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe posted successfully.')),
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
      appBar: AppBar(
        backgroundColor: AppColors.tan,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        title: const Text(
          'New Recipe',
          style: TextStyle(color: AppColors.text),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _selectedImage != null
                      ? (kIsWeb
                          ? Image.network(
                              _selectedImage!.path,
                              height: 140,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.file(
                              File(_selectedImage!.path),
                              height: 140,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ))
                      : Image.asset(
                          'assets/images/img1.jpg',
                          height: 140,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _pickImage,
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
                const _FieldLabel('Name'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _nameController,
                  hintText: 'example name',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Description'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _descriptionController,
                  hintText: 'example description',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Categories'),
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
                        labelStyle: TextStyle(
                          color: _selectedCategory == category ? AppColors.white : AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.white,
                        selectedColor: AppColors.primary,
                        side: BorderSide(
                          color: _selectedCategory == category ? Colors.transparent : AppColors.outline.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Other'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _otherCategoryController,
                  hintText: 'Other category name',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Ingredients'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _ingredientsController,
                  hintText: 'Ingredients (one per line)',
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Cooking Instructions'),
                const SizedBox(height: 6),
                _RecipeInput(
                  controller: _instructionsController,
                  hintText: 'Cooking instructions steps',
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
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Cancel',
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
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: const StadiumBorder(),
                            elevation: 2,
                          ),
                          child: Text(
                            _isSubmitting ? 'Posting...' : 'Post',
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
        fontWeight: FontWeight.w800,
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
        hintStyle: TextStyle(
          color: AppColors.coffee.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}
