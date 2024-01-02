import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/pages/Runner/homepageR.dart';
import 'package:itawseel/pages/Runner/trackorder.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
              // ignore: prefer_const_constructors
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text('Waiting for customer to choose a runner...'),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ],
              );
            } else if (offerStatus == 'riderSelected') {
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
                QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: 'Congrats, The customer choose you',
                    showConfirmBtn: true);
              });
            } else {
              // Handle other offer statuses if needed
              Future.delayed(Duration.zero, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomepageR(),
                  ),
                );
                QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: 'Sorry, the order is already taken',
                    showConfirmBtn: true);
              });
            }

            return const SizedBox(); // Should never reach here
          },
        ),
      ),
    );
  }
}
