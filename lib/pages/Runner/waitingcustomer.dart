import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/pages/Runner/trackorder.dart';
import 'package:itawseel/themes/colors.dart';

class WaitingForCustomerPage extends StatefulWidget {
  final String orderId;

  const WaitingForCustomerPage({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<WaitingForCustomerPage> createState() => _WaitingForCustomerPageState();
}

class _WaitingForCustomerPageState extends State<WaitingForCustomerPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _orderStream;

  @override
  void initState() {
    super.initState();
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Waiting for Customer',
          style: TextStyle(color: white),
        ),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _orderStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching order status'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final orderData = snapshot.data!.data();
            final offerStatus = orderData?['offerStatus'] as String;

            if (offerStatus == 'pending') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Waiting for customer to choose a runner...'),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              );
            } else if (offerStatus == 'riderSelected') {
              final chosenRiderId = orderData!['chosenRiderId'] as String;

              // Check if this user is the chosen rider

              Future.delayed(Duration.zero, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackOrderRunnerPage(
                      orderId: widget.orderId,
                    ),
                  ),
                );
              });
            } else {
              // Handle other offer statuses if needed
              return const Center(
                  child: Text('Sorry This order has been taken'));
            }

            return const SizedBox(); // Should never reach here
          },
        ),
      ),
    );
  }
}
