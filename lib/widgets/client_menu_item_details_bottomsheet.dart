import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientMenuItemDetailsBottomSheet extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String category;
  final String price;
  final String imageUrl;
  final double rating;
  final int numOfRatings;

  final String orderID;

  const ClientMenuItemDetailsBottomSheet(
      {Key? key,
      required this.id,
      required this.name,
      required this.category,
      required this.description,
      required this.price,
      required this.imageUrl,
      required this.rating,
      required this.numOfRatings,
      required this.orderID})
      : super(key: key);

  @override
  _ClientMenuItemDetailsBottomSheetState createState() =>
      _ClientMenuItemDetailsBottomSheetState();
}

class _ClientMenuItemDetailsBottomSheetState
    extends State<ClientMenuItemDetailsBottomSheet> {
  String specialRequest = ""; // For capturing the special request

  @override
  Widget build(BuildContext context) {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    // Get the height of the keyboard dynamically
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(bottom: keyboardHeight + 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            if (widget.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  widget.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[600], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            widget.numOfRatings == 0
                                ? "N/A"
                                : widget.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Category
                  Text(
                    '(${widget.category})',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Description
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price
                  Text(
                    '\EGP ${widget.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Special Request TextField
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        specialRequest = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Special Request",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Add Item Button
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final orderProvider =
                        Provider.of<OrderProvider>(context, listen: false);

                    String orderId = widget.orderID;
                    User? user = FirebaseAuth.instance.currentUser;
                    final clientId = user!.uid;

                    await orderProvider.addItemToOrder(
                      orderId,
                      clientId,
                      widget.id, //itemId
                      widget.name, // Item name
                      widget.imageUrl,
                      double.parse(widget.price),
                      1, // Default quantity 1
                      specialRequest, // Special request from the text field
                    );

                    // Show a success message or close the sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.name} added to your order!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.of(context).pop(); // Close the bottom sheet
                  } catch (e) {
                    // Handle errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add item to order: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 140),
                ),
                child: const Text(
                  "Add Item",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
