import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
        title: const Text('Admin Home Page'),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading while fetching data
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display restaurant logo and name
                  if (logoURL != null)
                    Image.network(
                      logoURL!, // Display restaurant logo from the URL
                      width: 100,
                      height: 100,
                    ),
                  const SizedBox(height: 16),
                  if (restaurantName != null)
                    Text(
                      'Restaurant: $restaurantName',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16),
                  // Display the username of the admin
                  if (adminName != null)
                    Text(
                      'Welcome, $adminName!',
                      style: TextStyle(fontSize: 24),
                    ),
                ],
              ),
            ),
    );
  }
}
