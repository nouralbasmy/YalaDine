import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientHomeDrawer extends StatelessWidget {
  const ClientHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: AppColors.primaryOrange,
            child: Text(
              'Yala Dine',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 30,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(Icons.local_offer),
            title: Text("Offers"),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              print("Offers clicked");
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("Past Orders"),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              print("Past orders clicked");
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle the 'Logout' tab tap here
              Navigator.pop(context); // Close the drawer
              print("Logout clicked");
            },
          ),
        ],
      ),
    );
  }
}
