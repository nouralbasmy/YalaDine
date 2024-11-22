import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yala_dine/screens/management/add_menu_item_screen.dart';
import 'package:yala_dine/screens/management/admin_menu_screen.dart';
import 'package:yala_dine/screens/management/admin_offer_screen.dart';
import 'package:yala_dine/screens/management/admin_order_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

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
  void switchPage(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  String? adminName = "";
  String? restaurantName = "";
  String? logoURL = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserAndRestaurantInfo();
  }

  // Method to fetch the admin's name and restaurant info from Firestore
  void _getUserAndRestaurantInfo() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
    if (user != null) {
      // Fetch the user info
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      //print(userDoc);
      // Fetch the restaurant info associated with this admin
      DocumentSnapshot restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('adminID',
              isEqualTo: user
                  .uid) // Find the restaurant where the adminId matches the userId
          .limit(1)
          .get()
          .then((snapshot) {
        //if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
        //} //else {
        //   return null;
        // }
      });

      if (restaurantDoc != null) {
        setState(() {
          restaurantName = restaurantDoc['restaurantName'];
          logoURL = restaurantDoc['logoURL'];
          adminName = userDoc['name'];
          isLoading = false; // Data fetching is complete
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        title: Text(
          '$restaurantName',
          // style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.logout))],
      ),
      body: adminTabs[selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
                  MaterialPageRoute(builder: (context) => AddMenuItemScreen()),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Color(0xFFFF6F00),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
