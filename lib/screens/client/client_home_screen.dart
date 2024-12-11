import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/client/client_menu_screen.dart';
import 'package:yala_dine/screens/client/qr_scanner_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String? name = "";

  @override
  void initState() {
    super.initState();
    _getClientName();
  }

  void _getClientName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        name = userDoc['name'];
      });
    }
  }

  void showTableCodeDialog() {
    TextEditingController tableCodeController = TextEditingController();
    String errorMessage = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter Table Code"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tableCodeController,
                      decoration: const InputDecoration(
                        hintText: "Enter your table code",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(top: 8.0),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String tableCode = tableCodeController.text.trim();

                    if (tableCode.isEmpty) {
                      setState(() {
                        errorMessage = "Please enter a table code";
                      });
                      return;
                    }

                    try {
                      final order = await Provider.of<OrderProvider>(context,
                              listen: false)
                          .fetchOrderByOrderId(tableCode);

                      if (order == null) {
                        setState(() {
                          errorMessage = "Invalid table order code. Try again.";
                        });
                      } else {
                        // Navigate to the Menu Screen with the restaurantId
                        String restaurantId = order['restaurantId'];
                        User? user = FirebaseAuth.instance.currentUser;
                        final clientId = user!.uid;
                        Provider.of<OrderProvider>(context, listen: false)
                            .addUserToOrder(tableCode, clientId)
                            .then((_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientMenuScreen(
                                restaurantId: restaurantId,
                                orderID: tableCode,
                              ),
                            ),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to update order: $error"),
                            ),
                          );
                        });
                      }
                    } catch (e) {
                      setState(() {
                        errorMessage = "An error occurred. Please try again.";
                      });
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        title: const Text('Yala Dine', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            onPressed: () {
              // Logout logic
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: name == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Image.asset(
                        "lib/assets/login_logo.png",
                        width: 250,
                        height: 250,
                      ),
                      const SizedBox(height: 20),
                      // Welcome message
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome, $name',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Let’s get your table order started\nHow would you like to join?',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Scan QR Code Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QrScannerScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner, size: 28),
                            SizedBox(width: 12),
                            Text(
                              "Scan QR Code",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Enter Table Code Button
                      ElevatedButton(
                        onPressed: showTableCodeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.table_restaurant, size: 28),
                            SizedBox(width: 12),
                            Text(
                              "Enter Table Code",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40), // Add bottom spacing
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
