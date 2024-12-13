import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/client_order_item_tile.dart';
import 'package:yala_dine/providers/order_provider.dart';

class ClientTableOrderDetailsFirstScreen extends StatefulWidget {
  final String orderID;

  const ClientTableOrderDetailsFirstScreen({
    super.key,
    required this.orderID,
  });

  @override
  _ClientTableOrderDetailsFirstScreenState createState() =>
      _ClientTableOrderDetailsFirstScreenState();
}

class _ClientTableOrderDetailsFirstScreenState
    extends State<ClientTableOrderDetailsFirstScreen> {
  Map<String, dynamic>? orderDetails;

  @override
  Widget build(BuildContext context) {
    if (orderDetails == null) {
      // Fetch order details if not already fetched
      OrderProvider orderProvider = Provider.of<OrderProvider>(context);
      orderProvider.fetchOrderByOrderId(widget.orderID).then((fetchedOrder) {
        setState(() {
          orderDetails = fetchedOrder;
        });
      });

      // Show loading indicator while fetching the data
      return Scaffold(
        appBar: AppBar(
          title: const Text("Order Details"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Extract client data for each user ID in orderDetails
    final userOrders = orderDetails!["orderDetails"] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(8.0),
            children: userOrders.entries.map((entry) {
              final userId = entry.key;
              final clientData = entry.value;
              final clientName = clientData["name"];
              final menuItems = clientData["menuItems"] as List;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0, right: 8, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName ?? "Unknown Client",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            imageUrl: item["imageUrl"],
                            title: item["name"],
                            quantity: item["quantity"],
                            specialRequest: item["specialRequest"],
                            onQuantityChanged: (newQuantity) {
                              // Update the local state immediately
                              setState(() {
                                item["quantity"] = newQuantity;
                              });

                              // Now update the backend (database)
                              Provider.of<OrderProvider>(context, listen: false)
                                  .updateMenuItemQuantity(
                                widget.orderID,
                                userId,
                                item["itemID"],
                                newQuantity,
                              );
                            },
                            onSpecialRequestChanged: (newRequest) {
                              setState(() {
                                item["specialRequest"] = newRequest;
                              });
                              // Update special request in Firestore
                              Provider.of<OrderProvider>(context, listen: false)
                                  .updateMenuItemSpecialRequest(
                                widget.orderID,
                                userId,
                                item["itemID"],
                                newRequest,
                              );
                            },
                            onDelete: () {
                              // Handle item deletion locally
                              setState(() {
                                menuItems.remove(item);
                              });
                              Provider.of<OrderProvider>(context, listen: false)
                                  .removeItemFromOrder(
                                widget.orderID,
                                userId,
                                item["itemID"],
                              );
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
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // Handle button press, e.g., send to kitchen
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
        ],
      ),
    );
  }
}
