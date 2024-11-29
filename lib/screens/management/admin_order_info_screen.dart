import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/order_header_card.dart'; // Import your custom colors

class AdminOrderInfoScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  AdminOrderInfoScreen({required this.order});

  @override
  _AdminOrderInfoScreenState createState() => _AdminOrderInfoScreenState();
}

class _AdminOrderInfoScreenState extends State<AdminOrderInfoScreen> {
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _currentStatus =
        widget.order['status']; // Initialize with the order's current status
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total price for all items
    double totalAmount = 0.0;
    int totalGuests = 0; // Track the total number of guests

    // Iterate over all users in the orderDetails to calculate totalAmount and totalGuests
    widget.order['orderDetails'].forEach((_, userOrder) {
      List<dynamic> menuItems = userOrder['menuItems'];
      for (var item in menuItems) {
        totalAmount += item['price'] * item['quantity'];
      }
      totalGuests += 1; // Add the guest count from each user order
    });

    // Format the createdAt date to dd/MM hh:mm
    String formattedDate = _formatDate(widget.order['createdAt']);

    return Scaffold(
      appBar: AppBar(title: Text('Order Info')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            OrderHeaderCard(
              orderID: "ABCDEFGHIJKLMNOPQRS0",
              createdAt: formattedDate,
              tableNumber: widget.order['tableNum'].toString(),
              numberOfGuests: totalGuests,
              orderStatus: _currentStatus,
            ),

            const SizedBox(height: 16),

            // Order Details Section
            ...widget.order['orderDetails'].entries.map<Widget>((entry) {
              var userOrder = entry.value;
              String userName = userOrder['name'];
              bool isPaid = userOrder['isPaid'];
              List<dynamic> menuItems = userOrder['menuItems'];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Name
                  Text(
                    '$userName:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ...menuItems.map<Widget>((item) {
                    String itemName = item['name'];
                    double itemPrice = item['price'];
                    int itemQuantity = item['quantity'];
                    String specialRequest = item['specialRequest'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${itemQuantity}x ',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors
                                            .primaryOrange, // Orange for quantity
                                      ),
                                    ),
                                    TextSpan(
                                      text: itemName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${(itemPrice * itemQuantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // Price per item (in parentheses)
                                  Text(
                                    '(\$${itemPrice.toStringAsFixed(2)} each)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .blueGrey, // Subtle color for unit price
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Special request, if any
                          if (specialRequest.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
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

                  // Payment status
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isPaid ? Colors.grey : AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPaid ? 'Paid' : 'Unpaid',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2),
                ],
              );
            }).toList(),

            // Total order price
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Total Price: ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange, // Total price in green
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to format the date to dd/MM hh:mm
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(
          dateString); // Assuming the date string is in ISO 8601 format
      return DateFormat('dd/MM HH:mm').format(date); // Format as dd/MM hh:mm
    } catch (e) {
      return dateString; // If there's an error in formatting, return the original string
    }
  }
}
