import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/pages/Customer/chooserunner.dart';
import 'package:itawseel/pages/Customer/payment.dart';
import 'package:itawseel/pages/Customer/trackingorder.dart';
import 'package:itawseel/themes/colors.dart';

class HistoryC extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
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
            .where('currentemail', isEqualTo: user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching orders: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              return Center(child: Text('No orders found'));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                      orderId: order.id, offerstatus: order['offerStatus']);
                },
              ),
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
        elevation: 12,
        shadowColor: const Color.fromARGB(103, 0, 0, 0),
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
                            builder: (context) => ChooseRunnerPage(
                              orderId: orderId,
                            ),
                          ),
                        );
                      },
                      child: Text('Choose Runner'),
                    ),
                  if (offerstatus == 'riderselected' ||
                      offerstatus == 'buyingFood' ||
                      offerstatus == 'onTheWay' ||
                      offerstatus == 'arrived')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackOrderPage(
                              orderId: orderId,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Track Order',
                        style: TextStyle(color: white),
                      ),
                    ),
                  SizedBox(width: 10),
                  if (offerstatus == 'arrived')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentDetails(
                              orderID: orderId,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Pay',
                        style: TextStyle(color: white),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
