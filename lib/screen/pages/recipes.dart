import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';
import 'package:app/databaseConnection/recipeLogic/recipe_storage_implementation.dart';
import 'package:app/widgets/add_recipe_screen.dart';
import 'package:app/widgets/common/throbber.dart';
import 'package:app/widgets/recipe_preview.dart';
import 'package:app/widgets/recipe_nav_bar.dart';
import 'package:app/widgets/recipe_screen.dart';
import 'package:app/widgets/filters.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/base_page.dart';
import 'package:app/databaseConnection/recipeLogic/import_recipe.dart';
import 'package:app/services/auth_service.dart';

class RecipesPage extends BasePage {
  RecipesPage({super.key})
      : super(
          title: 'Recipes',
          backgroundColor: const Color.fromARGB(255, 200, 230, 201),
          buildChild: (context) => RecipesContent(),
        );
}

class RecipesContent extends StatefulWidget {
  const RecipesContent({super.key});

  @override
  RecipesContentState createState() => RecipesContentState();
}

class RecipesContentState extends State<RecipesContent>{
  Set<String> selectedIngredients = {};
  final TextEditingController _searchController = TextEditingController();
  String search = "";
  bool showFilters = false;

  void _recipeScreen(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
    );

    if (result == 'refresh') {
      setState(() {
      });
    }

  }

  void toggleFilters() {
    setState(() {
      showFilters = !showFilters;
    });
  }

  void toggleIngredient(String ingredient, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedIngredients.add(ingredient);
      } else {
        selectedIngredients.remove(ingredient);
      }
    });
  }

  int _navIndex = 0;
  void NavBarToggle(int index) {
    setState(() {
      search = "";
      _navIndex = index;
    });
    _searchController.clear();
  }

  Future<List<Recipe>> getRecipesNav(List<Recipe> recipes) async {
    final authService = AuthService();
    final userId = authService.uid;
    if (_navIndex == 1) {
      List<Recipe> filtered = [];
      for (Recipe recipe in recipes) {
        if (recipe.saves.contains(userId)) filtered.add(recipe);
      }
      recipes = filtered;
    } else if (_navIndex == 2) {
      List<Recipe> filtered = [];
      for (Recipe recipe in recipes) {
        if (recipe.userId == userId) filtered.add(recipe);
      }
      recipes = filtered;
    }

    return recipes;
  }

  Future<bool> containsSelected(Recipe recipe) async {
  for (String selectedName in selectedIngredients) {
    bool found = false;
    for (Map<String, dynamic> ingredient in recipe.ingredients) {
      if (ingredient.containsKey('id') && ingredient['id'] == selectedName) {
        found = true;
        break;
      }
    }
    if (!found) {
      
      return false;
    }
  }
  return true;
}

  void _addRecipeScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRecipeScreen()),
    );
  }

  Future<List<Recipe>> getRecipes() async{
    List<Recipe> recipes = await RecipeStorageImplementation().getAllRecipes();
    recipes = await getRecipesNav(recipes);
    List<Recipe> filteredRecipes = [];

    for (Recipe recipe in recipes) {
      bool isSelected = await containsSelected(recipe);
      if (isSelected) {
        filteredRecipes.add(recipe);
      }
    }

    return filteredRecipes;
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
        );
      },
      child: const Icon(Icons.add),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),
    body: FutureBuilder<List<Recipe>>(
      future: getRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Throbber());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading recipes"));
        } else {
          final recipes = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SearchBar(
                          controller: _searchController,
                          padding: const WidgetStatePropertyAll(EdgeInsets.only(left: 25)),
                          leading: const Icon(Icons.search, size: 20, color: Colors.grey),
                          hintText: "Search for recipes here",
                          hintStyle: const WidgetStatePropertyAll(
                            TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                          ),
                          onSubmitted: (value) {
                      setState(() {
                        search = value;
                      });
                      _searchController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
              if (!showFilters)
                ElevatedButton(
                  onPressed: toggleFilters,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text("Show Filters"),
                    ],
                  ),
                ),
              if (showFilters)
                Filters(
                  selectedItems: selectedIngredients,
                  onIngredientToggle: toggleIngredient,
                ),
              if (showFilters)
                ElevatedButton(
                  onPressed: toggleFilters,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close),
                      SizedBox(width: 8),
                      Text("Hide Filters"),
                    ],
                  ),
                ),
              RecipeNavBar(onNavSellect: NavBarToggle, selectedIndexNow: _navIndex,),
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    if (!recipe.name.toLowerCase().contains(search.toLowerCase())) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () => _recipeScreen(recipe),
                      child: RecipePreview(
                        recipe: recipe,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    ),
  );
}
}