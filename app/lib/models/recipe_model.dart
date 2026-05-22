import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.authorName,
    required this.authorId,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.imagePath,
    required this.createdAt,
    required this.favoriteUserIds,
  });

  final String id;
  final String title;
  final String authorName;
  final String authorId;
  final String category;
  final String description;
  final String ingredients;
  final String instructions;
  final String imagePath;
  final DateTime createdAt;
  final List<String> favoriteUserIds;

  factory RecipeModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return RecipeModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'You',
      authorId: data['authorId'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      description: data['description'] as String? ?? '',
      ingredients: data['ingredients'] as String? ?? '',
      instructions: data['instructions'] as String? ?? '',
      imagePath: data['imagePath'] as String? ?? 'assets/images/img1.jpg',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      favoriteUserIds: List<String>.from(
        data['favoriteUserIds'] as List<dynamic>? ?? const [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'authorName': authorName,
      'authorId': authorId,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'imagePath': imagePath,
      'createdAt': FieldValue.serverTimestamp(),
      'favoriteUserIds': favoriteUserIds,
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? authorName,
    String? authorId,
    String? category,
    String? description,
    String? ingredients,
    String? instructions,
    String? imagePath,
    DateTime? createdAt,
    List<String>? favoriteUserIds,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      authorId: authorId ?? this.authorId,
      category: category ?? this.category,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      favoriteUserIds: favoriteUserIds ?? this.favoriteUserIds,
    );
  }
}
