import 'package:app/databaseConnection/pantryLogic/pantry_storage_implementation.dart';
import 'package:flutter/material.dart';
import "dart:async";
import 'package:app/user/user_session.dart';

class IngredientScreen extends StatefulWidget {
  final String name;
  final String imagePath;
  final int quantity;
  final int caloriesPer100g;
  final DateTime expireDate;
  final int index;

  const IngredientScreen({super.key, 
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.caloriesPer100g,
    required this.expireDate,
    required this.index
  });

  @override
  IngredientScreenState createState() => IngredientScreenState();
}

class IngredientScreenState extends State<IngredientScreen> {
  late int quantity;

  final int addDecreaseAmount = 5;
  Timer? _debounceTimer;
  final int debounceTime = 2;

  int _localWeight = 0;

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity;
    _localWeight = quantity;
  }

  void _queueUpdate(int newWeight) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(Duration(seconds: debounceTime), () async {
      final userId = UserSession().userId;

      if (userId == null) return;

      final pantry = await PantryStorageImplementation().getUserPantry(userId.toString());

      if (pantry == null){
        return;
      }

      if(!mounted) return;

      pantry.updateItemAt(widget.index, widget.expireDate, pantry.ingredientIds[widget.index], _localWeight, widget.expireDate);
      await PantryStorageImplementation().updateUserPantry(userId, pantry);
      setState(() {
        quantity = _localWeight;
      });
    });
  }

  void _updateWeight(int addDecreaseAmount) {
    int updatedWeight = _localWeight + addDecreaseAmount;
    if (updatedWeight <= 0){
      return;
    }

    setState(() {
      _localWeight = updatedWeight;
    });

    _queueUpdate(updatedWeight);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, size: 40, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 250,
            child: widget.imagePath.isNotEmpty
              ? Image.network(
                  widget.imagePath,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  Icons.image,
                  size: 100,
                  color: Colors.grey,
                ),
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center (
                  child: Text(
                    widget.name,
                      style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.green[900]),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () => _updateWeight(-addDecreaseAmount),
                    ),
                    Text(
                      '$_localWeight g',
                      style: TextStyle(fontSize: 25),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _updateWeight(addDecreaseAmount),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Center (
                  child: Text(
                    '${widget.caloriesPer100g} kcal / 100 g',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 70),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.black, size: 45),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The next product to expire has expiration date: ${widget.expireDate.day.toString().padLeft(2, '0')}/${widget.expireDate.month.toString().padLeft(2, '0')}/${widget.expireDate.year}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
