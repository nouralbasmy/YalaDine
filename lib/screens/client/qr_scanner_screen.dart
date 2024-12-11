import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import the mobile_scanner package
import 'package:provider/provider.dart';
import 'package:yala_dine/providers/order_provider.dart';
import 'package:yala_dine/screens/client/client_menu_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  String? _scanResult;
  final MobileScannerController _controller =
      MobileScannerController(); // Camera controller

  // Function to handle QR scan result
  void _onScan(BarcodeCapture barcodeCapture) {
    if (barcodeCapture.barcodes.isNotEmpty) {
      final barcode = barcodeCapture.barcodes.first;

      final result = barcode.rawValue;
      setState(() {
        _scanResult = result; // Store the scan result
      });

      if (_scanResult != null && _scanResult!.isNotEmpty) {
        final orderId = _scanResult!;

        User? user = FirebaseAuth.instance.currentUser;
        final clientId = user!.uid;

        // Fetch the order by order ID
        Provider.of<OrderProvider>(context, listen: false)
            .fetchOrderByOrderId(orderId)
            .then((order) {
          if (order != null && order.isNotEmpty) {
            String restaurantId = order['restaurantId'];

            Provider.of<OrderProvider>(context, listen: false)
                .addUserToOrder(orderId, clientId)
                .then((_) {
              // Stop the camera before navigating
              _controller.dispose();
              print("Navigated");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClientMenuScreen(restaurantId: restaurantId),
                ),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Failed to update order: $error"),
                ),
              );
            });
          } else {
            // Show a message if the order is not found
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid order ID. Please try again."),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _controller, // Attach the controller
                    onDetect: (BarcodeCapture barcodeCapture) {
                      for (var barcode in barcodeCapture.barcodes) {
                        print(
                            'Detected barcode: ${barcode.rawValue}, Format: ${barcode.format}');

                        _onScan(barcodeCapture);
                      }
                    },
                    fit: BoxFit.cover,
                    errorBuilder: (context, exception, stackTrace) {
                      return Center(child: Text('Error: $exception'));
                    },
                  ),
                  // Adding a square overlay for scanning focus
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250, // Square width
                      height: 250, // Square height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 4.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when widget is disposed
    super.dispose();
  }
}
