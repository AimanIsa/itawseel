import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:itawseel/pages/Runner/trackorder.dart';
import 'package:itawseel/pages/Runner/waitingcustomer.dart';
import 'package:itawseel/themes/colors.dart';

class HistoryR extends StatefulWidget {
  HistoryR({super.key});

  @override
  State<HistoryR> createState() => _HistoryRState();
}

class _HistoryRState extends State<HistoryR> {
  final user = FirebaseAuth.instance.currentUser!;
  String? riderId; // Store the retrieved riderId
  String? username;
  @override
  void initState() {
    super.initState();
    getRiderIdFromUsersCollection();
  }

  Future<void> getRiderIdFromUsersCollection() async {
    try {
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email) // Assuming riderId is stored under the user's UID
          .get();
      riderId = userDocSnapshot.get('username');
      print(riderId);
      setState(() {}); // Update the UI to reflect the fetched riderId
    } catch (error) {
      print('Error fetching riderId from Users collection: $error');
      // Handle the error appropriately, e.g., show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('offerStatus', whereIn: [
              'riderselected',
              'buyingFood',
              'onTheWay',
              'pending',
              'arrived'
            ])
            .where('Runnerusername', isEqualTo: riderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching orders: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              print(username);
              return Center(child: Text('No orders found'));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                print(order.id);

                return OrderCard(
                    orderId: order.id, offerstatus: order['offerStatus']);
              },
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String offerstatus;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.offerstatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        shadowColor: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: $orderId',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Status: $offerstatus',
                    style: TextStyle(
                      fontSize: 14,
                      color: offerstatus == 'onTheWay'
                          ? Colors.green
                          : Color.fromARGB(188, 10, 8, 8),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (offerstatus == 'completed') SizedBox(),
                  if (offerstatus == 'pending')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WaitingForCustomerPage(
                              orderId: orderId,
                            ),
                          ),
                        );
                      },
                      child: Text('Waiting...'),
                    ),
                  if (offerstatus == 'riderselected' ||
                      offerstatus == 'buyingFood' ||
                      offerstatus == 'onTheWay' ||
                      offerstatus == 'arrived')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackOrderRunnerPage(
                              orderId: orderId,
                            ),
                          ),
                        );
                      },
                      child: Text('Track Order'),
                    ),
                  SizedBox(width: 10),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
