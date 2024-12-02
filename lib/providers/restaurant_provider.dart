import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantProvider with ChangeNotifier {
  String? restaurantName;
  String? logoUrl;
  String? restaurantId;
  bool isLoading = true;

  Future<void> fetchAdminRestaurantInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the restaurant of logged in admin ID
      DocumentSnapshot restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .where('adminID', isEqualTo: user.uid)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      restaurantName = restaurantDoc['restaurantName'];
      logoUrl = restaurantDoc['logoUrl'];
      // print(logoURL);

      restaurantId = restaurantDoc.id;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> fetchRestaurantByID(String restaurantID) async {
    try {
      isLoading = true;
      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantID)
          .get();

      if (!restaurantDoc.exists) {
        isLoading = false;
        return null;
      }

      restaurantName = restaurantDoc['restaurantName'];
      logoUrl = restaurantDoc['logoUrl'];
      isLoading = false;
      return {
        'id': restaurantDoc.id,
        ...restaurantDoc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      print("Error fetching restaurant by ID: $e");
      throw Exception("Failed to fetch restaurant by ID");
    }
  }
}
