import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RestaurantProvider with ChangeNotifier {
  String? restaurantName;
  String? logoURL;
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
      logoURL = restaurantDoc['logoURL'];
      restaurantId = restaurantDoc.id;
      isLoading = false;
      notifyListeners();
    }
  }
}
