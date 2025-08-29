import 'package:flutter/material.dart';

class RecipeNavBar extends StatelessWidget {
  final int selectedIndexNow;

  final List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.search, color: Colors.black,),
        selectedIcon: Icon(Icons.search, color: Colors.green),
        label: "Search"),
    NavigationDestination(icon: Icon(Icons.save, color: Colors.black,),
        selectedIcon: Icon(Icons.save, color: Colors.green,),
        label: "Saved"),
    NavigationDestination(icon: Icon(Icons.my_library_add_outlined, color: Colors.black,),
        selectedIcon: Icon(Icons.my_library_add_outlined, color: Colors.green,),
        label: "My Recipes")
  ];

  final Function(int index) onNavSellect;

  RecipeNavBar({
    super.key,
    required this.selectedIndexNow,
    required this.onNavSellect,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: states.contains(MaterialState.selected) ? Colors.green : Colors.black,
          );
        }),
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndexNow,
        indicatorColor: Colors.green.withOpacity(0.5),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations,
        onDestinationSelected: (int index) {
          onNavSellect(index);
        },
      ),
    );
  }
}