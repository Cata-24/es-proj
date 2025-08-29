// app/utils/pantry_navigator.dart
import 'package:flutter/material.dart';
import 'package:app/widgets/ingredient_screen.dart';
import 'package:app/widgets/pantry/add_ingredient_screen.dart';
import 'package:app/widgets/pantry/pantry_item.dart';

class PantryNavigation {
  static Future<void> navigateToIngredientDetails(BuildContext context, PantryItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientScreen(
          name: item.name,
          imagePath: item.imagePath,
          quantity: item.weight,
          caloriesPer100g: item.calories,
          expireDate: item.expireDate,
          index: item.index,
        ),
      ),
    );
  }

  static Future<dynamic> navigateToAddOrEditIngredient(BuildContext context, {PantryItem? ingredient}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddIngredientPage(ingredient: ingredient),
      ),
    );
    if (result is Map<String, dynamic> || result is String) {
      return result;
    }
    return null;
  }
}