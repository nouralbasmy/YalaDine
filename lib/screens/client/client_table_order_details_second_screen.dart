import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yala_dine/screens/client/client_menu_screen.dart';
import 'package:yala_dine/screens/client/client_split_bill_options_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientTableOrderDetailsSecondScreen extends StatefulWidget {
  final String orderID;
  const ClientTableOrderDetailsSecondScreen({
    super.key,
    required this.orderID,
  });

  @override
  State<ClientTableOrderDetailsSecondScreen> createState() =>
      _ClientTableOrderDetailsSecondScreenState();
}

class _ClientTableOrderDetailsSecondScreenState
    extends State<ClientTableOrderDetailsSecondScreen> {
  // Preparing Order Card
  Widget buildPreparingOrderCard() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/preparingImage.png',
              height: 150.0,
            ),
            const SizedBox(height: 16.0),
            const Column(
              children: [
                Text(
                  'Your meal is being prepared.',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTeal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.0),
                Text(
                  'Sit back and relax!',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  // Served Order Card
  Widget buildServedOrderCard() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'lib/assets/served.jpg',
              height: 160.0,
            ),
            const SizedBox(height: 16.0),
            const Column(
              children: [
                Text(
                  'Your meal is served!',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.0),
                Text(
                  'Bon appétit!',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text("Order Status"),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderID)
            .snapshots(), // Listen for real-time updates
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderData = snapshot.data!;

          if (!orderData.exists) {
            return const Center(
              child: Text(
                'No order data available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Extract the status and order details
          String status = orderData.data()?['status'] ?? 'Unknown';
          Map<String, dynamic> orderDetails =
              orderData.data()?['orderDetails'] ?? {};

          return Stack(children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                children: [
                  status == "In Progress"
                      ? buildPreparingOrderCard()
                      : buildServedOrderCard(),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      "Order Summary",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (orderDetails.isEmpty)
                    const Center(
                      child: Text(
                        'No order details available.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  else
                    ...orderDetails.entries.map<Widget>((entry) {
                      var userOrder = entry.value;
                      String userName = userOrder['name'];
                      List<dynamic> menuItems = userOrder['menuItems'];

                      return Container(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Client Name
                            Row(
                              children: [
                                const Icon(Icons.person_rounded),
                                const SizedBox(width: 2),
                                Text(
                                  '$userName',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            ...menuItems.map<Widget>((item) {
                              String itemName = item['name'];
                              double itemPrice = item['price'];
                              int itemQuantity = item['quantity'];
                              String specialRequest = item['specialRequest'];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${itemQuantity}x ',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      AppColors.primaryOrange,
                                                ),
                                              ),
                                              TextSpan(
                                                text: itemName,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '\EGP ${(itemPrice * itemQuantity).toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            // Price per item (in parentheses)
                                            Text(
                                              '(\EGP ${itemPrice.toStringAsFixed(2)} each)',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Special request, if any
                                    if (specialRequest.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Special Request: $specialRequest',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),

                            const Divider(thickness: 2),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
            status == "Served"
                ? Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        // TO BE ADDED
                        //print("Split Bill CLICKED");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ClientSplitBillOptionsScreen(
                                    order: orderData.data()!,
                                    orderID: widget.orderID,
                                  )),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_horiz_outlined,
                              size: 22, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Split Bill",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox()
          ]);
        },
      ),
    );
  }
}
