import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/menu_provider.dart';
import 'package:yala_dine/providers/offer_provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/screens/auth/login_screen.dart';
import 'package:yala_dine/screens/client/client_offers_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientHomeDrawer extends StatelessWidget {
  const ClientHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: AppColors.primaryOrange,
            child: const Text(
              'Yala Dine',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                  color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text("Offers"),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientOffersScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("Past Orders"),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              print("Past orders clicked");
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
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

                final offerProvider =
                    Provider.of<OfferProvider>(context, listen: false);
                offerProvider.offers = [];
                offerProvider.isLoading = true;
                offerProvider.isOffersEmpty = false;

                final orderProvider =
                    Provider.of<OrderProvider>(context, listen: false);
                orderProvider.orders = [];
                orderProvider.isLoading = true;
                orderProvider.isOrdersEmpty = false;

                final menuProvider =
                    Provider.of<MenuProvider>(context, listen: false);
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
            },
          ),
        ],
      ),
    );
  }
}
