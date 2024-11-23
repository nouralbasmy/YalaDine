import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuProvider with ChangeNotifier {
  List<Map<String, dynamic>> menuItems = [];
  bool isLoading = true;
  // Fetch menu items from the sub-collection
  Future<void> fetchMenuItems(String restaurantId) async {
    try {
      isLoading = true;
      final menuCollection = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu');

      final snapshot = await menuCollection.get();

      // Map each document to a local list
      menuItems = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Use the Firestore document ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error fetching menu items: $e");
      throw Exception("Failed to fetch menu items");
    }
  }

  // Add menu items to the sub-collection
  Future<void> addMenuItems(
      String restaurantId, List<Map<String, dynamic>> items) async {
    try {
      final menuCollection = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu');

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var item in items) {
        var docRef = menuCollection.doc(); // Generate a unique ID
        batch.set(docRef, item); // Add item to batch

        item['id'] = docRef.id; // Add the generated ID to the item locally
      }

      await batch.commit(); // Commit batch to Firestore

      // Update the local version
      for (var item in items) {
        menuItems.add(item);
      }

      notifyListeners();
    } catch (error) {
      print("Error adding menu items: $error");
      throw Exception("Failed to add menu items");
    }
  }

  Future<void> updateMenuItem(String restaurantId, String itemId,
      Map<String, dynamic> updatedData) async {
    try {
      final menuDoc = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(itemId);

      await menuDoc.update(updatedData);

      // Update the local state
      final itemIndex = menuItems.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        menuItems[itemIndex] = {
          'id': itemId,
          ...updatedData,
        };
        notifyListeners();
      }
    } catch (error) {
      print("Error updating menu item: $error");
      throw Exception("Failed to update menu item");
    }
  }

  Future<void> deleteMenuItem(String restaurantId, String itemId) async {
    try {
      final menuDoc = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu')
          .doc(itemId);

      await menuDoc.delete();

      // Update the local state
      menuItems.removeWhere((item) => item['id'] == itemId);
      notifyListeners();
    } catch (error) {
      print("Error deleting menu item: $error");
      throw Exception("Failed to delete menu item");
    }
  }
}
