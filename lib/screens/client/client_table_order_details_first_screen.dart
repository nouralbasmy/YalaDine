import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/client_order_item_tile.dart';

class ClientTableOrderDetailsFirstScreen extends StatelessWidget {
  const ClientTableOrderDetailsFirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderDetails = {
      "A6GOOlJmdwY7kVwuRwm0u8TcpPu1": {
        "isPaid": false,
        "name": "Nour",
        "menuItems": [
          {
            "itemId": "3uoYxHMBFNk8dekBwXPg",
            "name": "Garlic Bread",
            "price": 60,
            "quantity": 2,
            "specialRequest": "",
          },
          {
            "itemId": "E1QzajTxbu8flxFEtCka",
            "name": "Classic Fried Chicken",
            "price": 169,
            "quantity": 1,
            "specialRequest": "No coleslaw",
          },
        ],
      },
      "i6CyqQzuKtUu3iSXlvrCdTEMWZq1": {
        "isPaid": false,
        "name": "John",
        "menuItems": [],
      },
    };
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
      ),
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.all(8.0),
          children: orderDetails.entries.map((entry) {
            final clientData = entry.value;
            final clientName = clientData["name"];
            final menuItems = clientData["menuItems"] as List;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 8, left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Client Name
                  Text(
                    clientName.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Show menu items or a message if none
                  if (menuItems.isEmpty)
                    const Text(
                      "Hasn't added anything yet",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  else
                    Column(
                      children: menuItems.map((item) {
                        return ClientOrderItemTile(
                          imageUrl:
                              'https://www.therusticelk.com/wp-content/uploads/2018/09/southern-fried-chicken-1-720x540.jpg',
                          title: item["name"],
                          quantity: item["quantity"],
                          specialRequest: item["specialRequest"],
                          onQuantityChanged: (newQuantity) {
                            print(
                                'Quantity for ${item["name"]} changed to $newQuantity');
                          },
                          onSpecialRequestChanged: (newRequest) {
                            print(
                                'Special request for ${item["name"]} updated to: $newRequest');
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              // TO BE ADDED
              print("SEND TO KITCHEN CLICKED");
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Send to Kitchen",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 24, color: Colors.white),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
