class Order {
  final String orderId;
  final List<Map<String, dynamic>> orderDetails; // List of orders for each user
  final String status;
  final double totalPrice;

  Order({
    required this.orderId,
    required this.orderDetails,
    required this.status,
    required this.totalPrice,
  });
}
