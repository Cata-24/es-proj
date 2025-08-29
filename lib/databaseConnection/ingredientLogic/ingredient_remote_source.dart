import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';

abstract class IngredientRemoteSource {
  Future<Ingredient?> getIngredientById(String ingredientId);
  Future<List<Ingredient>> searchIngredientsByName(String query);
}