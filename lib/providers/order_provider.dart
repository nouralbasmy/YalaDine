import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  bool isOrdersEmpty = false;

  // Fetch orders for a specific restaurant
  Future<void> fetchOrders(String restaurantId) async {
    try {
      isLoading = true;
      final ordersCollection = FirebaseFirestore.instance
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId);

      final snapshot = await ordersCollection.get();

      if (snapshot.docs.isEmpty) {
        isOrdersEmpty = true;
        isLoading = false;
        notifyListeners();
        return;
      }

      isOrdersEmpty = false;

      // Map each document to a local list
      orders = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Use Firestore document ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error fetching orders: $e");
      throw Exception("Failed to fetch orders");
    }
  }

  // Add a new order
  Future<void> addOrder(Map<String, dynamic> newOrder) async {
    try {
      isLoading = true;
      notifyListeners();

      final ordersCollection = FirebaseFirestore.instance.collection('orders');

      // Add the new order to Firestore
      final docRef = await ordersCollection.add(newOrder);

      // Add the new order to the local list
      orders.add({
        'id': docRef.id, // Firestore generated ID
        ...newOrder,
      });

      isOrdersEmpty = false; // Since a new order was added
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error adding order: $e");
      throw Exception("Failed to add order");
    }
  }

  // // Update an existing order
  // Future<void> updateOrder(
  //     String orderId, Map<String, dynamic> updatedData) async {
  //   try {
  //     isLoading = true;
  //     notifyListeners();

  //     final orderDoc =
  //         FirebaseFirestore.instance.collection('orders').doc(orderId);

  //     // Update the order in Firestore
  //     await orderDoc.update(updatedData);

  //     // Update the local list
  //     final index = orders.indexWhere((order) => order['id'] == orderId);
  //     if (index != -1) {
  //       orders[index] = {
  //         ...orders[index],
  //         ...updatedData,
  //       };
  //     }

  //     isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     isLoading = false;
  //     print("Error updating order: $e");
  //     throw Exception("Failed to update order");
  //   }
  // }

  // // Delete an order
  // Future<void> deleteOrder(String orderId) async {
  //   try {
  //     isLoading = true;
  //     notifyListeners();

  //     final orderDoc =
  //         FirebaseFirestore.instance.collection('orders').doc(orderId);

  //     // Delete the order from Firestore
  //     await orderDoc.delete();

  //     // Remove the order from the local list
  //     orders.removeWhere((order) => order['id'] == orderId);

  //     if (orders.isEmpty) {
  //       isOrdersEmpty = true;
  //     }

  //     isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     isLoading = false;
  //     print("Error deleting order: $e");
  //     throw Exception("Failed to delete order");
  //   }
  // }
}
