import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/client/client_past_order_info_screen.dart';
import 'package:yala_dine/utils/app_colors.dart'; // For formatting the timestamp

class ClientPastOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;
    final clientId = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Past Orders"),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // Stream of orders
        stream: orderProvider.fetchClientOrders(clientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching orders"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No past orders found"));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              //print("order $order");

              final createdAt = order['createdAt'] != null
                  ? (order['createdAt'] as Timestamp).toDate()
                  : DateTime.now();
              final totalPrice = order['totalPrice'] ?? 0.0;

              // Get the orderDetails map
              final orderDetails =
                  order['orderDetails'] as Map<String, dynamic>?;

              // Filter orderDetails for the logged-in user and retrieve menuItems
              List<dynamic> menuItems = [];
              if (orderDetails != null) {
                orderDetails.entries.where((entry) {
                  return entry.key == clientId; // Match with currentUserId
                }).forEach((entry) {
                  var userOrder = entry.value ?? {};
                  menuItems = userOrder['menuItems'] ?? [];
                });
              }

              int totalGuests = 0;
              if (orderDetails != null) {
                orderDetails.forEach((_, userOrder) {
                  totalGuests += 1;
                });
              }

              // Fetch the restaurant name based on the restaurant ID in the order
              final restaurantId = order['restaurantId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(restaurantId)
                    .get(),
                builder: (context, restaurantSnapshot) {
                  if (restaurantSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Loading indicator
                  }

                  if (restaurantSnapshot.hasError) {
                    return Text('Error fetching restaurant name');
                  }

                  final restaurantData = restaurantSnapshot.data;
                  final restaurantName = restaurantData?.exists == true
                      ? restaurantData!['restaurantName']
                      : 'Unknown Restaurant';
                  final restaurantLogoUrl = restaurantData!['logoUrl'];

                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: restaurantLogoUrl.isNotEmpty
                          ? Image.network(
                              restaurantLogoUrl,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'lib/assets/pastOrderImage.png',
                              height: 60,
                              width: 60,
                              fit: BoxFit.fitWidth,
                            ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$restaurantName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(
                                '${DateFormat('dd/MM HH:mm').format(createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Order Total: EGP $totalPrice',
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          order['splitMethod'] == "Equally"
                              ? Text("Split Bill: ${order['splitMethod']}")
                              : Text("Split Bill: By Item"),
                          Row(
                            children: [
                              Icon(Icons.people),
                              SizedBox(
                                width: 2,
                              ),
                              Text(totalGuests.toString())
                            ],
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientPastOrderInfoScreen(
                              orderID: order['id'],
                              numOfGuests: totalGuests,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
