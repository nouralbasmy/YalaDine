import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/menu_item_card.dart';
import 'package:yala_dine/widgets/menu_item_details_bottomsheet.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    "All",
    "Appetizers",
    "Main Course",
    "Sides",
    "Desserts",
    "Beverages"
  ];

  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);

    if (restaurantProvider.restaurantId != null &&
        menuProvider.menuItems.isEmpty &&
        !menuProvider.isMenuEmpty) {
      // Fetch menu items
      menuProvider.fetchMenuItems(restaurantProvider.restaurantId!);
    }

    if (menuProvider.menuItems.isEmpty && !menuProvider.isLoading) {
      return Center(child: Text("No items available. Add some menu items."));
    }

    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Tab Bar for categories
          TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFFFF6F00),
            labelColor: Color(0xFFFF6F00),
            unselectedLabelColor: Colors.grey,
            isScrollable: true,
            tabs: _categories.map((category) {
              return Tab(text: category);
            }).toList(),
            onTap: (index) {
              setState(() {
                selectedCategory = _categories[index];
              });
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                // Filter items by category
                List<Map<String, dynamic>> filteredItems =
                    menuProvider.menuItems.where((item) {
                  String? itemCategory = item['category'] as String?;
                  return category == "All" || itemCategory == category;
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(6.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    var item = filteredItems[index];

                    return GestureDetector(
                      onTap: () {
                        // Open the bottom sheet with item details, passing the item ID
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return MenuItemDetailsBottomSheet(
                              id: item['id'] ?? '', // Pass the item ID
                              name: item['name'] ?? 'No title',
                              description:
                                  item['description'] ?? 'No description',
                              price: item['price']?.toString() ?? '0.00',
                              category: item['category'] ?? 'No Category',
                              imageUrl: item['imageUrl'] ?? '',
                              rating: double.tryParse(
                                      item['rating']?.toString() ?? '0.0') ??
                                  0.0,
                              numOfRatings: int.tryParse(
                                      item['numOfRatings']?.toString() ?? '') ??
                                  0,
                              isEditing: false, // Default is not editing
                            );
                          },
                        );
                      },
                      child: MenuItemCard(
                        imageUrl: item['imageUrl'] ?? '',
                        title: item['name'] ?? 'No title',
                        price: item['price']?.toString() ?? '0.00',
                        rating: item['numOfRatings'] == 0
                            ? "N/A"
                            : item['rating']?.toString() ?? "N/A",
                        actionButton: IconButton(
                          icon: Icon(Icons.edit,
                              color: AppColors.secondaryOrange),
                          onPressed: () {
                            // Open the bottom sheet in edit mode
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return MenuItemDetailsBottomSheet(
                                  id: item['id'] ?? '',
                                  name: item['name'] ?? 'No title',
                                  description:
                                      item['description'] ?? 'No description',
                                  price: item['price']?.toString() ?? '0.00',
                                  category: item['category'] ?? 'No Category',
                                  imageUrl: item['imageUrl'] ?? '',
                                  rating: double.tryParse(
                                          item['rating']?.toString() ??
                                              '0.0') ??
                                      0.0,
                                  numOfRatings: int.tryParse(
                                          item['numOfRatings']?.toString() ??
                                              '') ??
                                      0,
                                  isEditing:
                                      true, // Set isEditing to true for editing mode
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
