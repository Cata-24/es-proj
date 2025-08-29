import 'package:app/databaseConnection/firestore_source.dart';
import 'package:app/databaseConnection/ingredientLogic/ingredient_storage.dart';
import 'package:app/databaseConnection/pantryLogic/pantry_storage.dart';
import 'package:app/databaseConnection/pantryLogic/import_pantry.dart';
import 'package:app/widgets/pantry/pantry_item.dart';

class PantryStorageImplementation implements PantryStorage {

    
  static final PantryStorageImplementation _instance = PantryStorageImplementation._internal();

  PantryStorageImplementation._internal();

  factory PantryStorageImplementation() {
    return _instance;
  }

  static FirestoreSource? _firestoreSourceInstance; 
  static IngredientStorage? _ingredientStorageInstance; 

  static void initialize(FirestoreSource firestoreSource, IngredientStorage ingredientStorage) {
    _firestoreSourceInstance = firestoreSource;
    _ingredientStorageInstance = ingredientStorage;
  }

  FirestoreSource get _firestoreSource {
    if (_firestoreSourceInstance == null) {
      throw Exception('OpenFoodFactsHandler not initialized. Call initialize() first.');
    }
    return _firestoreSourceInstance!;
  }

  IngredientStorage get _ingredientStorage {
    if (_ingredientStorageInstance == null) {
      throw Exception('OpenFoodFactsHandler not initialized. Call initialize() first.');
    }
    return _ingredientStorageInstance!;
  }

  @override
  Future<Pantry?> getUserPantry(String userId) async {
    try {
      final querySnapshot = await _firestoreSource.getDocumentsByQuery('pantry', field: 'userId', value: userId);
      if (querySnapshot.docs.isEmpty) return null;
      return Pantry.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addItemToPantry(String userId, DateTime expireDate, String ingredientId, int weight, DateTime notificationDate) async {
    final pantry = await getUserPantry(userId);
    notificationDate = notificationDate; 

    if (pantry == null) {
      final newPantry = Pantry([expireDate], [ingredientId], userId, [weight], [notificationDate]);
      await _firestoreSource.addDocument('pantry', Pantry.toMap(newPantry));
    } else {
      pantry.addItem(expireDate, ingredientId, weight, notificationDate);
      final snapshot = await _firestoreSource.getDocumentsByQuery('pantry', field: 'userId', value: userId);
      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await _firestoreSource.updateDocument('pantry', docId,Pantry.toMap(pantry));
      }
    }
  }

  @override
  Future<List<PantryItem>> getUserPantryItems(String userId) async {
    final pantry = await getUserPantry(userId);
    if (pantry == null) {
      return [];
    }

    List<PantryItem> result = [];
    for (int i = 0; i < pantry.ingredientIds.length; i++) {
      final id = pantry.ingredientIds[i];
      final ingredient = await _ingredientStorage.getIngredient(id);

      if (ingredient != null) {
        final notificationDate = pantry.notificationDates.length > i
            ? pantry.notificationDates[i]
            : pantry.expireDates[i];

        result.add(PantryItem(
          ingredientId: id,
          name: ingredient.name,
          imagePath: ingredient.imagePath,
          weight: pantry.weights[i],
          calories: ingredient.calories,
          expireDate: pantry.expireDates[i],
          notificationDate: notificationDate,
          index: i,
        ));
      }
    }
    return result;
  }

  @override
  Future<void> removeItemFromPantry(String userId, int index) async {
    try {
      final pantry = await getUserPantry(userId);
      if (pantry == null) {
        print('Pantry not found for user: $userId. Cannot remove item.');
        return;
      }

      if (index < 0 || index >= pantry.ingredientIds.length) {
        print('Invalid index $index for pantry removal. Pantry has ${pantry.ingredientIds.length} items.');
        return;
      }

      pantry.removeItemAt(index);

      final snapshot = await _firestoreSource.getDocumentsByQuery('pantry', field: 'userId', value: userId);

      final docId = snapshot.docs.first.id;
      await _firestoreSource.updateDocument('pantry', docId, Pantry.toMap(pantry));
    } catch (e) {
      print('Error removing item from pantry: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserPantry(String userId, Pantry pantry) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery('pantry', field: 'userId', value: userId);

      if (snapshot.docs.isEmpty) {
        return;
      }

      final docId = snapshot.docs.first.id;
      await _firestoreSource.updateDocument('pantry',docId,Pantry.toMap(pantry));
    } catch (e) {
      print('Error updating user pantry: $e');
      rethrow;
    }
  }
  
}