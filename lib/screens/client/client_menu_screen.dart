import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientMenuScreen extends StatelessWidget {
  final String restaurantId;
  const ClientMenuScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (menuProvider.menuItems.isEmpty && !menuProvider.isMenuEmpty) {
      // Fetch menu items
      menuProvider.fetchMenuItems(restaurantId);
    }
    restaurantProvider.fetchRestaurantByID(restaurantId);

    if (menuProvider.menuItems.isEmpty && !menuProvider.isLoading) {
      return const Center(
          child: Text("Oops! No items here yet. Stay tuned for updates!"));
    }
    return Scaffold(
      appBar: AppBar(
          title: const Text("Menu"), backgroundColor: AppColors.primaryOrange),
      body: Center(
        child: Text("Restaurant Name: ${restaurantProvider.restaurantName}"),
      ),
    );
  }
}
