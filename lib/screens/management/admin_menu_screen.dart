import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/menu_item_card.dart';

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

  final List<Map<String, String>> _menuItems = [
    {
      "title": "Club Sandwich",
      "category": "Main Course",
      "price": "25.00",
      "rating": "4.8",
      "imageUrl":
          "https://assets3.thrillist.com/v1/image/1202445/414x310/crop;webp=auto;jpeg_quality=60;progressive.jpg"
    },
    {
      "title": "Meat & Mushrooms",
      "category": "Main Course",
      "price": "37.00",
      "rating": "5.0",
      "imageUrl":
          "https://thewoksoflife.com/wp-content/uploads/2018/10/beef-with-mushrooms-18.jpg"
    },
    {
      "title": "Egg & Bread",
      "category": "Main Course",
      "price": "25.00",
      "rating": "4.7",
      "imageUrl":
          "https://www.giverecipe.com/wp-content/uploads/2018/04/Eggy-Bread-Recipe.jpg"
    },
    {
      "title": "Sweet Pancake",
      "category": "Desserts",
      "price": "13.00",
      "rating": "4.9",
      "imageUrl":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEK-wstyZfg1RmJBdQRJ0-6ADy8AjSTXz4Yg&s"
    },
    // Add more menu items as needed
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
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: [
          // Tab Bar at the top
          Container(
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFFFF6F00),
              labelColor: Color(0xFFFF6F00),
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: _categories.map((category) {
                return Tab(
                  text: category,
                );
              }).toList(),
              onTap: (index) {
                setState(() {
                  selectedCategory = _categories[index];
                });
              },
            ),
          ),
          // TabBarView to display the Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                // Filter items based on selected category
                List<Map<String, String>> filteredItems =
                    _menuItems.where((item) {
                  return category == "All" || item["category"] == category;
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
                    return MenuItemCard(
                      imageUrl: item["imageUrl"]!,
                      title: item["title"]!,
                      price: item["price"]!,
                      rating: double.parse(item["rating"]!),
                      actionButton: IconButton(
                        icon:
                            Icon(Icons.edit, color: AppColors.secondaryOrange),
                        onPressed: () {
                          //to be done
                        },
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
