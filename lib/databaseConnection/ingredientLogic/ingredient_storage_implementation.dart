import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';
import 'package:app/databaseConnection/ingredientLogic/ingredient_remote_source.dart';
import 'package:app/databaseConnection/ingredientLogic/ingredient_storage.dart';

class IngredientStorageImplementation implements IngredientStorage {

  static final IngredientStorageImplementation _instance = IngredientStorageImplementation._internal();

  IngredientStorageImplementation._internal();

  factory IngredientStorageImplementation() {
    return _instance;
  }

  static IngredientRemoteSource? _remoteDataSourceInstance; 

  static void initialize(IngredientRemoteSource remoteDataSource) {
    _remoteDataSourceInstance = remoteDataSource;
  }

  IngredientRemoteSource get _remoteDataSource {
    if (_remoteDataSourceInstance == null) {
      throw Exception('OpenFoodFactsHandler not initialized. Call initialize() first.');
    }
    return _remoteDataSourceInstance!;
  }


  final Map<String, Ingredient?> _ingredientCache = {};
  final Map<String, List<Ingredient>> _searchCache = {};

  @override
  Future<Ingredient?> getIngredient(String ingredientId) async {
    if (_ingredientCache.containsKey(ingredientId)) {
      return _ingredientCache[ingredientId];
    }
    final ingredient = await _remoteDataSource.getIngredientById(ingredientId);
    if (ingredient != null) {
      _ingredientCache[ingredientId] = ingredient;
    }
    return ingredient;
  }

  @override
  Future<List<Ingredient>> searchIngredients(String query) async {
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!;
    }
    final ingredients = await _remoteDataSource.searchIngredientsByName(query);
    _searchCache[query] = ingredients;
    return ingredients;
  }
}