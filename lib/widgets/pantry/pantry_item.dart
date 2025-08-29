import 'package:app/databaseConnection/pantryLogic/pantry_storage_implementation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app/user/user_session.dart';

class PantryItem {
  final String name;
  final String imagePath;
  int weight;
  int calories;
  DateTime expireDate;
  DateTime notificationDate;
  final String ingredientId;

  int index;
  
  PantryItem({
    required this.name,
    required this.imagePath,
    required this.ingredientId,
    required this.weight,
    required this.calories,
    required this.expireDate,
    required this.notificationDate,
    required this.index,
  });

}


class PantryItemWidget extends StatefulWidget {
  final PantryItem item;
  final VoidCallback? onEdit;

  const PantryItemWidget({super.key, required this.item, this.onEdit});

  @override
  PantryItemWidgetState createState() => PantryItemWidgetState();
}

class PantryItemWidgetState extends State<PantryItemWidget> {
  final int addDecreaseAmount = 5;
  Timer? _debounceTimer;
  final int debounceTime = 2;

  int _localWeight = 0;

  @override
  void initState() {
    super.initState();
    _localWeight = widget.item.weight;
  }

  void _queueUpdate(int newWeight) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(seconds: debounceTime), () {
      _sendUpdate();
    });
  }
  
  
  void _sendUpdate() async {
    final userId = UserSession().userId;

    if (userId == null) return;
    final PantryStorageImplementation service = PantryStorageImplementation();
    final pantry = await service.getUserPantry(userId);

    if (pantry == null) return;

    int index = widget.item.index;
    pantry.updateItemAt(index, widget.item.expireDate, widget.item.ingredientId, _localWeight, widget.item.notificationDate);
    await service.updateUserPantry(userId, pantry);

    widget.item.weight = _localWeight;
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
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
      _sendUpdate(); 
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PantryItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.weight != widget.item.weight) {
      setState(() {
        _localWeight = widget.item.weight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black, width: 0.7)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8).copyWith(right:0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.item.imagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.item.imagePath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                )
                : const Icon(Icons.food_bank, size: 40, color: Colors.grey),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                widget.item.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            const SizedBox(width: 10),
              Row(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 15,
                      tooltip: "Remove ${addDecreaseAmount}g",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Transform.scale(
                        scale: 2,
                        child: const Icon(Icons.remove, color: Colors.red),
                      ),
                      onPressed: () => _updateWeight(-addDecreaseAmount),
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: Text(
                      "$_localWeight g",
                      key: ValueKey(_localWeight),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(50),
                      shape: BoxShape.circle),
                    child: IconButton(
                      iconSize: 15,
                      tooltip: "Add ${addDecreaseAmount}g",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Transform.scale(
                        scale: 2,
                        child: const Icon(Icons.add, color: Colors.green),
                      ),
                      onPressed: () => _updateWeight(addDecreaseAmount),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      iconSize: 15,
                      tooltip: "Edit ingredient",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: widget.onEdit,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

  }
}

