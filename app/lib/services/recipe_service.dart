import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/recipe_model.dart';

class RecipeService {
  RecipeService._();

  static final RecipeService instance = RecipeService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipes');

  static final List<RecipeModel> defaultRecipes = [
    RecipeModel(
      id: 'mock_1',
      title: 'Steak and Fried',
      authorName: 'Apple23',
      authorId: 'mock_author_1',
      category: 'Budget',
      description: 'A perfect classic ribeye steak served alongside golden crispy french fries.',
      ingredients: '- 250g Ribeye Steak\n- 2 Russet Potatoes\n- 2 cloves Garlic\n- Sprig of Rosemary\n- Olive Oil, Butter, Salt, Pepper',
      instructions: '1. Season steak generously with salt and pepper.\n2. In a hot skillet, sear steak for 3 mins each side.\n3. Add butter, garlic, rosemary and baste for 1 min.\n4. Let rest for 5 mins.\n5. Peel and cut potatoes, fry in oil until crispy.',
      imagePath: 'assets/images/img1.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      favoriteUserIds: const [],
    ),
    RecipeModel(
      id: 'mock_2',
      title: 'Grilled Chicken Bowl',
      authorName: 'MiaChef',
      authorId: 'mock_author_2',
      category: 'Affordable',
      description: 'Healthy and rich chicken breast combined with fresh avocado, quinoa, and soft greens.',
      ingredients: '- Chicken Breast\n- Quinoa\n- Fresh Avocado\n- Mixed Salad Greens\n- Lemon Herb Dressing',
      instructions: '1. Marinate chicken in lemon juice and herbs.\n2. Grill for 6-7 mins per side until internal temp is 165°F.\n3. Cook quinoa in salted water.\n4. Slice avocado.\n5. Combine all items in a bowl and drizzle dressing.',
      imagePath: 'assets/images/img2.jpg',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      favoriteUserIds: const [],
    ),
    RecipeModel(
      id: 'mock_3',
      title: 'Creamy Pasta Bake',
      authorName: 'TasteLab',
      authorId: 'mock_author_3',
      category: 'One Pot',
      description: 'Indulgent baked penne pasta with garlic sauce and bubbling golden mozzarella.',
      ingredients: '- Penne Pasta\n- Heavy Cream & Milk\n- Parmesan Cheese\n- Garlic & Italian Seasoning\n- Mozzarella Cheese',
      instructions: '1. Boil penne until al dente.\n2. Simmer cream, milk, garlic, parmesan in a pan.\n3. Toss pasta in sauce, transfer to a baking dish.\n4. Top with shredded mozzarella.\n5. Bake at 400°F for 15 mins until bubbling.',
      imagePath: 'assets/images/img3.jpg',
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      favoriteUserIds: const [],
    ),
    RecipeModel(
      id: 'mock_4',
      title: 'Fresh Berry Tart',
      authorName: 'NoraKitchen',
      authorId: 'mock_author_4',
      category: 'Budget',
      description: 'Buttery shortcrust pastry shell topped with luxurious custard and sweet berries.',
      ingredients: '- Tart Crust (Flour, Butter, Sugar)\n- Pastry Custard\n- Fresh Strawberries & Blueberries\n- Apricot Glaze',
      instructions: '1. Bake tart crust at 375°F until golden, let cool.\n2. Fill with prepared cold pastry custard.\n3. Arrange fresh berries beautifully on top.\n4. Warm apricot glaze and brush gently over berries.',
      imagePath: 'assets/images/img4.jpg',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
      favoriteUserIds: const [],
    ),
    RecipeModel(
      id: 'mock_5',
      title: 'Classic Burger Stack',
      authorName: 'UrbanBites',
      authorId: 'mock_author_5',
      category: 'Affordable',
      description: 'Juicy double beef patty with melted cheddar, crisp lettuce, and special burger sauce.',
      ingredients: '- Ground Beef Patties\n- Cheddar Cheese Slices\n- Brioche Buns\n- Lettuce, Tomato, Onions\n- Mayonnaise, Ketchup, Mustard',
      instructions: '1. Shape and season beef patties.\n2. Sear on griddle for 3 mins, flip, add cheese.\n3. Toast brioche buns with butter.\n4. Build the burger starting with sauce, lettuce, then patties, tomato, and onion.',
      imagePath: 'assets/images/img5.jpg',
      createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
      favoriteUserIds: const [],
    ),
    RecipeModel(
      id: 'mock_6',
      title: 'Roasted Veg Platter',
      authorName: 'GreenFork',
      authorId: 'mock_author_6',
      category: 'One Pot',
      description: 'Rainbow colored selection of roasted sweet potatoes, zucchini, asparagus, and peppers.',
      ingredients: '- Sweet Potatoes & Zucchini\n- Asparagus & Bell Peppers\n- Garlic Cloves\n- Olive Oil, Thyme, Balsamic Glaze',
      instructions: '1. Chop vegetables into bite-sized pieces.\n2. Toss in olive oil, minced garlic, salt, pepper, and thyme.\n3. Spread on sheet pan.\n4. Roast at 425°F for 25-30 mins.\n5. Drizzle with balsamic glaze.',
      imagePath: 'assets/images/img6.jpg',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      favoriteUserIds: const [],
    ),
  ];

