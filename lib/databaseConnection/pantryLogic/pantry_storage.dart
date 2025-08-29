import 'package:app/databaseConnection/pantryLogic/import_pantry.dart';
import 'package:app/widgets/pantry/pantry_item.dart';

abstract class PantryStorage {
  Future<Pantry?> getUserPantry(String userId);
  Future<void> addItemToPantry(String userId, DateTime expireDate, String ingredientId, int weight, DateTime notificationDate);
  Future<void> removeItemFromPantry(String userId, int index);
  Future<List<PantryItem>> getUserPantryItems(String userId);
  Future<void> updateUserPantry(String userId, Pantry pantry);
}