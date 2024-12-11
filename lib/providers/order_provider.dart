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

  // Method to update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      isLoading = true;
      notifyListeners();

      // Reference to the order in Firestore
      final orderDocRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Update the status field in Firestore
      await orderDocRef.update({'status': newStatus});

      // Find and update the order in the local list
      final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        orders[orderIndex]['status'] = newStatus; // Update the status locally
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error updating order status: $e");
      throw Exception("Failed to update order status");
    }
  }

  Future<Map<String, dynamic>?> fetchOrderByOrderId(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        return null;
      }

      return {
        'id': orderDoc.id, // Order ID
        ...orderDoc.data() as Map<String, dynamic>, // Order details
      };
    } catch (e) {
      print("Error fetching order by ID: $e");
      throw Exception("Failed to fetch order by ID");
    }
  }

  Future<void> addUserToOrder(String orderId, String userId) async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Get the existing order details
      final orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;

      // Fetch the user's name from the users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found");
      }

      final userName = userDoc.data()?['name'] ?? 'Unknown User';

      // Add user to orderDetails
      final orderDetails = orderData['orderDetails'] ?? {};
      print(orderDetails);
      if (!orderDetails.containsKey(userId)) {
        orderDetails[userId] = {
          "name": userName,
          "menuItems": [], // initially empty for just added users to order
          "isPaid": false,
        };
      }

      // Update Firestore
      await orderRef.update({'orderDetails': orderDetails});

      notifyListeners();
    } catch (e) {
      print("Error adding user to order: $e");
      throw Exception("Failed to add user to order");
    }
  }

  Future<void> addItemToOrder(String orderId, String userId, String itemId,
      String name, double price, int quantity, String specialRequest) async {
    try {
      isLoading = true;
      notifyListeners();

      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Get the existing order details
      final orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderDetails = orderData['orderDetails'] ?? {};

      // Check if the user already has menuItems
      List<dynamic> menuItems = orderDetails[userId]["menuItems"] ?? [];

      // Check if the item with itemId already exists in the menuItems
      final existingItemIndex =
          menuItems.indexWhere((item) => item['itemId'] == itemId);

      if (existingItemIndex != -1) {
        // If item exists, update the quantity
        menuItems[existingItemIndex]['quantity'] += quantity;
      } else {
        // If item doesn't exist, create a new item entry
        final newItem = {
          "itemId": itemId, // Add itemId for easier identification
          "name": name,
          "price": price,
          "quantity": quantity,
          "specialRequest": specialRequest,
        };
        menuItems.add(newItem);
      }

      // Update Firestore with the updated menuItems list
      orderDetails[userId]["menuItems"] = menuItems;
      await orderRef.update({'orderDetails': orderDetails});

      // Update the local state
      final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        orders[orderIndex]['orderDetails'] = orderDetails;
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error adding item to order: $e");
      throw Exception("Failed to add item to order");
    }
  }
}
