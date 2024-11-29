import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart'; // Assuming the provider is in this location

class OrderStatusBar extends StatefulWidget {
  final String currentStatus;
  final String orderID;

  OrderStatusBar({required this.currentStatus, required this.orderID});

  @override
  _OrderStatusBarState createState() => _OrderStatusBarState();
}

class _OrderStatusBarState extends State<OrderStatusBar> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus =
        widget.currentStatus; // Initialize with the current status passed
  }

  @override
  Widget build(BuildContext context) {
    List<String> statuses = ['New', 'In Progress', 'Served'];

    bool isPaid = _currentStatus == 'Paid';
    if (isPaid) {
      return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'Completed',
          style: TextStyle(
            color: AppColors.greyBackground,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: statuses.map<Widget>((status) {
          bool isSelected = _currentStatus == status;

          return Expanded(
            child: GestureDetector(
              onTap: isPaid
                  ? null // Prevent tapping if the status is "Paid"
                  : () async {
                      await context
                          .read<OrderProvider>()
                          .updateOrderStatus(widget.orderID, status);

                      // Update the local status immediately after Firestore update
                      setState(() {
                        _currentStatus = status;
                      });
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondaryOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryOrange
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isPaid
                          ? Colors.grey
                          : Colors.black, // Dim text if Paid
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
