import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/databaseConnection/recipeLogic/import_comment.dart';


class Recipe {
  final String recipeId;
  final String name;
  final int prepTime;
  final DateTime createdAt;
  final int difficulty;
  final String imageUrl;
  final List<Map<String, dynamic>> ingredients;
  final int likes;
  final int servings;
  final List<String> steps;
  final String userId;
  final List<String> trackLikes;
  final List<String> saves;
  final List<Comment> comments;

  Recipe({
    required this.recipeId,
    required this.name,
    required this.prepTime,
    required this.createdAt,
    required this.difficulty,
    required this.imageUrl,
    required this.ingredients,
    required this.likes,
    required this.servings,
    required this.steps,
    required this.userId,
    required this.trackLikes,
    required this.saves,
    required this.comments
  });

  Map<String, dynamic> toMap() {
    return {
      "recipeId" : recipeId,
      'name': name,
      'cooking_time_minutes': prepTime,
      'created_at': createdAt,
      'difficulty': difficulty,
      'image_url': imageUrl,
      'ingredients': ingredients,
      'likes': likes,
      'servings': servings,
      'steps': steps,
      'userId': userId,
      'trackLikes': trackLikes,
      'saves': saves,
    };
  }

 factory Recipe.fromMap(Map<String, dynamic> map) {
  return Recipe(
    recipeId: map['recipeId'] is String
        ? map['recipeId']
        : int.tryParse(map['recipeId']?.toString() ?? '0') ?? 0,
    name: map['name']?.toString() ?? '',
    prepTime: map['cooking_time_minutes'] is int
        ? map['cooking_time_minutes']
        : int.tryParse(map['cooking_time_minutes']?.toString() ?? '0') ?? 0,
    createdAt: (map['created_at'] as Timestamp).toDate(),
    difficulty: map['difficulty'] is int
        ? map['difficulty']
        : int.tryParse(map['difficulty']?.toString() ?? '0') ?? 0,
    imageUrl: map['image_url']?.toString() ?? '',
    ingredients: List<Map<String, dynamic>>.from(map['ingredients'] ?? []),
    likes: List<String>.from(map['trackLikes'] ?? []).length,
    servings: map['servings'] is int
        ? map['servings']
        : int.tryParse(map['servings']?.toString() ?? '0') ?? 0,
    steps: List<String>.from(map['steps'] ?? []),
    userId: map['userId']?.toString() ?? '',
    trackLikes: List<String>.from(map['trackLikes'] ?? []),
    saves: List<String>.from(map['saves'] ?? []),
    comments: (map['comments'] as List<dynamic>?)
        ?.map((commentMap) => Comment.fromMap(commentMap as Map<String, dynamic>))
        .toList()
        ?? [],
  );
}
}