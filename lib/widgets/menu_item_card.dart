import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String rating;
  final Widget? actionButton; // Optional action button

  const MenuItemCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.rating,
    this.actionButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(rating);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack to layer the image and the rating badge
          Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Rating Badge
              Positioned(
                top: 8, // Position it a bit below the top
                right: 8, // Position it near the right edge
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Oval shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating != "N/A"
                            ? double.parse(rating).toStringAsFixed(1)
                            : rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),

                // Price and Action Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Text(
                      "\EGP $price",
                      style: TextStyle(
                        fontSize: 17,
                        // fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 96, 96, 96),
                      ),
                    ),

                    // Action Button
                    if (actionButton != null) actionButton!,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
