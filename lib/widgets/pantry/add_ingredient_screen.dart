import 'package:app/databaseConnection/ingredientLogic/ingredient_storage_implementation.dart';
import 'package:app/databaseConnection/ingredientLogic/open_food_facts_handler.dart';
import 'package:app/widgets/common/throbber.dart';
import 'package:flutter/material.dart';
import "package:app/widgets/pantry/pantry_item.dart";
import "package:app/databaseConnection/ingredientLogic/import_ingredient.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:app/services/firebase_notification_service.dart';


class AddIngredientPage extends StatefulWidget {
  final PantryItem? ingredient;

  const AddIngredientPage({super.key, this.ingredient});

  @override
  AddIngredientPageState createState() => AddIngredientPageState();
}

class AddIngredientPageState extends State<AddIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _caloriesController;
  late TextEditingController _expireDateController;
  late TextEditingController _notificationDateController;
  late String _imagePath;
  late String _ingredientCode = "";
  List<Ingredient> ingredientList = [];
  bool _isSearching = false;
  bool _hasError = false;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    String? name = widget.ingredient?.name ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = name;
    });
    _weightController =
        TextEditingController(text: widget.ingredient?.weight.toString() ?? '');
    _caloriesController = TextEditingController(
        text: widget.ingredient?.calories.toString() ?? '');
    _expireDateController = TextEditingController(
        text: widget.ingredient?.expireDate.toLocal().toString().split(
            ' ')[0] ?? '');
    _notificationDateController = TextEditingController(
        text: widget.ingredient?.notificationDate.toString() ?? '');
    _imagePath = widget.ingredient?.imagePath ?? '';
    _ingredientCode = widget.ingredient?.ingredientId ?? '';
  }

  void _saveIngredient() async {
    if (_formKey.currentState!.validate()) {
      String ingredientName = _nameController.text.trim();

      if (_ingredientCode.isEmpty) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please select a valid ingredient from the suggestions.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Ingredient? selectedIngredient = await OpenFoodFactsHandler().getIngredientById(_ingredientCode);

      if (!mounted) return;

      if (selectedIngredient == null) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ingredient not found in the list!$_ingredientCode',),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (ingredientName != selectedIngredient.name) {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please select a valid ingredient from the suggestions.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      int weight = int.parse(_weightController.text);
      int calories = int.parse(_caloriesController.text);
      DateTime expireDate = DateTime.parse(_expireDateController.text);
      DateTime notificationDate = DateTime.parse(_notificationDateController.text);


      final firebaseNotificationService = FirebaseNotificationService();
      firebaseNotificationService.scheduleNotification(selectedIngredient, notificationDate);
      
      if (weight <= 0 || calories < 0) {
        setState(() => _hasError = true);
        Navigator.pop(context, null);
        return;
      }

      Navigator.pop(context, {
        'name': ingredientName,
        'imagePath': _imagePath,
        'weight': weight,
        'calories': calories,
        'expireDate': expireDate,
        'id': _ingredientCode,
        'notificationDate': notificationDate,
      });
    } else {
      setState(() => _hasError = true);
    }
  }

  void _removeIngredient() {
    Navigator.pop(context, "removed");
  }

  Future<void> _selectExpireDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _expireDateController.text =
        pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _selectNotificationDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _notificationDateController.text =
        pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Widget _buildRemoveButton() {
    if (widget.ingredient == null) {
      return SizedBox.shrink();
    }

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
          textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 8,
        ),
        onPressed: _removeIngredient,
        child: const Text('Remove'),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Color(0xFF006400),
          centerTitle: true,
          title: Text(
            widget.ingredient == null ? 'Add Ingredient' : 'Edit Ingredient',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23,
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* corrigi isto porque na versao 5.0.0 e acima do flutter_typeahead
                 o TypeAheadFormField e textFieldConfiguration foram trocados
                 se der erro, trocar no pubspec.yaml
                 flutter_typeahead: ^5.x.x para flutter_typeahead: ^4.8.0
              */
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("Searching...",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                  TypeAheadFormField<Ingredient>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Ingredient Name',
                        labelStyle: TextStyle(fontSize: 22),
                      ),
                      style: TextStyle(fontSize: 22),
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
                        leading: suggestion.imagePath.isNotEmpty
                            ? Image.network(suggestion.imagePath, width: 40,
                            height: 40,
                            fit: BoxFit.cover)
                            : const Icon(Icons.food_bank),
                        title: Text(suggestion.name),
                        subtitle: Text('${suggestion.calories.toStringAsFixed(
                            0)} kcal'),
                      );
                    },
                    onSuggestionSelected: (Ingredient suggestion) {
                      setState(() {
                        _nameController.text = suggestion.name;
                        _caloriesController.text = suggestion.calories
                            .toString();
                        _imagePath = suggestion.imagePath;
                        _ingredientCode = suggestion.ingredientId;
                      });
                    },
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter a name'
                        : null,
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (g)',
                  labelStyle: TextStyle(fontSize: 22),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 0.0),
                ),
                style: const TextStyle(fontSize: 22),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty || int.tryParse(value) == null ||
                    int.parse(value) <= 0
                    ? 'Enter a valid weight'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _expireDateController,
                decoration: const InputDecoration(
                  labelText: 'Expire Date',
                  labelStyle: TextStyle(fontSize: 22),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 0.0),
                ),
                style: const TextStyle(fontSize: 22),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter a valid expire date';
                  }
                  DateTime? expireDate = DateTime.tryParse(value);
                  if (expireDate == null ||
                      expireDate.isBefore(DateTime.now())) {
                    return 'Date must be today or later';
                  }
                  return null;
                },
                readOnly: true,
                onTap: () async => await _selectExpireDate(context),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notificationDateController,
                decoration: const InputDecoration(
                  labelText: 'Notification Date',
                  labelStyle: TextStyle(fontSize: 22),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 0.0),
                ),
                style: const TextStyle(fontSize: 22),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a notification date';
                  }

                  final notificationDate = DateTime.tryParse(value);
                  final expireDate = DateTime.tryParse(
                      _expireDateController.text);

                  if (notificationDate == null || expireDate == null) {
                    return 'Invalid date';
                  }

                  if (notificationDate.isBefore(DateTime.now())) {
                    return 'Notification date must be in the future';
                  }

                  if (notificationDate.isAfter(expireDate)) {
                    return 'Notification date must be before the expiration date';
                  }

                  return null;
                },
                readOnly: true,
                onTap: () async => await _selectNotificationDate(context),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _saveIngredient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasError ? Colors.red[800] : Colors.green[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 45, vertical: 20),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                  ),
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 10),
              _buildRemoveButton(),
            ],
          ),
        ),
      ),
    );
  }
}