import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfferProvider with ChangeNotifier {
  List<Map<String, dynamic>> offers = [];
  bool isLoading = true;
  bool isOffersEmpty = false;
  // Fetch offers from the sub-collection
  Future<void> fetchOffers(String restaurantId) async {
    try {
      //print("Here in offer provider");
      isLoading = true;
      final offersCollection = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('offers');

      final snapshot = await offersCollection.get();

      if (snapshot.docs.isEmpty) {
        isLoading = false;
        isOffersEmpty = true;
        //print("Here in offer provider found empty");
        notifyListeners();
        return;
      }

      isOffersEmpty = false;
      // Map each document to a local list
      offers = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Use the Firestore document ID
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error fetching offers: $e");
      throw Exception("Failed to fetch offers");
    }
  }

  Future<void> addOffer(
      String restaurantId, Map<String, dynamic> newOffer) async {
    try {
      isLoading = true;
      notifyListeners();

      final offersCollection = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('offers');

      // Add new offer to Firestore
      final docRef = await offersCollection.add(newOffer);

      // Add new offer to local list
      offers.add({
        'id': docRef.id, // The generated Firestore doc ID
        ...newOffer,
      });

      isOffersEmpty = false; // Since new offer added
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print("Error adding offer: $e");
      throw Exception("Failed to add offer");
    }
  }

  Future<void> updateOfferStatus(
      String restaurantId, String offerId, bool isActive) async {
    try {
      final offerDoc = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('offers')
          .doc(offerId);

      await offerDoc.update({'isActive': isActive});

      // Update locally
      final offerIndex = offers.indexWhere((offer) => offer['id'] == offerId);
      if (offerIndex != -1) {
        offers[offerIndex]['isActive'] = isActive;
      }

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to update offer status: $e");
    }
  }

  Future<void> deleteOffer(String restaurantId, String offerId) async {
    try {
      // delete offer from Firestore
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('offers')
          .doc(offerId)
          .delete();

      // remove the offer from local list
      offers.removeWhere((offer) => offer['id'] == offerId);

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete offer: $e');
    }
  }
}
