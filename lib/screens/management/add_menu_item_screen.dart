import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class AddMenuItemScreen extends StatefulWidget {
  @override
  _AddMenuItemScreenState createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  List<Map<String, String>> menuItemsData = [
    {
      "imageURL": "",
      "title": "",
      "description": "",
      "category": "Appetizer",
      "price": "",
      "imageUrl": "",
    },
  ];

  // Categories
  List<String> categories = [
    "Appetizers",
    "Main Course",
    "Sides",
    "Desserts",
    "Beverages"
  ];

  // Add another item form
  void addNewItem() {
    setState(() {
      menuItemsData.add({
        "imageURL": "",
        "title": "",
        "description": "",
        "category": "Appetizers",
        "price": "",
        "imageUrl": "",
      });
    });
  }

  // Remove the last item form
  void removeLastItem() {
    setState(() {
      if (menuItemsData.length > 1) {
        menuItemsData.removeLast();
      }
    });
  }

  void submitItems() {
    print(menuItemsData);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu items added successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Menu Item(s)'),
      ),
      body: ListView.builder(
        itemCount: menuItemsData.length,
        itemBuilder: (context, index) {
          var currentItem = menuItemsData[index]; // Get current item

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image URL
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          currentItem["imageURL"] = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Title
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          currentItem["title"] = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Category Dropdown (correct styling)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButton<String>(
                        value: currentItem["category"], // Valid category
                        onChanged: (String? newValue) {
                          setState(() {
                            currentItem["category"] = newValue!;
                          });
                        },
                        isExpanded: true, // Make the dropdown take full width
                        items: categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        iconEnabledColor: Colors.black, // Customize icon color
                      ),
                    ),
                    SizedBox(height: 10),

                    // Description
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      onChanged: (value) {
                        setState(() {
                          currentItem["description"] = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    // Price
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          currentItem["price"] = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    if (index ==
                        menuItemsData.length - 1) // Only show on last card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Add New Item Button
                          IconButton(
                            icon: Icon(Icons.add_circle,
                                color: AppColors.secondaryOrange),
                            onPressed: addNewItem,
                          ),
                          // Remove Item Button (only last card)
                          if (menuItemsData.length >
                              1) // no remove button if there's only 1 card
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.grey),
                              onPressed: removeLastItem,
                            ),
                        ],
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: submitItems,
        child: Icon(Icons.check),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        tooltip: 'Submit All Items',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}
