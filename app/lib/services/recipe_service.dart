import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/recipe_model.dart';

class RecipeService {
  RecipeService._();

  static final RecipeService instance = RecipeService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipes');

  Stream<List<RecipeModel>> watchRecentRecipes({int limit = 18}) {
    return _recipes
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(RecipeModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<RecipeModel>> watchUserRecipes(String userId) {
    return _recipes
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(RecipeModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<RecipeModel>> watchFavoriteRecipes(String userId) {
    return _recipes
        .where('favoriteUserIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(RecipeModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<void> createRecipe(RecipeModel recipe) async {
    await _recipes.add(recipe.toFirestore());
  }

  Future<void> incrementUserRecipeCount(String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'recipeCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> toggleFavorite({
    required String recipeId,
    required String userId,
  }) async {
    final docRef = _recipes.doc(recipeId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data();
      if (data == null) return;

      final currentFavorites = List<String>.from(
        data['favoriteUserIds'] as List<dynamic>? ?? const [],
      );

      if (currentFavorites.contains(userId)) {
        currentFavorites.remove(userId);
      } else {
        currentFavorites.add(userId);
      }

      transaction.update(docRef, {'favoriteUserIds': currentFavorites});
    });
  }

  Future<List<RecipeModel>> searchRecipes(String query) async {
    final snapshot = await _recipes
        .orderBy('createdAt', descending: true)
        .get();
    final lowered = query.trim().toLowerCase();
    final recipes = snapshot.docs.map(RecipeModel.fromFirestore).toList();

    if (lowered.isEmpty) {
      return recipes.take(6).toList(growable: false);
    }

    return recipes
        .where((recipe) {
          return recipe.title.toLowerCase().contains(lowered) ||
              recipe.authorName.toLowerCase().contains(lowered) ||
              recipe.category.toLowerCase().contains(lowered) ||
              recipe.description.toLowerCase().contains(lowered);
        })
        .toList(growable: false);
  }
}