  Future<void> seedDefaultRecipes() async {
    try {
      final snapshot = await _recipes.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final recipe in defaultRecipes) {
          final docRef = _recipes.doc(recipe.id);
          batch.set(docRef, {
            'title': recipe.title,
            'authorName': recipe.authorName,
            'authorId': recipe.authorId,
            'category': recipe.category,
            'description': recipe.description,
            'ingredients': recipe.ingredients,
            'instructions': recipe.instructions,
            'imagePath': recipe.imagePath,
            'createdAt': Timestamp.fromDate(recipe.createdAt),
            'favoriteUserIds': recipe.favoriteUserIds,
          });
        }
        await batch.commit();
      }
    } catch (e) {
      // Log or ignore seeding errors so it doesn't crash the app start
      debugPrint('Error seeding default recipes: $e');
    }
  }

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
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs.map(RecipeModel.fromFirestore).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }

  Stream<List<RecipeModel>> watchFavoriteRecipes(String userId) {
    return _recipes
        .where('favoriteUserIds', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs.map(RecipeModel.fromFirestore).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }

  Future<void> createRecipe(RecipeModel recipe) async {
    final docRef = _recipes.doc();
    final batch = _firestore.batch();
    batch.set(docRef, recipe.toFirestore());
    batch.set(
      _firestore.collection('users').doc(recipe.authorId),
      {
        'recipeCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> updateRecipe(RecipeModel recipe) async {
    final data = recipe.toFirestore();
    data.remove('createdAt');
    await _recipes.doc(recipe.id).update(data);
  }

  Future<void> deleteRecipe(String recipeId, String userId) async {
    final batch = _firestore.batch();
    batch.delete(_recipes.doc(recipeId));
    batch.set(
      _firestore.collection('users').doc(userId),
      {
        'recipeCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
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

  Future<List<RecipeModel>> searchRecipes(
    String query, {
    String? category,
    String? sortBy,
  }) async {
    Query<Map<String, dynamic>> queryRef = _recipes;

    // Apply Firestore category filtering if a specific category is requested
    if (category != null && category.isNotEmpty && category != 'All') {
      queryRef = queryRef.where('category', isEqualTo: category);
    }

    final snapshot = await queryRef.get();
    var recipes = snapshot.docs.map(RecipeModel.fromFirestore).toList();

    // Apply fuzzy local text search across multiple fields
    final lowered = query.trim().toLowerCase();
    if (lowered.isNotEmpty) {
      recipes = recipes.where((recipe) {
        return recipe.title.toLowerCase().contains(lowered) ||
            recipe.authorName.toLowerCase().contains(lowered) ||
            recipe.category.toLowerCase().contains(lowered) ||
            recipe.description.toLowerCase().contains(lowered) ||
            recipe.ingredients.toLowerCase().contains(lowered);
      }).toList();
    } else {
      // If no query and category is 'All', return a subset or fallback
      if (category == 'All' || category == null) {
        recipes = recipes.take(18).toList();
      }
    }

    // Apply sorting logic
    if (sortBy == 'Newest') {
      recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy == 'Popularity') {
      recipes.sort((a, b) => b.favoriteUserIds.length.compareTo(a.favoriteUserIds.length));
    }

    return recipes;
  }
}
