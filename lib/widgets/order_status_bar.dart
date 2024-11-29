import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class OrderStatusBar extends StatelessWidget {
  final String currentStatus;
  // final Function(String) onStatusChanged;

  OrderStatusBar({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    List<String> statuses = ['New', 'In Progress', 'Served'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: statuses.map<Widget>((status) {
          bool isSelected = currentStatus == status;

          return Expanded(
            child: GestureDetector(
              onTap: () => {print("STATUS CHANGED")},
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
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
