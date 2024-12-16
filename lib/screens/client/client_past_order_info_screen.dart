import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientPastOrderInfoScreen extends StatefulWidget {
  final String orderID;
  final int numOfGuests;
  const ClientPastOrderInfoScreen(
      {super.key, required this.orderID, required this.numOfGuests});

  @override
  State<ClientPastOrderInfoScreen> createState() =>
      _ClientPastOrderInfoScreenState();
}

class _ClientPastOrderInfoScreenState extends State<ClientPastOrderInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        title: const Text("My Bill"),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderID)
            .snapshots(),
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

          Map<String, dynamic>? orderDetails =
              orderData.data()?['orderDetails'];
          List<dynamic>? sharedItems = orderData.data()?['sharedItems'];

          if (orderDetails == null) {
            return const Center(
              child: Text(
                'No order details available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Column(
              children: [
                ...orderDetails.entries.where((entry) {
                  return entry.key == currentUserId;
                }).map<Widget>((entry) {
                  var userOrder = entry.value ?? {};
                  List<dynamic> menuItems = userOrder['menuItems'] ?? [];

                  List<dynamic> filteredSharedItems =
                      (sharedItems ?? []).where((item) {
                    List<dynamic> sharedWith = item['sharedWith'] ?? [];
                    return sharedWith.contains(currentUserId);
                  }).toList();

                  // Total Bill Calculation if shared
                  double totalMyShareBill = 0.0;

                  // Add individual item costs
                  for (var item in menuItems) {
                    double itemPrice = (item['price'] ?? 0).toDouble();
                    int itemQuantity = (item['quantity'] ?? 0) as int;
                    bool isShared = item['isShared'] ?? false;
                    int totalSharing = (item['sharedWith']?.length ?? 0) + 1;

                    double userSharePrice =
                        isShared ? (itemPrice / totalSharing) : itemPrice;

                    totalMyShareBill += (userSharePrice * itemQuantity);
                  }

                  //Equally spit total
                  double totalEquallyBill =
                      orderData['totalPrice'] / widget.numOfGuests;

                  // Add shared item costs
                  for (var sharedItem in filteredSharedItems) {
                    String ownedBy = sharedItem['ownedBy'] ?? '';
                    var ownerDetails = orderDetails[ownedBy];

                    if (ownerDetails == null) {
                      continue;
                    }

                    var menuItem = (ownerDetails['menuItems'] ?? []).firstWhere(
                        (item) =>
                            item['itemID'] == sharedItem['orderItem']['itemID'],
                        orElse: () => null);

                    if (menuItem == null) {
                      continue;
                    }

                    double itemPrice = (menuItem['price'] ?? 0).toDouble();
                    int itemQuantity = (menuItem['quantity'] ?? 0) as int;
                    int totalSharing =
                        (sharedItem['sharedWith']?.length ?? 0) + 1;

                    double userSharePrice = itemPrice / totalSharing;
                    totalMyShareBill += (userSharePrice * itemQuantity);
                  }

                  return Container(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User's Individual Items
                        ...menuItems.map<Widget>((item) {
                          String itemName = item['name'] ?? 'Unknown Item';
                          double itemPrice = (item['price'] ?? 0).toDouble();
                          int itemQuantity = (item['quantity'] ?? 0) as int;
                          bool isShared = item['isShared'] ?? false;
                          List<dynamic> sharedWith = item['sharedWith'] ?? [];
                          int totalSharing = sharedWith.length + 1;

                          double userSharePrice =
                              isShared ? itemPrice / totalSharing : itemPrice;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$itemQuantity x $itemName',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\EGP ${(userSharePrice * itemQuantity).toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isShared)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, left: 4.0),
                                    child: Text(
                                      'Original: \EGP ${(itemPrice * itemQuantity).toStringAsFixed(1)}, Shared by $totalSharing people',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                        // Shared Items
                        if (filteredSharedItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  filteredSharedItems.map<Widget>((sharedItem) {
                                String itemID =
                                    sharedItem['orderItem']['itemID'] ?? '';
                                String ownedBy = sharedItem['ownedBy'] ?? '';
                                var ownerDetails = orderDetails[ownedBy];

                                if (ownerDetails == null) {
                                  return const SizedBox();
                                }

                                var menuItem = (ownerDetails['menuItems'] ?? [])
                                    .firstWhere(
                                        (item) => item['itemID'] == itemID,
                                        orElse: () => null);

                                if (menuItem == null) {
                                  return const SizedBox();
                                }

                                String itemName =
                                    menuItem['name'] ?? 'Unknown Item';
                                double itemPrice =
                                    (menuItem['price'] ?? 0).toDouble();
                                int itemQuantity =
                                    (menuItem['quantity'] ?? 0) as int;
                                int totalSharing =
                                    (sharedItem['sharedWith']?.length ?? 0) + 1;
                                double userSharePrice =
                                    itemPrice / totalSharing;

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$itemQuantity x $itemName',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '\EGP ${(userSharePrice * itemQuantity).toStringAsFixed(1)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4.0, left: 4.0),
                                        child: Text(
                                          'Original: \EGP ${(itemPrice * itemQuantity).toStringAsFixed(1)}, Shared by $totalSharing people',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Divider and Total Bill
                        const Divider(thickness: 2),
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: orderData['splitMethod'] == "ByItem"
                                ? Text(
                                    'Total: \EGP ${totalMyShareBill.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryOrange,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Order Total: EGP ${orderData['totalPrice'].toStringAsFixed(1)}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.people),
                                              SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                "Number of guests: ${widget.numOfGuests.toString()}",
                                                style: TextStyle(fontSize: 14),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "Bill Split Method:  ${orderData['splitMethod']}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueGrey),
                                      ),
                                      Text(
                                        'Amount Paid: \EGP ${totalEquallyBill.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                    ],
                                  )),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
