import 'package:app/databaseConnection/ingredientLogic/open_food_facts_handler.dart';
import 'package:app/databaseConnection/recipeLogic/recipe_storage_implementation.dart';
import 'package:app/widgets/common/throbber.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/databaseConnection/recipeLogic/import_recipe.dart';
import 'package:app/user/user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:app/databaseConnection/ingredientLogic/import_ingredient.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  
  const AddRecipeScreen({super.key, this.recipe});

  @override
  AddRecipeScreenState createState() => AddRecipeScreenState();
}

class AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _recipeIdController;
  late TextEditingController _nameController;
  late TextEditingController _prepTimeController;
  late TextEditingController _createdAtController;
  late TextEditingController _difficultyController = TextEditingController(text: '0');
  late String _imagePath = widget.recipe?.imageUrl ?? ''; // Assuming this is meant to store the image file path
  late String _selectedDifficulty; // Add this variable to store the selected difficulty
  late List<TextEditingController> _ingredientsController;
  late List<TextEditingController> _quantitiesController;
  late List<TextEditingController> _ingredientIds;
  late TextEditingController _likesController;
  late TextEditingController _servingsController;
  late List<TextEditingController> _stepController;
  late TextEditingController _userIdController;
  bool _isSearching = false;
  List<Ingredient> ingredientList = [];
 

  Future<String> _getRecipeId() async {
    final recipeId = widget.recipe?.recipeId;
    if (recipeId != null) {
      return recipeId;
    } else {
      final docRef = FirebaseFirestore.instance.collection('recipe').doc();
      return docRef.id;
    }
  }
  @override
void initState() {
  super.initState();

  _nameController = TextEditingController(text: widget.recipe?.name ?? '');
  _prepTimeController = TextEditingController(
      text: widget.recipe?.prepTime != null ? widget.recipe!.prepTime.toString() : '');
  _servingsController = TextEditingController(
      text: widget.recipe?.servings != null ? widget.recipe!.servings.toString() : '');
  _difficultyController = TextEditingController(
      text: widget.recipe?.difficulty != null ? widget.recipe!.difficulty.toString() : '0');
  _ingredientsController = [];
  _quantitiesController = [];
  _stepController = [];
  if (widget.recipe?.ingredients != null) {
  for (var ingredient in widget.recipe!.ingredients) {
    if (ingredient.length >= 2) {
      _ingredientsController.add(TextEditingController(text: ingredient['id'] ?? ''));
      _quantitiesController.add(TextEditingController(text: ingredient['quantity'] ?? ''));
    } else {
      _ingredientsController.add(TextEditingController());
      _quantitiesController.add(TextEditingController());
    }
  }
} else {
  _ingredientsController.add(TextEditingController());
  _quantitiesController.add(TextEditingController());
}
  if (widget.recipe?.steps != null) {
    for (var step in widget.recipe!.steps) {
      _stepController.add(TextEditingController(text: step));
    }
  } else {
    _stepController.add(TextEditingController());
  }
}
  
  @override
  void dispose() {
    _nameController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    for (var controller in _ingredientsController) {
      controller.dispose();
    }
    for (var controller in _quantitiesController) {
      controller.dispose();
    }

    for (var controller in _stepController) {
      controller.dispose();
    }
    super.dispose();
  }

