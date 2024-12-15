import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/screens/client/client_table_order_details_first_screen.dart';
import 'package:yala_dine/screens/client/client_table_order_details_second_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/client_menu_item_details_bottomsheet.dart';
import 'package:yala_dine/widgets/menu_item_card.dart';

class ClientMenuScreen extends StatefulWidget {
  final String restaurantId;
  final String orderID;
  const ClientMenuScreen(
      {super.key, required this.restaurantId, required this.orderID});

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
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider
        .listenForOrderStatusChanges(widget.orderID)
        .listen((orderSnapshot) {
      if (orderSnapshot.exists) {
        final orderData = orderSnapshot.data() as Map<String, dynamic>;
        final status = orderData['status'];

        if (status == 'In Progress') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ClientTableOrderDetailsSecondScreen(
                orderID: widget.orderID,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showQRCodeDialog(BuildContext context, String orderID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Table Order Code"),
          content: SingleChildScrollView(
            // Allow scrolling if content overflows
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  // wrapped QrImageView in SizedBox to give specific size
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: orderID,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Order ID: $orderID",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (menuProvider.menuItems.isEmpty && !menuProvider.isMenuEmpty) {
      // Fetch menu items
      menuProvider.fetchMenuItems(widget.restaurantId);
    }
    if (restaurantProvider.restaurantName == null ||
        restaurantProvider.restaurantName == "") {
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
        automaticallyImplyLeading: false,
        // backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.darkGrey,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code),
            onPressed: () {
              showQRCodeDialog(context, widget.orderID);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(4.0),
            child: Column(
              children: [
                // Tab Bar for categories
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.secondaryOrange,
                  labelColor: AppColors.secondaryOrange,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    orderID: widget.orderID,
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
                              // actionButton: Container(
                              //   width: MediaQuery.of(context).size.width * 0.1,
                              //   height: MediaQuery.of(context).size.width * 0.1,
                              //   decoration: BoxDecoration(
                              //     color: AppColors.secondaryOrange,
                              //     borderRadius: BorderRadius.circular(8.0),
                              //   ),
                              // child: IconButton(
                              //   icon: Icon(Icons.add, color: Colors.white),
                              //   onPressed: () async {
                              //     try {
                              //       final orderProvider =
                              //           Provider.of<OrderProvider>(context,
                              //               listen: false);

                              //       String orderId = widget.orderID;
                              //       User? user =
                              //           FirebaseAuth.instance.currentUser;
                              //       final clientId = user!.uid;

                              //       await orderProvider.addItemToOrder(
                              //         orderId,
                              //         clientId,
                              //         item['name'], // Item name
                              //         double.parse(item['price'].toString()),
                              //         1, // Default quantity 1
                              //         "", //quick add so no special request
                              //       );

                              //       // Show a success message or close the sheet
                              //       ScaffoldMessenger.of(context)
                              //           .showSnackBar(
                              //         SnackBar(
                              //           content: Text(
                              //               '${item['name']} added to your order!'),
                              //           backgroundColor:
                              //               AppColors.secondaryOrange,
                              //         ),
                              //       );

                              //       Navigator.of(context)
                              //           .pop(); // Close the bottom sheet
                              //     } catch (e) {
                              //       // Handle errors
                              //       ScaffoldMessenger.of(context)
                              //           .showSnackBar(
                              //         SnackBar(
                              //           content: Text(
                              //               'Failed to add item to order: $e'),
                              //           backgroundColor: Colors.red,
                              //         ),
                              //       );
                              //     }
                              //   },
                              //),
                              //),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // TO BE ADDED
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ClientTableOrderDetailsFirstScreen(
                            orderID: widget.orderID,
                          )),
                );
                // print("View order Clicked");
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant,
                      size: 20,
                      color: Colors.white), // Add your chosen icon here
                  SizedBox(width: 8), // Space between icon and text
                  Text(
                    "View Order",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
