import 'package:flutter/material.dart';
import 'package:yala_dine/widgets/order_status_bar.dart';

class OrderHeaderCard extends StatelessWidget {
  final String orderID;
  final String createdAt;
  final String tableNumber;
  final int numberOfGuests;
  final String orderStatus;

  const OrderHeaderCard(
      {required this.orderID,
      required this.createdAt,
      required this.tableNumber,
      required this.numberOfGuests,
      required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order #$orderID",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: $createdAt',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Table Number and Number of Guests (Side by side)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.table_restaurant,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Table: $tableNumber',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Guests: ${numberOfGuests.toString()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // Show the total guest count
              ],
            ),
            const SizedBox(height: 8),

            // Order Status Section with a smooth horizontal status bar
            OrderStatusBar(
              currentStatus: orderStatus,
              orderID: orderID,
            )
          ],
        ),
      ),
    );
  }
}
