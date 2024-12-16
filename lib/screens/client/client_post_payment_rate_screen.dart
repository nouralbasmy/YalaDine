import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/client/client_home_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientPostPaymentRateScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String orderID;

  const ClientPostPaymentRateScreen({
    super.key,
    required this.order,
    required this.orderID,
  });

  @override
  State<ClientPostPaymentRateScreen> createState() =>
      _ClientPostPaymentRateScreenState();
}

class _ClientPostPaymentRateScreenState
    extends State<ClientPostPaymentRateScreen> {
  // Map to store ratings for each item
  Map<int, double> ratings = {};

  late List<dynamic> userMenuItems;

  @override
  void initState() {
    super.initState();

    User? user = FirebaseAuth.instance.currentUser;
    final clientID = user!.uid;
    final orderDetails =
        widget.order['orderDetails'] as Map<String, dynamic>? ?? {};

    if (!orderDetails.containsKey(clientID)) {
      throw Exception("User not part of this order");
    }

    // Extract the user's menu items
    userMenuItems = orderDetails[clientID]['menuItems'] as List<dynamic>? ?? [];
  }

  Future<void> _updateItemRating(String itemId, double newRating) async {
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    final restaurantId = widget.order['restaurantId'];
    if (restaurantId == null || restaurantId.isEmpty) {
      throw Exception("Restaurant ID is missing in order data");
    }
    if (menuProvider.menuItems.isEmpty) {
      menuProvider.fetchMenuItems(restaurantId);
    }
    //print(menuProvider.menuItems);
    final itemIndex =
        menuProvider.menuItems.indexWhere((item) => item['id'] == itemId);

    if (itemIndex == -1) {
      throw Exception("Menu item not found");
    }

    final item = menuProvider.menuItems[itemIndex];

    final currentNumOfRatings = item['numOfRatings'] ?? 0;
    final currentRatingSum = (item['rating'] ?? 0.0) * currentNumOfRatings;

    final updatedNumOfRatings = currentNumOfRatings + 1;
    final updatedRatingSum = currentRatingSum + newRating;
    final updatedAverageRating = updatedRatingSum / updatedNumOfRatings;

    // Update the item in Firestore using MenuProvider
    await menuProvider.updateMenuItem(
      restaurantId,
      itemId,
      {
        'numOfRatings': updatedNumOfRatings,
        'rating': updatedAverageRating,
      },
    );

    // // Show a success message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Rating for item updated successfully!")),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Final Step"),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Thank You Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6.0),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle,
                    size: 50.0, color: AppColors.lightTeal),
                SizedBox(height: 12.0),
                Text(
                  "Payment successful!",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTeal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                Text(
                  "Thanks for dining with us. See you next time!",
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14.0),
            alignment: Alignment.topLeft,
            child: const Text("Rate Your Meal",
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          // List of Menu Items with Ratings
          Expanded(
            child: ListView.builder(
              itemCount: userMenuItems.length,
              itemBuilder: (context, index) {
                final item = userMenuItems[index];
                String itemName = item['name'] ?? 'Unknown Item';

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Name
                        Text(
                          itemName,
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),

                        // Star Rating
                        Row(
                          children: [
                            const Text(
                              "Rate this: ",
                              style: TextStyle(fontSize: 16.0),
                            ),
                            const SizedBox(width: 8.0),
                            _buildStarRating(index),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Finish Button
          Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                //print("Finish pressed");
                OrderProvider orderProvider =
                    Provider.of<OrderProvider>(context, listen: false);
                orderProvider.checkAndUpdateOrderStatus(widget.orderID);
                final menuProvider =
                    Provider.of<MenuProvider>(context, listen: false);
                menuProvider.menuItems.clear();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientHomeScreen()),
                );
              },
              child: const Text(
                "Finish",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Build the star rating widget
  Widget _buildStarRating(int index) {
    final item = userMenuItems[index];
    final itemId = item['itemID'];

    return Row(
      children: List.generate(5, (starIndex) {
        return GestureDetector(
          onTap: () async {
            final newRating = starIndex + 1.0;
            setState(() {
              ratings[index] = newRating;
            });

            // Update the rating for the item
            try {
              await _updateItemRating(itemId, newRating);
            } catch (e) {
              print("Failed to update rating: $e");
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text("Failed to update rating: $e")),
              // );
            }
          },
          child: Icon(
            Icons.star,
            size: 30.0,
            color: (ratings[index] ?? 0) > starIndex
                ? Colors.orange
                : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}
