import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class MenuItemDetailsBottomSheet extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String category;
  final String price;
  final String imageUrl;
  final double rating;
  final int numOfRatings; //HENA
  final bool isEditing;

  const MenuItemDetailsBottomSheet(
      {Key? key,
      required this.id,
      required this.name,
      required this.category,
      required this.description,
      required this.price,
      required this.imageUrl,
      required this.rating,
      required this.numOfRatings,
      required this.isEditing})
      : super(key: key);

  @override
  _MenuItemDetailsBottomSheetState createState() =>
      _MenuItemDetailsBottomSheetState();
}

class _MenuItemDetailsBottomSheetState
    extends State<MenuItemDetailsBottomSheet> {
  late bool isEditing = widget.isEditing;
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;

  // Editable category
  late String selectedCategory;

  // List of available categories
  final List<String> categories = [
    "Appetizers",
    "Main Course",
    "Sides",
    "Desserts",
    "Beverages"
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    descriptionController = TextEditingController(text: widget.description);
    priceController = TextEditingController(text: widget.price);
    imageUrlController = TextEditingController(text: widget.imageUrl);
    selectedCategory = widget.category;
  }

  @override
  void dispose() {
    // Dispose controllers
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    String? restaurantId = restaurantProvider.restaurantId;
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Section
            if (widget.imageUrl.isNotEmpty && !isEditing)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  widget.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.yellow[600], size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.numOfRatings == 0
                                  ? "N/A"
                                  : widget.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category
                    if (isEditing)
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else
                      Text(
                        'Category: ${widget.category}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Price
                    if (isEditing)
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price cannot be empty';
                          }
                          return null;
                        },
                      )
                    else
                      Text(
                        '\EGP ${widget.price}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Description
                    if (isEditing)
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description cannot be empty';
                          }
                          return null;
                        },
                      )
                    else
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Image URL (Editable only in edit mode)
                    if (isEditing)
                      TextFormField(
                        controller: imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'Image URL',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Edit/Save and Delete Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Confirm before deleting
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Delete Menu Item"),
                                  content: Text(
                                      "Are you sure you want to delete this item?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm ?? false) {
                              await menuProvider.deleteMenuItem(
                                restaurantId!,
                                widget.id,
                              );
                              Navigator.pop(context); // Close bottom sheet
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGrey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 14),
                          ),
                          child: Icon(Icons.delete),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (isEditing) {
                              // Validate form before saving
                              if (_formKey.currentState!.validate()) {
                                // Save the updated data
                                final updatedData = {
                                  'name': widget.name,
                                  'rating': widget.rating,
                                  'numOfRatings': widget.numOfRatings,
                                  'description': descriptionController.text,
                                  'price': priceController.text,
                                  'category': selectedCategory,
                                  'imageUrl': imageUrlController.text,
                                };

                                await menuProvider.updateMenuItem(
                                    restaurantId!, widget.id, updatedData);

                                Navigator.pop(context); // Close the sheet
                              } else {
                                // Show error if validation fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please fill out all required fields'),
                                  ),
                                );
                              }
                            } else {
                              // Enter editing mode
                              setState(() {
                                isEditing = true;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEditing
                                ? AppColors.lightTeal
                                : AppColors.secondaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 60),
                          ),
                          child: Text(
                            isEditing ? 'Save' : 'Edit',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
