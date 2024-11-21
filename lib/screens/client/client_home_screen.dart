import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  String? name = "";

  @override
  void initState() {
    super.initState();
    _getClientName();
  }

  void _getClientName() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the logged-in user
    if (user != null) {
      // Retrieve the user's name from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        name = userDoc['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Home Page'),
      ),
      body: Center(
        child: name == null
            ? const CircularProgressIndicator() // Show a loading indicator while the name is being fetched
            : Text('Welcome, $name!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
