import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/Components/navigationR.dart';

import 'package:itawseel/pages/Runner/trackorder.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaitingForCustomerPage extends StatefulWidget {
  final String orderId;

  const WaitingForCustomerPage({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<WaitingForCustomerPage> createState() => _WaitingForCustomerPageState();
}

class _WaitingForCustomerPageState extends State<WaitingForCustomerPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _orderStream;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  String? currentRiderId;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();

    // Second stream (example for fetching a user document)
    _userStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email) // Replace with appropriate identifier
        .snapshots();
    _userStream.listen((userSnapshot) {
      setState(() {
        currentRiderId = userSnapshot.data()!['riderId'];
      });
    });
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
                  const Text('Waiting for customer to choose a runner...'),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              );
            } else if (offerStatus == 'riderselected') {
              // Check if this user is the chosen rider
              // Fetch the chosen riderId from Firestore
              FirebaseFirestore.instance
                  .collection('orders')
                  .doc(widget.orderId)
                  .get()
                  .then((doc) {
                final chosenRiderId = doc.data()!['chosenRiderId'];

                // Check if this user is the chosen rider
                if (chosenRiderId == currentRiderId) {
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
                      text: 'Congrats, The customer chose you',
                      showConfirmBtn: true,
                    );
                  });
                } else {
                  // Redirect to homepage if not the chosen rider
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NavigationR(),
                    ),
                  );
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: 'Sorry, the order is already taken',
                    showConfirmBtn: true,
                  );

                  // Replace with your homepage route
                }
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
