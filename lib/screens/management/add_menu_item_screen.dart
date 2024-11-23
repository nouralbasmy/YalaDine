import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class AddMenuItemScreen extends StatefulWidget {
  @override
  _AddMenuItemScreenState createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // List to hold multiple menu items
  List<Map<String, dynamic>> menuItems = [
    {
      'name': '',
      'category': 'Appetizers',
      'price': '',
      'description': '',
      'imageUrl': '',
      'rating': 0.0, // Default value for rating
      'numOfRatings': 0, // Default value for number of ratings
    }
  ];

  // Category dropdown options
  final List<String> categories = [
    "Appetizers",
    "Main Course",
    "Sides",
    "Desserts",
    "Beverages"
  ];

  @override
  Widget build(BuildContext context) {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    String? restaurantId = restaurantProvider.restaurantId;
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Menu Item(s)"),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loop through the list of menu items to create fields for each
                for (int index = 0; index < menuItems.length; index++) ...[
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image URL Field
                          TextFormField(
                            initialValue: menuItems[index]['imageUrl'],
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                menuItems[index]['imageUrl'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Image URL cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Name Field
                          TextFormField(
                            initialValue: menuItems[index]['name'],
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                menuItems[index]['name'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            value: menuItems[index]['category'],
                            onChanged: (newValue) {
                              setState(() {
                                menuItems[index]['category'] = newValue!;
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
                          ),
                          const SizedBox(height: 16),

                          // Price Field
                          TextFormField(
                            initialValue: menuItems[index]['price'],
                            decoration: InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                menuItems[index]['price'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Price cannot be empty';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Enter a valid number for price';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Description Field
                          TextFormField(
                            initialValue: menuItems[index]['description'],
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            maxLines: 3,
                            onChanged: (value) {
                              setState(() {
                                menuItems[index]['description'] = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Add/Remove Item Buttons
                          if (index == menuItems.length - 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Remove item
                                if (menuItems.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        menuItems.removeAt(index);
                                      });
                                    },
                                  ),
                                // Add item
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      menuItems.add({
                                        'name': '',
                                        'category': 'Appetizers',
                                        'price': '',
                                        'description': '',
                                        'imageUrl': '',
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Add Menu Item Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        try {
                          for (var item in menuItems) {
                            item['rating'] = 0.0; // Default rating value
                            item['numOfRatings'] =
                                0; // Default number of ratings
                          }
                          // Add menu items using the addMenuItems method
                          await menuProvider.addMenuItems(
                            restaurantId!,
                            menuItems,
                          );

                          // Clear the form after saving
                          setState(() {
                            menuItems = [
                              {
                                'name': '',
                                'category': 'Appetizers',
                                'price': '',
                                'description': '',
                                'imageUrl': '',
                              }
                            ];
                          });

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Menu item(s) added successfully!')),
                          );

                          // Optionally, navigate back
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to add menu items: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryOrange,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add Menu Item(s)',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
