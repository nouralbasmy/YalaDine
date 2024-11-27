import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/offer_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';

class AddOfferForm extends StatefulWidget {
  const AddOfferForm({super.key});

  @override
  State<AddOfferForm> createState() => _AddOfferFormState();
}

class _AddOfferFormState extends State<AddOfferForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to manage text input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Offer"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Offer Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Offer Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              // Offer Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              // Discount Percentage Field
              TextFormField(
                controller: _discountController,
                decoration:
                    const InputDecoration(labelText: 'Discount Percentage (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount percentage';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              // Minimum Order Total Field
              TextFormField(
                controller: _minOrderController,
                decoration:
                    const InputDecoration(labelText: 'Minimum Order Total'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a minimum order total';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog without saving
          },
          child: const Text('Cancel'),
        ),
        // Submit button
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // new offer from form data
              final newOffer = {
                'title': _titleController.text,
                'description': _descriptionController.text,
                'discount':
                    (double.parse(_discountController.text) / 100).toDouble(),
                'minOrderTotal': double.parse(_minOrderController.text),
                'isActive': true, // Default value on creation
              };

              try {
                final restaurantProvider =
                    Provider.of<RestaurantProvider>(context, listen: false);
                final restaurantId = restaurantProvider.restaurantId;

                if (restaurantId == null) {
                  throw Exception("No restaurant ID found.");
                }

                await Provider.of<OfferProvider>(context, listen: false)
                    .addOffer(restaurantId, newOffer);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Offer added successfully!")),
                );

                Navigator.of(context).pop(); // Close the dialog
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add offer: $e")),
                );
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
