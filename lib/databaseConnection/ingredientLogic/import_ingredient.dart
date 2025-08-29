class Ingredient{
    int calories;
    String ingredientId;
    String name;
    String imagePath;
    
    Ingredient(this.calories, this.ingredientId, this.name, this.imagePath);

    static toMap(Ingredient ingredient){
        return{
        "calories": ingredient.calories,
        "ingredientId": ingredient.ingredientId,    
        "name": ingredient.name,
        "imagePath" : ingredient.imagePath,
        };
    }
    factory Ingredient.fromMap(Map<String, dynamic> map) {
      return Ingredient(
        map['calories'] as int, map['ingredientId'] as String, map['name'] as String, map['imagePath'] as String);
    }

  factory Ingredient.fromOpenFoodFactsJson(Map<String, dynamic> json) {
    final name = json['product_name'] ??
        json['product_name_en'] ??
        json['generic_name_en'] ??
        json['generic_name'] ??
        json['generic_name_fr'] ??
        json['product_name_fr'];

    final image = json['image_url'] ?? '';
    final kcalDouble = json['nutriments']?['energy-kcal_100g'];
    final kcal = (kcalDouble is num) ? kcalDouble.round() : -1;
    final code = json['code'];

    if (name?.isNotEmpty != true || kcal < 0 || code?.isNotEmpty != true) {
      throw FormatException('Invalid or incomplete ingredient data from OpenFoodFacts: $json');
    }
    return Ingredient(kcal, code!, name!, image);
  }
}
