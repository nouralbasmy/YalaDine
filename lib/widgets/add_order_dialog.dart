import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:provider/provider.dart';

class AddOrderDialog extends StatefulWidget {
  const AddOrderDialog({super.key});

  @override
  State<AddOrderDialog> createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controller to manage text input
  final TextEditingController _tableNumController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _tableNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return AlertDialog(
      title: const Text("New Order"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Table Number Field
              TextFormField(
                controller: _tableNumController,
                decoration: const InputDecoration(labelText: 'Table Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a table number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        // Submit button
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final restaurantProvider =
                      Provider.of<RestaurantProvider>(context, listen: false);
                  final restaurantId = restaurantProvider.restaurantId;

                  final tableNum = _tableNumController.text.trim();

                  // new order data
                  final newOrder = {
                    "restaurantId": restaurantId,
                    "tableNum": tableNum,
                    "orderDetails": {}, //EDITED
                    "status": "New",
                    "totalPrice": 0.0,
                    "createdAt": Timestamp.now(),
                    "splitRequests": [],
                    //"splitMethod": "Undecided" //options: Undecided, Equally, ByItem
                  };

                  await orderProvider.addOrder(newOrder);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Order created successfully!")),
                  );

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to create order: $e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryOrange,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 16.0), // Text size
            ),
          ),
        ),
      ],
    );
  }
}
