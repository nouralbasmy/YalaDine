import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/management/admin_order_info_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  // final String orderId;
  // final String tableNumber;
  // final int numberOfGuests;
  // final String createdAt;
  // final String status;

  OrderTile({
    required this.order,
    // required this.orderId,
    // required this.tableNumber,
    // required this.numberOfGuests,
    // required this.createdAt,
    // required this.status,
  });

  @override
  Widget build(BuildContext context) {
    int numberOfGuests = order['orderDetails'].length;
    String createdAt = order['createdAt'] != null
        ? DateFormat('dd/MM HH:mm').format(order['createdAt'].toDate())
        : 'N/A';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdminOrderInfoScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side - Order Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Table ${order['tableNum']} Order",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "$numberOfGuests Guests",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            // Right Side - Created At and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      createdAt,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order['status'] == "New"
                        ? AppColors.lightTeal
                        : order['status'] == "In Progress"
                            ? AppColors.secondaryOrange
                            : order['status'] == "Served"
                                ? AppColors.primaryOrange
                                : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
