import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/providers/restaurant_provider.dart';
import 'package:yala_dine/utils/app_colors.dart';
import 'package:yala_dine/widgets/admin_orders_list.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _orderTabs = [
    "Active",
    "Completed",
  ];
  String selectedTab = "Active";

  List<Map<String, dynamic>> filteredOrders = [];
  // Filter dropdown value for Active tab
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _orderTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Filter orders based on the selected tab (Active/Completed)
  List<Map<String, dynamic>> getTabOrders(
      List<Map<String, dynamic>> orders, String selectedTab) {
    if (selectedTab == 'Active') {
      return orders
          .where((order) =>
              ['New', 'In Progress', 'Served'].contains(order['status']))
          .toList();
    } else if (selectedTab == 'Completed') {
      return orders
          .where((order) => ['Paid', 'Cancelled'].contains(order['status']))
          .toList();
    }
    return orders;
  }

  List<Map<String, dynamic>> getActiveTabFilteredOrders(
      List<Map<String, dynamic>> orders, String selectedStatusFilter) {
    List<Map<String, dynamic>> activeOrders = getTabOrders(orders, "Active");
    return activeOrders
        .where((order) => (selectedStatusFilter == 'All' ||
            order['status'] == _selectedStatusFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    if (restaurantProvider.restaurantId != null &&
        orderProvider.orders.isEmpty &&
        !orderProvider.isOrdersEmpty) {
      orderProvider.fetchOrders(restaurantProvider.restaurantId!);
    }
    // Check if orders are loading
    if (orderProvider.isLoading && !orderProvider.isOrdersEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.isOrdersEmpty) {
      return const Center(child: Text("No orders available."));
    }

    // filteredOrders = getTabOrders(orderProvider.orders, selectedTab);

    return Column(
      children: [
        // TabBar for switching between Active and Completed orders
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
            onTap: (index) {
              setState(() {
                selectedTab = index == 0 ? 'Active' : 'Completed';
              });
            },
          ),
        ),
        if (selectedTab == "Active")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            alignment: Alignment.topLeft,
            child: DropdownButton<String>(
              alignment: Alignment.center,
              value: _selectedStatusFilter,
              onChanged: (newValue) {
                setState(() {
                  _selectedStatusFilter = newValue!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'New', child: Text('New')),
                DropdownMenuItem(
                    value: 'In Progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'Served', child: Text('Served')),
              ],
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Active Orders Tab
              AdminOrdersList(
                  orders: getActiveTabFilteredOrders(
                      orderProvider.orders, _selectedStatusFilter)),
              // Completed Orders Tab
              AdminOrdersList(
                  orders: getTabOrders(orderProvider.orders, "Completed")),
            ],
          ),
        ),
      ],
    );
  }
}
