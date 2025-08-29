import 'package:flutter/material.dart';
import 'package:app/widgets/pantry/pantry_item.dart';

class PantryListView extends StatelessWidget {
  final List<PantryItem> items;
  final Function(int) onPantryItemTap;
  final Function(int) onPantryItemEdit;

  const PantryListView({
    super.key,
    required this.items,
    required this.onPantryItemTap,
    required this.onPantryItemEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          "No ingredients in your pantry.",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, left: 6, right: 6),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: GestureDetector(
            onTap: () => onPantryItemTap(index),
            child: PantryItemWidget(
              item: items[index],
              onEdit: () => onPantryItemEdit(index),
            ),
          ),
        );
      },
    );
  }
}