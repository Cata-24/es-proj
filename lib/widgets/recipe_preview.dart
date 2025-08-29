import 'package:flutter/material.dart';
import 'package:app/databaseConnection/recipeLogic/import_recipe.dart';

class RecipePreview extends StatelessWidget {
  final Recipe recipe;

  const RecipePreview({
    super.key,
    required this.recipe,
  });
@override
Widget build(BuildContext context) {
  String difficulty = recipe.difficulty.toString();
  String time = recipe.prepTime.toString();
  String servings = recipe.servings.toString();
  String likes = recipe.likes.toString();

  return Container(
    margin: const EdgeInsets.all(10),
    height: 190,
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 8,
          offset: Offset(2, 4),
        ),
      ],
      color: const Color.fromRGBO(246, 246, 245, 1.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: double.infinity,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
           child: recipe.imageUrl != null && recipe.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image,
                            size: 80, color: Colors.red);
                      },
                    ),
                  )
                : Icon(Icons.food_bank, size: 80, color: Colors.green[900]),
          ),

        // Text Information Section
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recipe.name,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("$time mins",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black, ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 20, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("Difficulty: $difficulty/5",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black, )
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 20, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("Servings: $servings",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black, ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 20, color: Colors.black),
                    const SizedBox(width: 4),
                    Text("$likes likes",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black, ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}}
