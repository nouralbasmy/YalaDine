import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientSplitItemsScreen extends StatefulWidget {
  final String orderID;

  const ClientSplitItemsScreen({
    super.key,
    required this.orderID,
  });

  @override
  State<ClientSplitItemsScreen> createState() => _ClientSplitItemsScreenState();
}

class _ClientSplitItemsScreenState extends State<ClientSplitItemsScreen> {
  @override
  Widget build(BuildContext context) {
    // Firestore stream to listen for changes in the specific order
    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderID)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Order Items"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          // Extract order details from the snapshot data
          final order = snapshot.data!.data() as Map<String, dynamic>;

          // Extract the menu items for the specific client
          User? user = FirebaseAuth.instance.currentUser;
          final clientId = user!.uid;
          final userOrders = order["orderDetails"] as Map<String, dynamic>;

          final clientOrder = userOrders[clientId];
          if (clientOrder == null) {
            return const Center(child: Text('No items found for this client'));
          }

          final menuItems = clientOrder['menuItems'] as List<dynamic>? ?? [];
          final isPaid = clientOrder['isPaid'] ?? false;

          return Stack(children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: const Text("Split Requests",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _showReceivedSplitsDialog(order);
                          },
                          icon:
                              const Icon(Icons.south_west, color: Colors.white),
                          label: const Text(
                            "Received",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                          ),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showSentSplitsDialog(order);
                          },
                          icon:
                              const Icon(Icons.north_east, color: Colors.white),
                          label: const Text(
                            "Sent",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                Expanded(
                  child: ListView(
                    children: menuItems.map((itemData) {
                      final item = itemData as Map<String, dynamic>;
                      final itemName = item['name'] ?? 'Unknown Item';
                      final quantity = item['quantity'] ?? 0;
                      final price = (item['price'] ?? 0).toDouble();
                      final totalPrice = quantity * price;
                      final isShared = item['isShared'] ?? false;
                      final sharedWith = item['sharedWith'] ?? [];
                      final imageUrl = item['imageUrl'] ?? '';
                      final specialRequest = item['specialRequest'] ?? '';

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  // Item Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.image, size: 80),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),

                                  // Item Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Item Name and Quantity
                                        Text(
                                          "$itemName x $quantity",
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),

                                        // Price per item and Total price
                                        Text(
                                            "Price/item: EGP ${price.toStringAsFixed(2)}"),
                                        Text(
                                            "Total: EGP ${totalPrice.toStringAsFixed(2)}"),
                                        const SizedBox(height: 8.0),

                                        // Special Request
                                        // if (specialRequest.isNotEmpty)
                                        //   Text(
                                        //     "Special Request: $specialRequest",
                                        //     style: const TextStyle(
                                        //       color: Colors.blueGrey,
                                        //     ),
                                        //   ),

                                        // Shared Status
                                        isShared
                                            ? Text(
                                                "Shared with: ${sharedWith.join(', ')}",
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                ),
                                              )
                                            : const Text("Not shared yet",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Share Button (If not shared)
                              if (!isShared)
                                Positioned(
                                  top: 25.0,
                                  right: 2.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      //print("Share item: $itemName");
                                      _showShareDialog(context, item, order);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightTeal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0, vertical: 12.0),
                                    ),
                                    child: const Text(
                                      "Share",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  //print("Proceed to Payment");
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Proceed to Payment",
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
          ]);
        },
      ),
    );
  }

  void _showShareDialog(
      BuildContext context, dynamic item, Map<String, dynamic> order) async {
    final userOrders = order["orderDetails"] as Map<String, dynamic>;

    // List of all client IDs in the order
    final clients = userOrders.keys.toList();

    // Exclude the logged-in user
    final loggedInUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherClients = clients.where((id) => id != loggedInUserId).toList();

    // Map of client IDs to names for display
    Map<String, String> clientNames = {};
    otherClients.forEach((clientId) {
      clientNames[clientId] = userOrders[clientId]['name'];
    });

    // Track selected client IDs
    List<String> selectedClientIds = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Clients to Share With"),
              content: SingleChildScrollView(
                child: Column(
                  children: clientNames.entries.map((entry) {
                    final clientId = entry.key; // Client ID
                    final clientName = entry.value; // Client Name

                    return CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: clientName, // Display client name
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' (${clientId})', // Display client ID in smaller font (optional)
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey, // Make the ID color lighter
                              ),
                            ),
                          ],
                        ),
                      ),
                      value: selectedClientIds.contains(
                          clientId), // Check if the client ID is selected
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            selectedClientIds
                                .add(clientId); // Add the client ID
                          } else {
                            selectedClientIds
                                .remove(clientId); // Remove the client ID
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog without sharing
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    // Create share requests for each selected client
                    List<Map<String, dynamic>> shareRequests =
                        selectedClientIds.map((clientId) {
                      return {
                        'itemID': item['itemID'],
                        'itemName': item['name'],
                        'fromUser': loggedInUserId,
                        'toUser': clientId,
                        'status': 'pending',
                      };
                    }).toList();

                    // Print the share requests for debugging
                    print("Share Requests: $shareRequests");

                    // Update Firestore
                    Provider.of<OrderProvider>(context, listen: false)
                        .updateFirestoreWithShareRequests(
                            widget.orderID, shareRequests);

                    // Update the item's sharedWith list
                    setState(() {
                      item['sharedWith'] =
                          selectedClientIds; // Store selected IDs
                      item['isShared'] =
                          selectedClientIds.isNotEmpty; // Update shared status
                    });

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text("Share"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSentSplitsDialog(Map<String, dynamic> order) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Get the splitRequests from the passed order data
    final splitRequests = order['splitRequests'] as List<dynamic>? ?? [];

    // Filter sent requests where the logged-in user is the fromUser
    final sentRequests = splitRequests
        .where((request) => request['fromUser'] == userId)
        .toList();

    if (sentRequests.isEmpty) {
      // No sent splits, show a message to the user
      _showNoSentSplitsDialog();
      return;
    }

    // Fetch user details to map user IDs to names
    final userOrders = order['orderDetails'] as Map<String, dynamic>;
    final clientNames = _getClientNames(userOrders);

    // Show the sent splits dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sent Split Requests"),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: sentRequests.map<Widget>((request) {
                  final clientName =
                      clientNames[request['toUser']] ?? 'Unknown User';
                  final itemName = request['itemName'] ?? 'Unknown Item';

                  return ListTile(
                    title: Text(itemName),
                    subtitle: Text(
                        "Sent to: $clientName\nStatus: ${request['status']}"),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // to map user ids to names
  Map<String, String> _getClientNames(Map<String, dynamic> userOrders) {
    final clientNames = <String, String>{};

    userOrders.forEach((userId, userDetails) {
      final name = userDetails['name'] ?? 'Unnamed User';
      clientNames[userId] = name;
    });

    return clientNames;
  }

  void _showNoSentSplitsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("No Sent Split Requests"),
          content: const Text("You have not sent any split requests."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showReceivedSplitsDialog(Map<String, dynamic> order) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Get the splitRequests from the passed order data
    final splitRequests = order['splitRequests'] as List<dynamic>? ?? [];

    // Filter received requests where the logged-in user is the toUser
    final receivedRequests =
        splitRequests.where((request) => request['toUser'] == userId).toList();

    if (receivedRequests.isEmpty) {
      // No received splits, show a message to the user
      _showNoReceivedSplitsDialog();
      return;
    }

    // Fetch user details to map user IDs to names
    final userOrders = order['orderDetails'] as Map<String, dynamic>;
    final clientNames = _getClientNames(userOrders);

    // Show the received splits dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Received Split Requests"),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevent overflow
                children: receivedRequests.map<Widget>((request) {
                  final clientName =
                      clientNames[request['fromUser']] ?? 'Unknown User';
                  final itemName = request['itemName'] ?? 'Unknown Item';

                  return ListTile(
                    title: Text(itemName),
                    subtitle: Text(
                        "Sent by: $clientName\nStatus: ${request['status']}"),
                    trailing: request['status'] == 'pending'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  // Handle accept action
                                  _acceptSplitRequest(request);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  // Handle reject action
                                  _rejectSplitRequest(request);
                                },
                              ),
                            ],
                          )
                        : null,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _acceptSplitRequest(Map<String, dynamic> request) {
    // Handle the logic for accepting the request
    // For now, you can just print or update the status
    print("Accepted request: ${request['itemName']}");

    // Example: Update the status to "accepted" in Firestore (just a placeholder)
    // FirebaseFirestore.instance
    //     .collection('orders')
    //     .doc(widget.orderID)
    //     .update({
    //   'splitRequests.${request['id']}.status': 'accepted',
    // });

    // You can implement your accept logic here
  }

  void _rejectSplitRequest(Map<String, dynamic> request) {
    // Handle the logic for rejecting the request
    // For now, you can just print or update the status
    print("Rejected request: ${request['itemName']}");

    // Example: Update the status to "rejected" in Firestore (just a placeholder)
    // FirebaseFirestore.instance
    //     .collection('orders')
    //     .doc(widget.orderID)
    //     .update({
    //   'splitRequests.${request['id']}.status': 'rejected',
    // });

    // You can implement your reject logic here
  }

  void _showNoReceivedSplitsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("No Received Split Requests"),
          content: const Text("You have not received any split requests."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
