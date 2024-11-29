import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/offer_provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/auth/login_screen.dart';
import 'package:yala_dine/screens/management/add_menu_item_screen.dart';
import 'package:yala_dine/screens/management/admin_menu_screen.dart';
import 'package:yala_dine/screens/management/admin_offer_screen.dart';
import 'package:yala_dine/screens/management/admin_order_screen.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/add_offer_form.dart';
import 'package:yala_dine/widgets/add_order_dialog.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<Widget> adminTabs = [
    AdminMenuScreen(),
    AdminOrderScreen(),
    AdminOfferScreen()
  ];
  var selectedTabIndex = 1;

  // This is called when the tab is switched
  void switchPage(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Call fetchAdminRestaurantInfo on screen load
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    restaurantProvider.fetchAdminRestaurantInfo();
  }

  Future<void> _logout() async {
    try {
      // Sign out the user from Firebase
      await FirebaseAuth.instance.signOut();

      //Clearing cached data
      final restaurantProvider =
          Provider.of<RestaurantProvider>(context, listen: false);
      restaurantProvider.restaurantId = "";
      restaurantProvider.restaurantName = "";
      restaurantProvider.logoUrl = "";
      restaurantProvider.isLoading = true;

      final offerProvider = Provider.of<OfferProvider>(context, listen: false);
      offerProvider.offers = [];
      offerProvider.isLoading = true;
      offerProvider.isOffersEmpty = false;

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.orders = [];
      orderProvider.isLoading = true;
      orderProvider.isOrdersEmpty = false;

      final menuProvider = Provider.of<MenuProvider>(context, listen: false);
      menuProvider.menuItems = [];
      menuProvider.isLoading = true;
      menuProvider.isMenuEmpty = false;

      // Redirect to login screen after logging out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle any errors that might occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          title: Consumer<RestaurantProvider>(
            builder: (context, restaurantProvider, child) {
              // Check if the restaurant data is still loading
              if (restaurantProvider.isLoading) {
                return Text("Loading...");
              }
              return Text(restaurantProvider.restaurantName ?? "Restaurant");
            },
          ),
          actions: [
            IconButton(
              onPressed: _logout,
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: adminTabs[selectedTabIndex], // Switch between tabs
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
            BottomNavigationBarItem(
                icon: Icon(Icons.library_books), label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_offer), label: 'Offers')
          ],
          currentIndex: selectedTabIndex,
          onTap: switchPage,
        ),
        floatingActionButton: selectedTabIndex == 0 // FAB in AdminMenuScreen
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddMenuItemScreen()),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: Color(0xFFFF6F00),
                foregroundColor: Colors.white,
              )
            : selectedTabIndex == 2
                ? FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AddOfferForm();
                        },
                      );
                    },
                    child: Icon(Icons.add),
                    backgroundColor: AppColors.secondaryOrange,
                    foregroundColor: Colors.white,
                  )
                : selectedTabIndex == 1
                    ? FloatingActionButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddOrderDialog();
                            },
                          );
                        },
                        child: Icon(Icons.add),
                        backgroundColor: AppColors.secondaryOrange,
                        foregroundColor: Colors.white,
                      )
                    : null);
  }
}
