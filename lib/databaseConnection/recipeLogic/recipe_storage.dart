import 'package:app/databaseConnection/recipeLogic/import_recipe.dart';
import 'package:app/databaseConnection/recipeLogic/import_comment.dart';

abstract class RecipeStorage {
  Future<void> addRecipe(Recipe recipe);
  Future<List<Recipe>> getUserRecipes(String userId);
  Future<Recipe?> getRecipeById(String recipeId);
  Future<void> updateRecipe(String recipeId, Recipe updatedRecipe);
  Future<void> removeRecipe(String recipeId);
  Future<List<Recipe>> getAllRecipes();
  Future<void> removeLike(String recipeId, String userId);
  Future<void> addLike(String recipeId, String userId);
  Future<void> removeSave(String recipeId, String userId);
  Future<void> addSave(String recipeId, String userId);
  Future<void> addComment(String recipeId, Comment comment);
  Future<void> removeComment(String recipeId, int index);

}