void saveRecipe() async {
  if (_formKey.currentState!.validate()) {
    String prepTime = _prepTimeController.text.trim();
    int portions = int.parse(_servingsController.text);

    List<Map<String, String>> ingredients = [];
    for (int i = 0; i < _quantitiesController.length; i++) {
      String id = _ingredientsController[i].text.trim();
      String quantity = _quantitiesController[i].text.trim();
      if (id.isNotEmpty && quantity.isNotEmpty) {
        ingredients.add({
          'id': id,
          'quantity': quantity,
        });
      }
    }

    List<String> steps = _stepController
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    if (int.parse(prepTime) <= 0) {
      Navigator.pop(context, null);
      return;
    }

    final recipe = Recipe(
      recipeId: await _getRecipeId(),
      name: _nameController.text.trim(),
      prepTime: int.parse(prepTime),
      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      difficulty: int.parse(_difficultyController.text),
      imageUrl: _imagePath,
      ingredients: ingredients,
      likes: widget.recipe?.likes ?? 0,
      servings: portions,
      steps: steps,
      userId: UserSession().userId ?? 'unknown',
      trackLikes: widget.recipe?.trackLikes ?? [],
      saves: widget.recipe?.saves ?? [],
      comments: widget.recipe?.comments ?? [],
    );

    try {
      if (widget.recipe == null) {
        await RecipeStorageImplementation().addRecipe(recipe);
      } else {
        await RecipeStorageImplementation().updateRecipe(recipe.recipeId, recipe);
      }

      if (mounted) {
        Navigator.pop(context, recipe);
      }
    } catch (e) {
      print('Error saving recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save recipe')),
      );
    }
  }
}
  void _removeRecipe(String recipeId) async {
  try {
    await RecipeStorageImplementation().removeRecipe(recipeId);

    Navigator.pop(context, "removed");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe removed successfully")),
    );
    setState(() {});
  } catch (e) {
    print('Error removing recipe: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to remove recipe")),
    );
  }
}
Future<String> uploadImage(String path, XFile image) async {
  try {
    final ref = FirebaseStorage.instance.ref(path);

    final Uint8List imageData = await image.readAsBytes();

    String contentType = 'application/octet-stream';
    if (image.name.toLowerCase().endsWith('.jpg') || image.name.toLowerCase().endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else if (image.name.toLowerCase().endsWith('.png')) {
      contentType = 'image/png';
    }

    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(imageData, metadata);

    final url = await ref.getDownloadURL();
    return url;
  } on FirebaseException catch (e) {
    print('FirebaseException during upload: ${e.message}');
    rethrow;
  } on FormatException catch (e) {
    throw Exception('Format error: ${e.message}');
  } catch (e) {
    print('Generic error during upload: $e');
    throw Exception('Something went wrong: $e');
  }
}

void _pickAndUploadImage() async {
  final ImagePicker picker = ImagePicker();

  final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading image...')),
      );

      final String imagePath = 'recipes/${DateTime.now().millisecondsSinceEpoch}_${pickedImage.name}';
      final String imageUrl = await uploadImage(imagePath, pickedImage);

      setState(() {
        _imagePath = imageUrl;
      });

      print('Stored _imagePath: $_imagePath');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No image selected.')),
    );
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(widget.recipe == null ? 'Add Recipe' : 'Edit Recipe'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Recipe Image Section
              const Text(
                  "Recipe Image",
                  style: TextStyle( fontSize: 16),
                ),
                const SizedBox(height: 8),
                Center(
                  child: (widget.recipe?.imageUrl != null && widget.recipe!.imageUrl.isNotEmpty) || _imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imagePath.isNotEmpty ? _imagePath : widget.recipe!.imageUrl,
                            height: 180,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.red),
                              );
                            },
                          ),
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickAndUploadImage,
                  icon: const Icon(Icons.upload),
                  label: const Text("Pick and Upload Image"),
                ),
                const SizedBox(height: 10),

              // Recipe Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a recipe name' : null,
              ),
              const SizedBox(height: 10),

              // Preparation Time
              TextFormField(
                controller: _prepTimeController,
                decoration: const InputDecoration(labelText: 'Preparation Time (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null ||
                        int.parse(value) <= 0
                    ? 'Enter a valid preparation time'
                    : null,
              ),
              const SizedBox(height: 10),

              // Difficulty Selector
              buildDifficultySelector(),
              const SizedBox(height: 10),

              // Servings
              TextFormField(
                controller: _servingsController,
                decoration: const InputDecoration(labelText: 'Servings'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null ||
                        int.parse(value) <= 0
                    ? 'Enter a valid number of servings'
                    : null,
              ),
              const SizedBox(height: 10),
               // Ingredients Section
              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if(_ingredientsController.isEmpty)
                const Text("No ingredients added yet."),
              const SizedBox(height: 8),
              for (int i = 0; i < _ingredientsController.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TypeAheadFormField<Ingredient>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: _ingredientsController[i],
                          decoration: const InputDecoration(
                            hintText: 'Ingredient',
                          ),
                        ),
                        suggestionsCallback: (query) async {
                          if (query.isEmpty) return [];

                          Future.microtask(() {
                            if (mounted) setState(() => _isSearching = true);
                          });

                          final suggestions = await OpenFoodFactsHandler().searchIngredientsByName(query);

                          Future.microtask(() {
                            if (mounted) {
                              setState(() {
                                ingredientList = suggestions;
                                _isSearching = false;
                              });
                            }
                          });

                          return suggestions;
                        },
                        itemBuilder: (context, Ingredient suggestion) {
                          return ListTile(
                            title: Text(suggestion.name),
                          );
                        },
                        noItemsFoundBuilder: (context) {
                          if (_isSearching) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Throbber(),
                                ),
                              ),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No ingredients found.'),
                            );
                          }
                        },
                        onSuggestionSelected: (Ingredient suggestion) {
                          setState(() {
                            _ingredientsController[i].text = suggestion.name;
                            _ingredientIds[i].text = suggestion.ingredientId;
                          });
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter an ingredient' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ingredient Quantity Input
                    Expanded(
                      child: TextFormField(
                        controller: _quantitiesController[i],
                        decoration: const InputDecoration(
                          hintText: 'Quantity',
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter a quantity' : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[800]),
                      onPressed: () {
                        setState(() {
                          _ingredientsController.removeAt(i);
                          _quantitiesController.removeAt(i);
                          _ingredientIds.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _ingredientsController.add(TextEditingController());
                    _quantitiesController.add(TextEditingController());
                    _ingredientIds.add(TextEditingController());
                  });
                },
                child: const Text("Add Ingredient"),
              ),
              const SizedBox(height: 10),

              // Steps Section
              const Text(
                "Steps",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _stepController.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stepController[i],
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Step ${i + 1}',
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter a step' : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[800]),
                      onPressed: () {
                        setState(() {
                          _stepController.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _stepController.add(TextEditingController());
                  });
                },
                child: const Text("Add Step"),
              ),
              const SizedBox(height: 20),
              Center(child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red[800]),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Recipe"),
                      content: const Text("Are you sure you want to delete this recipe?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    _removeRecipe(widget.recipe!.recipeId);
                  }
                },
              ),
              ),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: saveRecipe,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget buildDifficultySelector() {
    double currentValue = double.tryParse(_difficultyController.text) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Difficulty (0-5): ${currentValue.toInt()}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Slider(
          value: currentValue,
          min: 0,
          max: 5,
          divisions: 5,
          label: currentValue.toInt().toString(),
          onChanged: (value) {
            setState(() {
              _difficultyController.text = value.toInt().toString();
            });
          },
        )
      ],
    );
  }


  Widget buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < _ingredientsController.length; i++)
          Row(
            children: [
              // Ingredient name input
              Expanded(
                child: TextField(
                  controller: _ingredientsController[i],
                  decoration: const InputDecoration(
                    hintText: 'Ingredient',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Ingredient quantity input
              Expanded(
                child: TextField(
                  controller: _quantitiesController[i],
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _ingredientsController.removeAt(i);
                    _quantitiesController.removeAt(i);
                  });
                },
              ),
            ],
          ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _ingredientsController.add(TextEditingController());
              _quantitiesController.add(TextEditingController());
            });
          },
          child: const Text("Add Ingredient"),
        ),
      ],
    );
  }

  Widget buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Steps",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < _stepController.length; i++)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stepController[i],
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Step ${i + 1}',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _stepController.removeAt(i);
                  });
                },
              ),
            ],
          ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _stepController.add(TextEditingController());
            });
          },
          child: const Text("Add Step"),
        ),
      ],
    );
  }
  
  Widget iconWithText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }

  /*Widget buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Image.asset(
        _imagePath,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }*/


