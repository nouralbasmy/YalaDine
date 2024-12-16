import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/offer_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientOffersScreen extends StatefulWidget {
  const ClientOffersScreen({super.key});

  @override
  State<ClientOffersScreen> createState() => _ClientOffersScreenState();
}

class _ClientOffersScreenState extends State<ClientOffersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        title: const Text("Offers"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Provider.of<OfferProvider>(context, listen: false)
            .streamActiveOffers(), // Real-time stream of active offers
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No active offers available."));
          }

          final offers = snapshot.data!;
          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      offer['logoUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    offer['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['restaurantName'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(offer['description']),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
