import 'package:app/databaseConnection/recipeLogic/recipe_storage_implementation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app/user/user_session.dart';
import 'package:app/widgets/loading_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:app/widgets/recipe_screen.dart';
import 'package:app/services/firebase_notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

import 'package:app/databaseConnection/firestore_source_implementation.dart';
import 'package:app/databaseConnection/ingredientLogic/open_food_facts_handler.dart';
import 'package:app/databaseConnection/ingredientLogic/ingredient_storage_implementation.dart';
import 'package:app/databaseConnection/pantryLogic/pantry_storage_implementation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final http.Client httpClient = http.Client();

  FirestoreSourceImplementation.initialize(firebaseFirestore);

  OpenFoodFactsHandler.initialize(httpClient);
  IngredientStorageImplementation.initialize(OpenFoodFactsHandler());

  PantryStorageImplementation.initialize(FirestoreSourceImplementation(), IngredientStorageImplementation());

  RecipeStorageImplementation.initialize(FirestoreSourceImplementation());

  final firebaseNotificationServiceState = FirebaseNotificationService();
  await firebaseNotificationServiceState.initialize();
  await UserSession().loadUserId();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  void _initDynamicLinks() async {

    try {
      final PendingDynamicLinkData? initialLink =
          await FirebaseDynamicLinks.instance.getInitialLink();

      if (initialLink != null) {
        _handleDeepLink(initialLink.link);
      }
    } catch (e) {
      print('[DynamicLinks] Error getting initial link: $e');
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri deepLink = dynamicLinkData.link;
      _handleDeepLink(deepLink);
    }).onError((error) {
      print('[DynamicLinks] onLink error: $error');
    });
  }

  void _handleDeepLink(Uri deepLink) async {

    final String? recipeId = deepLink.queryParameters['id'];
    if (recipeId != null) {
      final recipe = await RecipeStorageImplementation().getRecipeById(recipeId);
      if (recipe != null) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoadingScreen()),
          (Route<dynamic> route) => false,
        );
        Future.delayed(Duration(milliseconds: 1000), () {
          if(UserSession().isLoggedIn()){
            _navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipe: recipe),
              ),
            );
          }
        });
      } else {
        print('[DynamicLinks] No recipe found for ID: $recipeId');
      }
    } else {
      print('[DynamicLinks] No recipeId found in deep link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPantry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: const LoadingScreen(),
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
