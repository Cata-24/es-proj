import 'package:app/databaseConnection/pantryLogic/pantry_storage_implementation.dart';
import 'package:app/widgets/pantry/pantry_item.dart';
import 'package:flutter/material.dart';
import 'package:app/services/auth_service.dart';

class Filters extends StatefulWidget {
  final Set<String> selectedItems;
  final Function(String ingredient, bool isSelected) onIngredientToggle;

  const Filters({
    super.key,
    required this.selectedItems,
    required this.onIngredientToggle,
  });

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  List<PantryItem> _allItems = [];
  String _searchQuery = "";

  Future<void> fetchItems() async {
    final authService = AuthService();
    final userId = authService.uid;

    if (userId != null) {
      final items = await PantryStorageImplementation().getUserPantryItems(userId);
      if (items != null) {
        setState(() {
          _allItems = items;
        });
      }
    } else {
      print("User ID is null. Cannot fetch pantry items.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final List<PantryItem> visibleItems;

    if (_searchQuery.isNotEmpty) {
      visibleItems = _allItems
          .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList()
        ..sort((a, b) {
          final aSelected = widget.selectedItems.contains(a.name);
          final bSelected = widget.selectedItems.contains(b.name);

          if (aSelected && !bSelected) return -1;
          if (!aSelected && bSelected) return 1;

          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    } else {
      visibleItems = _allItems
          .where((item) => widget.selectedItems.contains(item.name))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Colors.lightGreen, width: 3),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔍 Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search ingredients...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),

          if (visibleItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...visibleItems
                    .take(5)
                    .map((item) {
                  final isChecked = widget.selectedItems.contains(item.name);
                  return Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          widget.onIngredientToggle(item.name, value!);
                        },
                        activeColor: Colors.green[600],
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                      ),
                      Text(item.name, style: const TextStyle(fontSize: 14)),
                    ],
                  );
                }).toList(),
                if (visibleItems.length > 5)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      '...',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    "Select the ingredients in your pantry that you want to use in the recipe",
                    style: TextStyle(fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          else
            const Text(
              'Start typing to search your pantry items',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}
