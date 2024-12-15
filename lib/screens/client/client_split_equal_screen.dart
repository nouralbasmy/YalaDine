import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/client/client_post_payment_rate_screen.dart';
import 'package:yala_dine/utils/app_colors.dart';

class ClientSplitEqualScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String orderID;
  const ClientSplitEqualScreen(
      {super.key, required this.order, required this.orderID});

  @override
  State<ClientSplitEqualScreen> createState() => _ClientSplitEqualScreenState();
}

class _ClientSplitEqualScreenState extends State<ClientSplitEqualScreen> {
  // Text controllers for the card form
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Error messages for validation
  String? _cardNumberError;
  String? _cardHolderError;
  String? _expiryDateError;
  String? _cvvError;

  void _validateAndPay(double totalPrice) {
    setState(() {
      // Reset all error messages
      _cardNumberError = null;
      _cardHolderError = null;
      _expiryDateError = null;
      _cvvError = null;

      // Validate fields and set error messages
      if (_cardNumberController.text.isEmpty) {
        _cardNumberError = "Card number is required";
      }
      if (_cardHolderController.text.isEmpty) {
        _cardHolderError = "Cardholder name is required";
      }
      if (_expiryDateController.text.isEmpty) {
        _expiryDateError = "Expiry date is required";
      }
      if (_cvvController.text.isEmpty) {
        _cvvError = "CVV is required";
      }

      // If no errors, payment success
      if (_cardNumberError == null &&
          _cardHolderError == null &&
          _expiryDateError == null &&
          _cvvError == null) {
        // Payment successful
        OrderProvider orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        User? user = FirebaseAuth.instance.currentUser;
        final clientId = user!.uid;
        orderProvider.updateOrderTotalPrice(widget.orderID, totalPrice);
        orderProvider.markUserAsPaid(widget.orderID, clientId);
        orderProvider.checkAndUpdateOrderStatus(
            widget.orderID); //do as first thing in next page
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ClientPostPaymentRateScreen(
                    order: widget.order,
                    orderID: widget.orderID,
                  )),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Payment Successful!")),
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalGuests = 0;
    double totalPrice = 0;

    //print(widget.orderID);

    bool hasOrderDetails = widget.order['orderDetails'] != null &&
        widget.order['orderDetails'].isNotEmpty;

    // If there are order details, calculate the totalGuests
    if (hasOrderDetails) {
      widget.order['orderDetails'].forEach((_, userOrder) {
        totalGuests += 1;
        userOrder['menuItems'].forEach((item) {
          totalPrice +=
              item['price'] * item['quantity']; // Add item total to totalPrice
        });
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text("Split Equally"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Price Section
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/bill_payment.png',
                    height: 150.0,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Price: EGP $totalPrice",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Number of guests: $totalGuests",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Your Share: EGP ${totalPrice / totalGuests}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Card Info Section
            const Text(
              "Card Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Card Number Input
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Card number",
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _cardNumberError,
              ),
            ),
            const SizedBox(height: 16),

            // Cardholder Name Input
            TextField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: "Cardholder name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _cardHolderError,
              ),
            ),
            const SizedBox(height: 16),

            // Row with Expiry Date and CVV
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: "Expiry date",
                      prefixIcon: const Icon(Icons.date_range),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: _expiryDateError,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "CVV",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: _cvvError,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _validateAndPay(totalPrice);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  "Pay",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
