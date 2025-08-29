import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';

abstract class IngredientStorage {
  Future<Ingredient?> getIngredient(String ingredientId);
  Future<List<Ingredient>> searchIngredients(String query);
}