import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  bool isOrdersEmpty = false;

  // Fetch orders for a specific restaurant (management side fn)
  Future<void> fetchOrders(String restaurantId) async {
    try {
      isLoading = true;
      final ordersCollection = FirebaseFirestore.instance
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId);
      // print("restaurantId $restaurantId");
      final snapshot = await ordersCollection.get();
      // print("hena");

      if (snapshot.docs.isEmpty) {
        isOrdersEmpty = true;
        isLoading = false;
        // print("hena empty");

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
      // print("orders $orders");
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error fetching orders: $e");
      throw Exception("Failed to fetch orders");
    }
  }

  Stream<List<Map<String, dynamic>>> ordersStream(String restaurantId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Use Firestore document ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  // Add a new order (management side fn)
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
      //print(orderDetails);
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

  Future<void> addItemToOrder(
      String orderId,
      String userId,
      String itemID,
      String name,
      String imageUrl,
      double price,
      int quantity,
      String specialRequest) async {
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

      // Check if user already has menuItems
      List<dynamic> menuItems = orderDetails[userId]["menuItems"] ?? [];

      // Check if item already exists in the menuItems
      final existingItemIndex =
          menuItems.indexWhere((item) => item['itemID'] == itemID);

      if (existingItemIndex != -1) {
        // If item exists, update the quantity
        menuItems[existingItemIndex]['quantity'] += quantity;
      } else {
        // If item doesn't exist, create a new item entry
        final newItem = {
          "itemID": itemID,
          "name": name,
          "imageUrl": imageUrl,
          "price": price,
          "quantity": quantity,
          "specialRequest": specialRequest,
          "isShared": false,
          "sharedWith": []
        };
        menuItems.add(newItem);
      }

      // Update Firestore
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

  Future<void> updateMenuItemQuantity(
      String orderId, String userId, String itemID, int newQuantity) async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Fetch the existing order details
      final orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderDetails = orderData['orderDetails'] ?? {};

      // Update the specific menu item's quantity
      List<dynamic> menuItems = orderDetails[userId]["menuItems"] ?? [];
      final itemIndex =
          menuItems.indexWhere((item) => item['itemID'] == itemID);

      if (itemIndex != -1) {
        menuItems[itemIndex]['quantity'] = newQuantity;

        // Update Firestore
        orderDetails[userId]["menuItems"] = menuItems;
        await orderRef.update({'orderDetails': orderDetails});

        // Update local state
        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['orderDetails'] = orderDetails;
        }
        notifyListeners();
      } else {
        throw Exception("Menu item not found");
      }
    } catch (e) {
      print("Error updating menu item quantity: $e");
      throw Exception("Failed to update menu item quantity");
    }
  }

  Future<void> updateMenuItemSpecialRequest(
      String orderId, String userId, String itemID, String newRequest) async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Fetch the existing order details
      final orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderDetails = orderData['orderDetails'] ?? {};

      // Update the specific menu item's special request
      List<dynamic> menuItems = orderDetails[userId]["menuItems"] ?? [];
      final itemIndex =
          menuItems.indexWhere((item) => item['itemID'] == itemID);

      if (itemIndex != -1) {
        menuItems[itemIndex]['specialRequest'] = newRequest;

        // Update Firestore
        orderDetails[userId]["menuItems"] = menuItems;
        await orderRef.update({'orderDetails': orderDetails});

        // Update local state
        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['orderDetails'] = orderDetails;
        }
        notifyListeners();
      } else {
        throw Exception("Menu item not found");
      }
    } catch (e) {
      print("Error updating special request: $e");
      throw Exception("Failed to update special request");
    }
  }

  Future<void> removeItemFromOrder(
      String orderId, String userId, String itemID) async {
    try {
      isLoading = true;
      notifyListeners();

      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Fetch the existing order details
      final orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderDetails = orderData['orderDetails'] ?? {};

      // Get the menuItems for the user
      List<dynamic> menuItems = orderDetails[userId]["menuItems"] ?? [];

      // Find the index of the item to remove
      final itemIndex =
          menuItems.indexWhere((item) => item['itemID'] == itemID);

      if (itemIndex != -1) {
        // Remove the item from the menuItems list
        menuItems.removeAt(itemIndex);

        // Update Firestore with the updated menuItems list
        orderDetails[userId]["menuItems"] = menuItems;
        await orderRef.update({'orderDetails': orderDetails});

        // Update local state
        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['orderDetails'] = orderDetails;
        }

        isLoading = false;
        notifyListeners();
      } else {
        throw Exception("Menu item not found");
      }
    } catch (e) {
      isLoading = false;
      print("Error removing menu item: $e");
      throw Exception("Failed to remove menu item");
    }
  }

  Future<void> updateOrderTotalPrice(
      String orderId, double newTotalPrice) async {
    try {
      isLoading = true;
      notifyListeners();

      // Reference to the order in Firestore
      final orderDocRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Update the totalPrice field in Firestore
      await orderDocRef.update({'totalPrice': newTotalPrice});

      // update order locally
      final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        orders[orderIndex]['totalPrice'] = newTotalPrice; // Update locally
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error updating order totalPrice: $e");
      throw Exception("Failed to update order totalPrice");
    }
  }

  Future<void> markUserAsPaid(String orderId, String userId) async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Get the existing order details
      final orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;

      // Ensure the user exists in the order details
      final orderDetails =
          orderData['orderDetails'] as Map<String, dynamic>? ?? {};
      if (!orderDetails.containsKey(userId)) {
        throw Exception("User not part of this order");
      }

      // Update the isPaid field for the logged in user
      orderDetails[userId]['isPaid'] = true;

      // Update the Firestore document
      await orderRef.update({'orderDetails': orderDetails});

      // update the local orders list
      final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        orders[orderIndex]['orderDetails'][userId]['isPaid'] = true;
      }

      notifyListeners();
    } catch (e) {
      print("Error marking user as paid: $e");
      throw Exception("Failed to mark user as paid");
    }
  }

  Future<void> checkAndUpdateOrderStatus(String orderId) async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Fetch the order data from Firestore
      final orderDoc = await orderRef.get();
      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;

      final orderDetails =
          orderData['orderDetails'] as Map<String, dynamic>? ?? {};

      // Check if all clients have paid
      final allPaid = orderDetails.values.every((client) {
        return client['isPaid'] == true;
      });

      if (allPaid) {
        // Update the order status to "Paid"
        await orderRef.update({'status': 'Paid'});

        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['status'] = 'Paid';
        }

        notifyListeners(); // Notify the UI of changes
      }
    } catch (e) {
      print("Error updating order status: $e");
      throw Exception("Failed to check and update order status");
    }
  }

  Stream<DocumentSnapshot> listenForOrderStatusChanges(String orderID) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(orderID)
        .snapshots();
  }

  Future<void> updateFirestoreWithShareRequests(
      String orderID, List<Map<String, dynamic>> shareRequests) async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(orderID);

      // Use arrayUnion to add new share requests to the existing array
      await orderRef.update({
        'splitRequests': FieldValue.arrayUnion(shareRequests),
      });

      print("Share requests added to Firestore successfully.");

      // Notify listeners about the change
      notifyListeners();
    } catch (e) {
      print("Error updating Firestore with share requests: $e");
    }
  }

  Future<void> updateOrderSplitMethod(
      String orderId, String splitMethod) async {
    try {
      isLoading = true;
      notifyListeners();

      // Reference to the order in Firestore
      final orderDocRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);

      // Update the totalPrice field in Firestore
      await orderDocRef.update({'splitMethod': splitMethod});

      final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        orders[orderIndex]['splitMethod'] = splitMethod; // Update locally
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error updating order totalPrice: $e");
      throw Exception("Failed to update order totalPrice");
    }
  }

  Stream<List<Map<String, dynamic>>> fetchClientOrders(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      // Print the snapshot data to debug
      // print(
      //     "Snapshot data: ${snapshot.docs.map((doc) => doc.data()).toList()}");

      return snapshot.docs
          .map((doc) {
            var orderData = doc.data() as Map<String, dynamic>;
            var orderDetails =
                orderData['orderDetails'] as Map<String, dynamic>;

            // Print the order data and orderDetails to debug
            // print("Order data: $orderData");
            // print("Order details: $orderDetails");

            String? orderStatus = orderData['status'];

            // Check if orderDetails contains the currentUserId key and if status is "Paid"
            if (orderDetails.containsKey(currentUserId) &&
                orderStatus == 'Paid') {
              return {
                'id': doc.id, // Firestore document ID
                ...orderData,
              };
            }
            return null; // Skip orders that don't match or are not paid
          })
          .whereType<Map<String, dynamic>>() // This filters out null values
          .toList(); // Ensure the result is a List<Map<String, dynamic>> without nulls
    });
  }
}
