import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yala_dine/widgets/order_status_bar.dart';

class OrderHeaderCard extends StatelessWidget {
  final String orderID;
  final String createdAt;
  final String tableNumber;
  final int numberOfGuests;
  final String orderStatus;

  const OrderHeaderCard({
    required this.orderID,
    required this.createdAt,
    required this.tableNumber,
    required this.numberOfGuests,
    required this.orderStatus,
  });

  void showQRCodeDialog(BuildContext context, String orderID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("QR Code"),
          content: SingleChildScrollView(
            // Allow scrolling if content overflows
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  // wrapped QrImageView in SizedBox to give specific size
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: orderID,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Order ID: $orderID",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #$orderID",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Colors.black),
                  onPressed: () => showQRCodeDialog(context, orderID),
                ),
              ],
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
              ],
            ),
            const SizedBox(height: 8),
            OrderStatusBar(
              currentStatus: orderStatus,
              orderID: orderID,
            ),
          ],
        ),
      ),
    );
  }
}
