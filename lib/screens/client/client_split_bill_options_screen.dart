import 'package:flutter/material.dart';
import 'package:yala_dine/screens/client/client_split_equal_screen.dart';
import 'package:yala_dine/screens/client/client_split_items_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientSplitBillOptionsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderID;
  const ClientSplitBillOptionsScreen(
      {super.key, required this.order, required this.orderID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Split Bill"),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                  //print("Split equally clicked");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientSplitEqualScreen(
                              order: order,
                              orderID: orderID,
                            )),
                  );
                },
                child: Card(
                  color: AppColors.secondaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ListTile(
                    leading:
                        Icon(Icons.splitscreen, color: Colors.white, size: 40),
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

              // Split by Items Card
              GestureDetector(
                onTap: () {
                  //print("Split by items clicked");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClientSplitItemsScreen(
                              orderID: orderID,
                            )),
                  );
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
      ),
    );
  }
}
