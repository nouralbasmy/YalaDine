import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
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
  final int numOfRatings; //HENA

  const ClientMenuItemDetailsBottomSheet({
    Key? key,
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.numOfRatings,
  }) : super(key: key);

  @override
  _ClientMenuItemDetailsBottomSheetState createState() =>
      _ClientMenuItemDetailsBottomSheetState();
}

class _ClientMenuItemDetailsBottomSheetState
    extends State<ClientMenuItemDetailsBottomSheet> {
  // List of available categories
  final List<String> categories = [
    "Appetizers",
    "Main Course",
    "Sides",
    "Desserts",
    "Beverages"
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    String? restaurantId = restaurantProvider.restaurantId;
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10),
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
                    'Category: ${widget.category}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price
                  Text(
                    '\EGP ${widget.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
