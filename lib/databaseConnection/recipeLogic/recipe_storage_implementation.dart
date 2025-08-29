import 'package:app/databaseConnection/recipeLogic/recipe_storage.dart';
import 'package:app/databaseConnection/recipeLogic/import_recipe.dart';
import 'package:app/databaseConnection/recipeLogic/import_comment.dart';
import 'package:app/databaseConnection/firestore_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RecipeStorageImplementation implements RecipeStorage {

    
  static final RecipeStorageImplementation _instance = RecipeStorageImplementation._internal();

  RecipeStorageImplementation._internal();

  factory RecipeStorageImplementation() {
    return _instance;
  }

  static FirestoreSource? _firestoreSourceInstance; 

  static void initialize(FirestoreSource firestoreSource) {
    _firestoreSourceInstance = firestoreSource;
  }

  FirestoreSource get _firestoreSource {
    if (_firestoreSourceInstance == null) {
      throw Exception('FirestoreSource not initialized. Call initialize() first.');
    }
    return _firestoreSourceInstance!;
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _firestoreSource.addDocument('recipe', recipe.toMap());
    } catch (e) {
      print('Error adding recipe: $e');
    }
  }

  @override
  Future<List<Recipe>> getUserRecipes(String userId) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'userId',
        value: userId,
      );

      return snapshot.docs.map((doc) => Recipe.fromMap(doc.data() as Map<String,dynamic>)).toList();
    } catch (e) {
      print('Error fetching recipe: $e');
      return [];
    }
  }

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return null;

      return Recipe.fromMap(snapshot.docs.first.data() as Map<String,dynamic>);
    } catch (e) {
      print('Error fetching recipe by ID: $e');
      return null;
    }
  }

  @override
  Future<void> updateRecipe(String recipeId, Recipe updatedRecipe) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;
      await _firestoreSource.updateDocument(
        'recipe',
        docId,
        updatedRecipe.toMap(),
      );
    } catch (e) {
      print('Error updating recipe: $e');
    }
  }

  @override
  Future<void> removeRecipe(String recipeId) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;
      await _firestoreSource.deleteDocument('recipe', docId);
    } catch (e) {
      print('Error removing recipe: $e');
    }
  }

@override
Future<List<Recipe>> getAllRecipes() async {
  try {
    final querySnapshot = await _firestoreSource.getDocumentsByQuery('recipe');

    final sortedDocs = querySnapshot.docs.toList();
    sortedDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>? ?? {};
      final bData = b.data() as Map<String, dynamic>? ?? {};
      final aLikes = (aData['trackLikes'] as List?)?.length ?? 0;
      final bLikes = (bData['trackLikes'] as List?)?.length ?? 0;
      return bLikes.compareTo(aLikes);
    });

    final recipes = sortedDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final recipe = Recipe.fromMap(data);
      return recipe;
    }).toList();


    return recipes;
  } catch (e) {
    print('Error fetching recipes: $e');
    return [];
  }
}


  @override
  Future<void> removeLike(String recipeId, String userId) async {
    try {
     final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;

      await _firestoreSource.updateDocument(
        'recipe',
        docId,
        {'trackLikes': FieldValue.arrayRemove([userId])},
      );
    } catch (e) {
      print('Error removing like: $e');
    }
  }

  @override
  Future<void> addLike(String recipeId, String userId) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;


    await _firestoreSource.updateDocument(
      'recipe',
      docId,
      {'trackLikes': FieldValue.arrayUnion([userId])},
    );
    } catch (e) {
      print('Error adding like: $e');
    }
  }

  @override
  Future<void> removeSave(String recipeId, String userId) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;

    await _firestoreSource.updateDocument(
      'recipe',
      docId,
      {'saves': FieldValue.arrayRemove([userId])},
    );
    } catch (e) {
      print('Error removing save: $e');
    }
  }

  @override
  Future<void> addSave(String recipeId, String userId) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;

      await _firestoreSource.updateDocument(
        'recipe',
        docId,
        {'saves': FieldValue.arrayUnion([userId])},
      );
    } catch (e) {
      print('Error adding save: $e');
    }
  }

  @override
  Future<void> addComment(String recipeId, Comment comment) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final docId = snapshot.docs.first.id;

      await _firestoreSource.updateDocument(
        'recipe',
        docId,
        {'comments': FieldValue.arrayUnion([comment.toMap()])},
      );
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  @override
  Future<void> removeComment(String recipeId, int index) async {
    try {
      final snapshot = await _firestoreSource.getDocumentsByQuery(
        'recipe',
        field: 'recipeId',
        value: recipeId,
      );

      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final docId = doc.id;

      final data = doc.data() as Map<String, dynamic>? ?? {};
      List<dynamic> comments = data['comments'] ?? [];

      if (index >= 0 && index < comments.length) {
        comments.removeAt(index);

        await _firestoreSource.updateDocument(
          'recipe',
          docId,
          {'comments': comments},
        );
      } else {
        print('Invalid index: $index');
      }
    } catch (e) {
      print('Error removing comment: $e');
    }
  }
}