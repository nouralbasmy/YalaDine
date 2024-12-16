import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yala_dine/screens/client/client_split_equal_screen.dart';
import 'package:yala_dine/screens/client/client_split_items_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientSplitBillOptionsScreen extends StatelessWidget {
  final String orderID;
  final Map<String, dynamic> order;

  const ClientSplitBillOptionsScreen(
      {super.key, required this.orderID, required this.order});

  @override
  Widget build(BuildContext context) {
    // Listen to changes in the order document from Firestore
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Split Bill"),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderID)
            .snapshots(), // Listen to real-time changes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }

          final order = snapshot.data!.data() as Map<String, dynamic>;
          final splitMethod =
              order['splitMethod'] ?? ''; // Get splitMethod from order

          // Navigate based on the split method
          if (splitMethod == "Equally") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientSplitEqualScreen(
                    orderID: orderID,
                    order: order,
                  ),
                ),
              );
            });
          } else if (splitMethod == "ByItem") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientSplitItemsScreen(
                    orderID: orderID,
                  ),
                ),
              );
            });
          }

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "lib/assets/splitBill.png",
                    width: 280,
                    height: 280,
                  ),
                  const Text(
                    "How would you like to split the bill?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Update Firestore order split method to "Equally"
                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderID)
                          .update({'splitMethod': 'Equally'});
                    },
                    child: Card(
                      color: AppColors.secondaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ListTile(
                        leading: Icon(Icons.splitscreen,
                            color: Colors.white, size: 40),
                        title: Text(
                          "Split Equally",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Evenly divide the total bill among all clients at the table.",
                          style: TextStyle(
                              color: Color.fromARGB(235, 255, 255, 255),
                              fontSize: 16),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      // Update Firestore order split method to "ByItem"
                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderID)
                          .update({'splitMethod': 'ByItem'});
                    },
                    child: Card(
                      color: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ListTile(
                        leading: Icon(Icons.list_alt_outlined,
                            color: Colors.white, size: 40),
                        title: Text(
                          "Split by Items",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Pay for your ordered items or choose to split specific items with others.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
