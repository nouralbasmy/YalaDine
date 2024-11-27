import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/order_tile.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen>
    with SingleTickerProviderStateMixin {
  // Tab controller for switching between "Active" and "Completed"
  late TabController _tabController;

  // Orders data
  List<Map<String, dynamic>> orders = [
    {
      'orderId': '001',
      'tableNumber': '1',
      'numberOfGuests': 4,
      'status': 'New',
      'createdAt': DateTime.now().subtract(Duration(minutes: 10)),
    },
    {
      'orderId': '002',
      'tableNumber': '2',
      'numberOfGuests': 2,
      'status': 'Serving',
      'createdAt': DateTime.now().subtract(Duration(minutes: 20)),
    },
    {
      'orderId': '003',
      'tableNumber': '3',
      'numberOfGuests': 3,
      'status': 'Pending Payment',
      'createdAt': DateTime.now().subtract(Duration(minutes: 30)),
    },
    {
      'orderId': '004',
      'tableNumber': '4',
      'numberOfGuests': 5,
      'status': 'Paid',
      'createdAt': DateTime.now().subtract(Duration(minutes: 40)),
    },
    {
      'orderId': '005',
      'tableNumber': '10',
      'numberOfGuests': 3,
      'status': 'Preparing',
      'createdAt': DateTime.now().subtract(Duration(minutes: 40)),
    },
  ];

  // Filtered orders based on status
  List<Map<String, dynamic>> filteredOrders = [];

  // Selected filter status for active orders
  String? selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Two tabs: Active and Completed
    filteredOrders = orders
        .where((order) => ['New', 'Preparing', 'Serving', 'Pending Payment']
            .contains(order['status']))
        .toList();
  }

  // Filter Active orders based on status
  void filterOrders(String? status) {
    setState(() {
      selectedStatus = status;
      if (status == null || status.isEmpty || status == 'All') {
        // If no status selected, show all orders in the Active group
        filteredOrders = orders
            .where((order) => ['New', 'Preparing', 'Serving', 'Pending Payment']
                .contains(order['status']))
            .toList();
      } else {
        // Filter orders by selected status in the Active group
        filteredOrders = orders
            .where((order) =>
                ['New', 'Preparing', 'Serving', 'Pending Payment']
                    .contains(order['status']) &&
                order['status'] == status)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    // Loading state
    if (restaurantProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // No restaurant data
    if (restaurantProvider.restaurantId == null) {
      return const Center(
        child: Text(
          'No restaurant found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // TabBar for switching between Active and Completed
        Container(
          padding: const EdgeInsets.all(10),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
            labelColor: AppColors.primaryOrange,
            indicatorColor: AppColors.primaryOrange,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Active Orders Tab
              Column(
                children: [
                  // Status Filter for Active Orders
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      onChanged: (String? newStatus) {
                        filterOrders(newStatus);
                      },
                      items: <String>[
                        'All',
                        'New',
                        'Preparing',
                        'Serving',
                        'Pending Payment'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),

                  // Display filtered active orders
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderTile(
                          orderId: order['orderId'],
                          tableNumber: order['tableNumber'],
                          numberOfGuests: order['numberOfGuests'],
                          createdAt:
                              "${order['createdAt'].hour}:${order['createdAt'].minute} AM",
                          status: order['status'],
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Completed Orders Tab
              Column(
                children: [
                  // Display completed orders (Paid and Completed)
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders
                          .where((order) =>
                              ['Paid', 'Completed'].contains(order['status']))
                          .toList()
                          .length,
                      itemBuilder: (context, index) {
                        final order = orders
                            .where((order) =>
                                ['Paid', 'Completed'].contains(order['status']))
                            .toList()[index];
                        return OrderTile(
                          orderId: order['orderId'],
                          tableNumber: order['tableNumber'],
                          numberOfGuests: order['numberOfGuests'],
                          createdAt:
                              "${order['createdAt'].hour}:${order['createdAt'].minute} AM",
                          status: order['status'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
