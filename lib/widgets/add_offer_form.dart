import 'package:flutter/material.dart';

class AddOfferForm extends StatelessWidget {
  const AddOfferForm({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>(); // Key for form validation

    // Controllers to manage text input
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _discountController = TextEditingController();
    TextEditingController _minOrderController = TextEditingController();
    return AlertDialog(
      title: Text("Add New Offer"),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Offer Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Offer Title'),
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
                decoration: InputDecoration(labelText: 'Description'),
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
                decoration: InputDecoration(labelText: 'Discount Percentage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount percentage';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minOrderController,
                decoration: InputDecoration(labelText: 'Minimum Order Total'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a minimum order total';
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
          child: Text('Cancel'),
        ),
        // Submit button
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Retrieve form values
              String title = _titleController.text;
              String description = _descriptionController.text;
              double discount = double.parse(_discountController.text);
              double minOrderTotal = double.parse(_minOrderController.text);

              // Set the status to active by default
              String status = 'Active';

              //widget.onSubmit(title, description, discount);

              // Close the dialog after submitting
              Navigator.of(context).pop();
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
