import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yala_dine/widgets/order_tile.dart';

class AdminOrdersList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const AdminOrdersList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text("No orders available."));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        String createdAt = order['createdAt'] != null
            ? DateFormat('dd/MM HH:mm').format(order['createdAt'].toDate())
            : 'N/A';
        // int numberOfGuests = order['orderDetails'].length;
        return OrderTile(
          order: order,
          // orderId: order['id'] ?? 'Unknown',
          // tableNumber: order['tableNum'] ?? 'N/A',
          // numberOfGuests: numberOfGuests,
          // createdAt: createdAt,
          // status: order['status'] ?? 'Unknown',
        );
      },
    );
  }
}
