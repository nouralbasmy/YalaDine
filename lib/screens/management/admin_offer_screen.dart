import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class AdminOfferScreen extends StatefulWidget {
  @override
  _AdminOfferScreenState createState() => _AdminOfferScreenState();
}

class _AdminOfferScreenState extends State<AdminOfferScreen> {
  List<Map<String, dynamic>> offers = [
    {
      'id': 1,
      'title': '10% Off All Orders',
      'description': 'Get 10% off on orders above \$30',
      'isActive': true
    },
    {
      'id': 2,
      'title': 'Free Dessert with Any Meal',
      'description': 'Free dessert with any main course order',
      'isActive': false
    },
    {
      'id': 3,
      'title': '15% Off Beverages',
      'description': 'Get 15% off on all beverages',
      'isActive': true
    },
  ];

  String selectedFilter = 'All';

  // To hold the deleted offer for Undo
  Map<String, dynamic>? lastDeletedOffer;
  int? lastDeletedIndex;

  // Delete an offer with Undo option
  void deleteOffer(int index) {
    setState(() {
      lastDeletedOffer = offers[index]; // Store deleted offer for Undo
      lastDeletedIndex = index; // Store the index for Undo
      offers.removeAt(index);
    });

    // Show snackbar with Undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offer deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            undoDelete(); // Undo the deletion
          },
        ),
      ),
    );
  }

  // Undo the deletion
  void undoDelete() {
    if (lastDeletedOffer != null && lastDeletedIndex != null) {
      setState(() {
        offers.insert(
            lastDeletedIndex!, lastDeletedOffer!); // Re-insert the offer
      });
    }
  }

  List<Map<String, dynamic>> getFilteredOffers() {
    if (selectedFilter == 'Active') {
      return offers.where((offer) => offer['isActive']).toList();
    } else if (selectedFilter == 'Inactive') {
      return offers.where((offer) => !offer['isActive']).toList();
    }
    return offers; // Return all if "All" is selected
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: 8),
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
          SizedBox(height: 8),

          // List of offers
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredOffers().length,
              itemBuilder: (context, index) {
                final offer = getFilteredOffers()[index];
                return Dismissible(
                  key: Key(offer['id'].toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    deleteOffer(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(offer['title']),
                      subtitle: Text(offer['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: offer['isActive'],
                            onChanged: (value) {
                              setState(() {
                                offer['isActive'] = value;
                              });
                            },
                            activeColor: AppColors.lightTeal,
                            inactiveThumbColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
