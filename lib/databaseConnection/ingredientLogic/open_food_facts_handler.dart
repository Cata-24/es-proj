import 'package:http/http.dart' as http;
import 'package:app/databaseConnection/ingredientLogic/ingredient_remote_source.dart';
import 'dart:convert';
import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';

class OpenFoodFactsHandler implements IngredientRemoteSource {

  static final OpenFoodFactsHandler _instance = OpenFoodFactsHandler._internal();

  OpenFoodFactsHandler._internal();

  factory OpenFoodFactsHandler() {
    return _instance;
  }

  static http.Client? _clientInstance; 

  static void initialize(http.Client client) {
    _clientInstance = client;
  }

  http.Client get _client {
    if (_clientInstance == null) {
      throw Exception('OpenFoodFactsHandler not initialized. Call initialize() first.');
    }
    return _clientInstance!;
  }

  @override  
  Future<Ingredient?> getIngredientById(String ingredientId) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$ingredientId.json&fields=code,generic_name_en,product_name_en,product_name,generic_name,generic_name_fr,product_name_fr,image_url,nutriments');

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final product = data['product'];

        if (product == null) return null;

        final ingr = Ingredient.fromOpenFoodFactsJson(product);

        return ingr;
      }
    } catch (e) {
      print('Error fetching from OpenFoodFacts: $e');
    }
    return null;
  }

  @override
  Future<List<Ingredient>> searchIngredientsByName(String query) async {
    
    final url = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&fields=code,generic_name_en,product_name_en,product_name,generic_name,generic_name_fr,product_name_fr,image_url,nutriments&page_size=1000',
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final products = data['products'] as List<dynamic>;

        final ingredients = products.map((product) {
          try {
            return Ingredient.fromOpenFoodFactsJson(product as Map<String, dynamic>);
          } catch (e) {
            return null;
          }
        }).whereType<Ingredient>().toList();

        return ingredients;
      }
    } catch (e) {
      print('Error searching ingredients: $e');
    }

    return [];
  }
}