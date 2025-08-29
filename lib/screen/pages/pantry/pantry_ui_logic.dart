import 'package:app/databaseConnection/pantryLogic/pantry_storage.dart';
import 'package:app/databaseConnection/pantryLogic/pantry_storage_implementation.dart';
import 'package:app/user/user_session.dart';
import 'package:app/widgets/pantry/pantry_item.dart';

class PantryUILogic {
  final PantryStorage _pantryStorage;
  final UserSession _userSession;

  PantryUILogic({
    PantryStorage? pantryStorage,
    UserSession? userSession,
  })  : _pantryStorage = pantryStorage ?? PantryStorageImplementation(),
        _userSession = userSession ?? UserSession();

  Future<List<PantryItem>> fetchPantryItems() async {
    final userId = _userSession.userId;
    if (userId == null) {
      print("Error: User ID is null. Cannot fetch pantry items.");
      return [];
    }
    List<PantryItem>? pantry = await _pantryStorage.getUserPantryItems(userId);
    return pantry ?? [];
  }

  Future<PantryItem?> addNewIngredient(Map<String, dynamic> newIngredientData) async {
    final userId = _userSession.userId;
    if (userId == null) {
      print("Error: User ID is null. Cannot add ingredient.");
      return null;
    }

    if (newIngredientData['weight'] <= 0) {
      print("Error: Weight must be greater than 0.");
      return null;
    }

    final ingredientId = newIngredientData['id'];
    if (ingredientId == null || ingredientId.isEmpty) {
      print("Error: Failed to add ingredient: no ID returned.");
      return null;
    }

    try {
      final newPantryItem = PantryItem(
        ingredientId: ingredientId,
        name: newIngredientData['name'],
        imagePath: newIngredientData['imagePath'],
        weight: newIngredientData['weight'],
        calories: newIngredientData['calories'],
        expireDate: newIngredientData['expireDate'],
        notificationDate: newIngredientData['notificationDate'],
        index: -1,
      );

      await _pantryStorage.addItemToPantry(
        userId,
        newIngredientData['expireDate'],
        ingredientId,
        newIngredientData['weight'],
        newIngredientData['notificationDate'],
      );
      return newPantryItem;
    } catch (e) {
      print("Failed to add ingredient: $e");
      return null;
    }
  }

  Future<bool> removeIngredient(int index) async {
    final userId = _userSession.userId;
    if (userId == null) {
      print("Error: User ID is null. Cannot remove ingredient.");
      return false;
    }

    try {
      await _pantryStorage.removeItemFromPantry(userId, index);
      return true;
    } catch (e) {
      print("Failed to remove ingredient from pantry: $e");
      return false;
    }
  }

  Future<bool> editIngredient(int index, Map<String, dynamic> updatedIngredientData) async {
    final userId = _userSession.userId;
    if (userId == null) {
      print("Error: User ID is null. Cannot edit ingredient.");
      return false;
    }

    final pantry = await _pantryStorage.getUserPantry(userId);
    if (pantry == null) {
      print("Error: Pantry not found for user.");
      return false;
    }

    try {
      final String oldIngredientId = pantry.ingredientIds[index];
      final String newIngredientId = updatedIngredientData['id'];

      if (newIngredientId == null || newIngredientId.isEmpty) {
        print("Error: Ingredient ID cannot be empty.");
        return false;
      }

      if (newIngredientId != oldIngredientId) {
        pantry.removeItemAt(index);
        pantry.insertItemAt(index, updatedIngredientData['expireDate'], newIngredientId, updatedIngredientData['weight'], updatedIngredientData['notificationDate']);
      } else {
        pantry.updateItemAt(index, updatedIngredientData['expireDate'], newIngredientId, updatedIngredientData['weight'], updatedIngredientData['notificationDate']);
      }
      await _pantryStorage.updateUserPantry(userId, pantry);
      return true;
    } catch (e) {
      print("Failed to update ingredient: $e");
      return false;
    }
  }
}