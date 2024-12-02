import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/client_menu_item_details_bottomsheet.dart';
import 'package:yala_dine/widgets/menu_item_card.dart';

class ClientMenuScreen extends StatefulWidget {
  final String restaurantId;
  const ClientMenuScreen({super.key, required this.restaurantId});

  @override
  State<ClientMenuScreen> createState() => _ClientMenuScreenState();
}

class _ClientMenuScreenState extends State<ClientMenuScreen>
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
    final menuProvider = Provider.of<MenuProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (menuProvider.menuItems.isEmpty && !menuProvider.isMenuEmpty) {
      // Fetch menu items
      menuProvider.fetchMenuItems(widget.restaurantId);
    }
    if (restaurantProvider.restaurantName == null) {
      restaurantProvider.fetchRestaurantByID(widget.restaurantId);
    }

    if (menuProvider.menuItems.isEmpty && !menuProvider.isLoading) {
      return const Center(
          child: Text("Oops! No items here yet. Stay tuned for updates!"));
    }
    return Scaffold(
        appBar: AppBar(
          title: restaurantProvider.isLoading
              ? const Text("Loading...")
              : Text(restaurantProvider.restaurantName ?? "Restaurant"),
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
        ),
        body: Padding(
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
                                return ClientMenuItemDetailsBottomSheet(
                                  id: item['id'] ?? '', // Pass the item ID
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
                            actionButton: Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              height: MediaQuery.of(context).size.width * 0.1,
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: IconButton(
                                  icon: Icon(Icons.add, color: Colors.white),
                                  onPressed: () {
                                    //ADD TO ORDER
                                  }),
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
        ));
  }
}
