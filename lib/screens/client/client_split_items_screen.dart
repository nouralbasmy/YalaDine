import 'package:flutter/material.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientSplitItemsScreen extends StatelessWidget {
  const ClientSplitItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        title: Text("Split by Item"),
      ),
    );
  }
}
