import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  @override
  void initState() {
    super.initState();
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    restaurantProvider.fetchAdminRestaurantInfo();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (restaurantProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle case where restaurant data is not available
    if (restaurantProvider.restaurantId == null) {
      return const Center(
        child: Text(
          'No restaurant found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // Render restaurant information
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (restaurantProvider.logoUrl != null)
            Image.network(
              restaurantProvider.logoUrl!,
              height: 130,
              width: 100,
            ),
          const SizedBox(height: 16),
          if (restaurantProvider.restaurantName != null)
            Text(
              'Restaurant: ${restaurantProvider.restaurantName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
