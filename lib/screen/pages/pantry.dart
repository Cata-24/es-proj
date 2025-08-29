import 'package:app/databaseConnection/pantryLogic/pantry_storage.dart';
import 'package:app/databaseConnection/pantryLogic/pantry_storage_implementation.dart';
import 'package:app/screen/pages/pantry/pantry_navigation.dart';
import 'package:app/screen/pages/pantry/pantry_ui_logic.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/base_page.dart';
import 'package:app/widgets/pantry/pantry_item.dart';
import "package:app/widgets/pantry/add_ingredient_screen.dart";
import 'package:app/widgets/ingredient_screen.dart';
import 'package:app/user/user_session.dart';
import "package:app/widgets/pantry/pantry_item_list.dart";
import "package:app/widgets/common/throbber.dart";

class PantryPage extends BasePage {
  PantryPage({super.key})
      : super(
          title: 'Pantry',
          backgroundColor: const Color.fromARGB(255, 200, 230, 201),
          buildChild: (context) => PantryContent(),
        );
}

class PantryContent extends StatefulWidget {
  const PantryContent({super.key});

  @override
  PantryContentState createState() => PantryContentState();
}

class PantryContentState extends State<PantryContent> {
  late final PantryUILogic _pantryLogic;
  List<PantryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pantryLogic = PantryUILogic(); 
    _initAsync();
  }

  Future<void> _initAsync() async {
    try {
      final fetchedItems = await _pantryLogic.fetchPantryItems();
      if (!mounted) return;
      setState(() {
        _items = fetchedItems;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _onPantryItemTap(int index) async {
    await PantryNavigation.navigateToIngredientDetails(context, _items[index]);
    await _initAsync();
  }

  void _onPantryItemEdit(int index) async {
    final result = await PantryNavigation.navigateToAddOrEditIngredient(context, ingredient: _items[index]);

    if(result == "removed"){
      final success = await _pantryLogic.removeIngredient(index);
      if (!mounted) return;

      if (success) {
        await _initAsync();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove ingredient.')),
        );
      }
    }

    if (result != null) {
      final success = await _pantryLogic.editIngredient(index, result);
      if (!mounted) return;

      if (success) {
        await _initAsync();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update ingredient.')),
        );
      }
    }
  }

  void _addNewIngredient() async {
    final result = await PantryNavigation.navigateToAddOrEditIngredient(context);

    if (result != null) {
      final newPantryItem = await _pantryLogic.addNewIngredient(result);
      if (!mounted) return;

      if (newPantryItem != null) {
        setState(() {
          newPantryItem.index = _items.length;
          _items.add(newPantryItem);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add ingredient.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading ? const Throbber() : PantryListView(items: _items,onPantryItemTap: _onPantryItemTap,onPantryItemEdit: _onPantryItemEdit, ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewIngredient,
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}