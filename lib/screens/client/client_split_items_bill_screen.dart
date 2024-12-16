import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/client/client_post_payment_rate_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientSplitItemsBillScreen extends StatefulWidget {
  final String orderID;
  const ClientSplitItemsBillScreen({super.key, required this.orderID});

  @override
  State<ClientSplitItemsBillScreen> createState() =>
      _ClientSplitItemsBillScreenState();
}

class _ClientSplitItemsBillScreenState
    extends State<ClientSplitItemsBillScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Error messages for validation
  String? _cardNumberError;
  String? _cardHolderError;
  String? _expiryDateError;
  String? _cvvError;

  void _validateAndPay(
      Map<String, dynamic> order, double totalPrice, BuildContext context) {
    // Reset all error messages
    _cardNumberError = null;
    _cardHolderError = null;
    _expiryDateError = null;
    _cvvError = null;

    // Validate fields and set error messages
    if (_cardNumberController.text.isEmpty) {
      _cardNumberError = "Card number is required";
    }
    if (_cardHolderController.text.isEmpty) {
      _cardHolderError = "Cardholder name is required";
    }
    if (_expiryDateController.text.isEmpty) {
      _expiryDateError = "Expiry date is required";
    }
    if (_cvvController.text.isEmpty) {
      _cvvError = "CVV is required";
    }

    // If no errors, payment success
    if (_cardNumberError == null &&
        _cardHolderError == null &&
        _expiryDateError == null &&
        _cvvError == null) {
      // Process payment
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      User? user = FirebaseAuth.instance.currentUser;
      final clientId = user!.uid;
      orderProvider.updateOrderTotalPrice(widget.orderID, totalPrice);
      orderProvider.markUserAsPaid(widget.orderID, clientId);
      orderProvider.checkAndUpdateOrderStatus(widget.orderID);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientPostPaymentRateScreen(
            orderID: widget.orderID,
            order: order,
          ),
        ),
      );
    } else {
      // Show error message if fields are invalid
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Invalid Fields"),
          content: Text("Please fill in all required fields."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

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

          double totalPrice = 0;
          orderDetails.forEach((_, userOrder) {
            userOrder['menuItems'].forEach((item) {
              totalPrice += item['price'] *
                  item['quantity']; // Add item total to totalPrice
            });
          });

          return Stack(children: [
            SingleChildScrollView(
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

                    // Total Bill Calculation
                    double totalBill = 0.0;

                    // Add individual item costs
                    for (var item in menuItems) {
                      double itemPrice = (item['price'] ?? 0).toDouble();
                      int itemQuantity = (item['quantity'] ?? 0) as int;
                      bool isShared = item['isShared'] ?? false;
                      int totalSharing = (item['sharedWith']?.length ?? 0) + 1;

                      double userSharePrice =
                          isShared ? (itemPrice / totalSharing) : itemPrice;

                      totalBill += (userSharePrice * itemQuantity);
                    }

                    // Add shared item costs
                    for (var sharedItem in filteredSharedItems) {
                      String ownedBy = sharedItem['ownedBy'] ?? '';
                      var ownerDetails = orderDetails[ownedBy];

                      if (ownerDetails == null) {
                        continue;
                      }

                      var menuItem = (ownerDetails['menuItems'] ?? [])
                          .firstWhere(
                              (item) =>
                                  item['itemID'] ==
                                  sharedItem['orderItem']['itemID'],
                              orElse: () => null);

                      if (menuItem == null) {
                        continue;
                      }

                      double itemPrice = (menuItem['price'] ?? 0).toDouble();
                      int itemQuantity = (menuItem['quantity'] ?? 0) as int;
                      int totalSharing =
                          (sharedItem['sharedWith']?.length ?? 0) + 1;

                      double userSharePrice = itemPrice / totalSharing;
                      totalBill += (userSharePrice * itemQuantity);
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: filteredSharedItems
                                    .map<Widget>((sharedItem) {
                                  String itemID =
                                      sharedItem['orderItem']['itemID'] ?? '';
                                  String ownedBy = sharedItem['ownedBy'] ?? '';
                                  var ownerDetails = orderDetails[ownedBy];

                                  if (ownerDetails == null) {
                                    return const SizedBox();
                                  }

                                  var menuItem = (ownerDetails['menuItems'] ??
                                          [])
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
                                      (sharedItem['sharedWith']?.length ?? 0) +
                                          1;
                                  double userSharePrice =
                                      itemPrice / totalSharing;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                            child: Text(
                              'Total: \EGP ${totalBill.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom + 10,
                              top: 40,
                              left: 16,
                              right: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card Number Input
                              TextField(
                                controller: _cardNumberController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Card Number",
                                  prefixIcon: Icon(Icons.credit_card),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorText: _cardNumberError,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Cardholder Name Input
                              TextField(
                                controller: _cardHolderController,
                                decoration: InputDecoration(
                                  labelText: "Cardholder Name",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorText: _cardHolderError,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Expiry Date and CVV Input
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _expiryDateController,
                                      keyboardType: TextInputType.datetime,
                                      decoration: InputDecoration(
                                        labelText: "Expiry Date",
                                        prefixIcon: Icon(Icons.date_range),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorText: _expiryDateError,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller: _cvvController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "CVV",
                                        prefixIcon: Icon(Icons.lock),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorText: _cvvError,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Pay Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _validateAndPay(
                                        orderData.data()!, totalPrice, context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                  ),
                                  child: const Text(
                                    "Pay",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 24, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Pay",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
