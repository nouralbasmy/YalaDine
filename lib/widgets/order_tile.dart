import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class OrderTile extends StatelessWidget {
  final String orderId;
  final String tableNumber;
  final int numberOfGuests;
  final String createdAt;
  final String status;

  OrderTile({
    required this.orderId,
    required this.tableNumber,
    required this.numberOfGuests,
    required this.createdAt,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                "Table $tableNumber Order",
                style: TextStyle(
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
                  color: status == "New"
                      ? AppColors.lightTeal
                      : status == "In Progress"
                          ? AppColors.secondaryOrange
                          : status == "Pending Payment"
                              ? AppColors.primaryOrange
                              : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status,
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
    );
  }
}