Widget buildHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text.isNotEmpty ? _nameController.text : "New Recipe",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  iconWithText(Icons.emoji_emotions, _difficultyController.text),
                  iconWithText(Icons.access_time, _prepTimeController.text),
                  iconWithText(Icons.people, _servingsController.text),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: const [
            Icon(Icons.favorite_border),
            Icon(Icons.bookmark_border),
            Icon(Icons.share),
          ],
        ),
      ],
    ),
  );
}
Widget buildContent() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ingredients Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < _ingredientsController.length; i++)
                Row(
                  children: [
                    // Ingredient Name Input
                    Expanded(
                      child: TextField(
                        controller: _ingredientsController[i],
                        decoration: const InputDecoration(
                          hintText: 'Ingredient',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ingredient Quantity Input
                    Expanded(
                      child: TextField(
                        controller: _quantitiesController[i],
                        decoration: const InputDecoration(
                          hintText: 'Quantity',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ingredientsController.removeAt(i);
                          _quantitiesController.removeAt(i);
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _ingredientsController.add(TextEditingController());
                    _quantitiesController.add(TextEditingController());
                  });
                },
                child: const Text("Add Ingredient"),
              ),
            ],
          ),
        ),

        // Divider
        Container(width: 1, color: Colors.black),

        // Steps Section
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Steps",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _stepController.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _stepController[i],
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Step ${i + 1}',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _stepController.removeAt(i);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _stepController.add(TextEditingController());
                    });
                  },
                  child: const Text("Add Step"),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
}