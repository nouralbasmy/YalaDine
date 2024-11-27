import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/offer_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class AdminOfferScreen extends StatefulWidget {
  @override
  _AdminOfferScreenState createState() => _AdminOfferScreenState();
}

class _AdminOfferScreenState extends State<AdminOfferScreen> {
  String selectedFilter = 'All';

  // Delete an offer
  void deleteOffer(int index) async {
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    // Store the deleted offer and its index for Undo
    final offerToDelete = offerProvider.offers[index];

    try {
      // Remove the offer from the list
      await offerProvider.deleteOffer(
          restaurantProvider.restaurantId!, offerToDelete['id']);

      // Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer deleted'),
        ),
      );
    } catch (e) {
      // Handle error (e.g., show a Snackbar if deletion fails)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete offer: $e")),
      );
    }
  }

  Future<void> updateStatus(Map<String, dynamic> offer, bool value) async {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    try {
      await offerProvider.updateOfferStatus(
          restaurantProvider.restaurantId!, offer['id'], value);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update offer status: $e")),
      );
    }
  }

  List<Map<String, dynamic>> getFilteredOffers(
      List<Map<String, dynamic>> offers) {
    if (selectedFilter == 'Active') {
      return offers.where((offer) => offer['isActive']).toList();
    } else if (selectedFilter == 'Inactive') {
      return offers.where((offer) => !offer['isActive']).toList();
    }
    return offers; // Return all if "All" is selected
  }

  @override
  void initState() {
    super.initState();
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final offerProvider = Provider.of<OfferProvider>(context, listen: false);
    if (restaurantProvider.restaurantId != null) {
      offerProvider.fetchOffers(restaurantProvider.restaurantId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerProvider = Provider.of<OfferProvider>(context);

    if (offerProvider.isLoading && !offerProvider.isOffersEmpty) {
      return Center(child: Text("Loading..."));
    }
    if (offerProvider.isOffersEmpty) {
      return Center(child: Text("No offers available."));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: ['All', 'Active', 'Inactive'].map((filter) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: selectedFilter == filter
                        ? AppColors.secondaryOrange
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Text(filter),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // List of offers
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredOffers(offerProvider.offers).length,
              itemBuilder: (context, index) {
                final offer = getFilteredOffers(offerProvider.offers)[index];
                return Dismissible(
                    key: Key(offer['id'].toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      deleteOffer(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(offer['title']),
                        isThreeLine: true,
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer['description']),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Discount: ${offer['discount'] * 100}%',
                                    style:
                                        TextStyle(fontSize: 12), // smaller font
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Min Order: \EGP ${offer['minOrderTotal']}',
                                    style:
                                        TextStyle(fontSize: 12), // smaller font
                                  ),
                                ],
                              ),
                            ]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: offer['isActive'],
                              onChanged: (value) async {
                                await updateStatus(offer, value);
                              },
                              activeColor: AppColors.lightTeal,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
