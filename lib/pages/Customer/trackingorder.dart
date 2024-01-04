import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/pages/Customer/payment.dart';

import 'package:itawseel/themes/colors.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderId;

  const TrackOrderPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _orderStream;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots();
  }

  Future<String?> getRiderId() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.email;
    final userDoc = _firestore.collection('Users').doc(currentUserUid);
    final riderIdSnapshot = await userDoc.get();
    return riderIdSnapshot.data()!['riderId'];
  }

  Future<String?> getusername() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.email;
    final userDoc = _firestore.collection('Users').doc(currentUserUid);
    final usernameSnapshot = await userDoc.get();
    return usernameSnapshot.data()!['username'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Track Order',
          style: TextStyle(color: white),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.message))],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentDetails(
                  orderID: widget.orderId,
                ),
              ),
            );
          },
          icon: Icon(
            Icons.payment,
            color: white,
          ),
          label: Text(
            'Proceed with payment',
            style: TextStyle(color: white),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching order data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orderData = snapshot.data!.data();
          final chosenRiderId = orderData!['chosenRiderId'] as String;
          final offerStatus = orderData['offerStatus'] as String;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        SizedBox(width: 30),
                        Text(
                          "Tracking Progress",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: primaryColor),
                            child: _buildTimeline(offerStatus)),
                      ),
                    ),
                  ],
                ),
                // Item details
                const Divider(),
                const SizedBox(height: 20),
                // Bottom section with chat button
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(String offerStatus) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Unordered list for a visual timeline
        ListView(
          shrinkWrap: true, // Use a dot as the timeline marker
          children: [
            // Rider selected
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: offerStatus == 'riderselected'
                    ? Card(
                        color: white,
                        child: ListTile(
                            leading: Icon(Icons.fastfood, color: primaryColor),
                            title: Text('Rider Selected',
                                style: TextStyle(color: primaryColor)),
                            trailing:
                                const Icon(Icons.circle, color: Colors.green)),
                      )
                    : const ListTile(
                        leading: Icon(
                          Icons.fastfood,
                          color: Colors.white54,
                        ),
                        title: Text('Rider',
                            style: TextStyle(color: Colors.white54)),
                        trailing: SizedBox(),
                      ),
              ),
            ),

            // Buying food
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: offerStatus == 'buyingFood'
                    ? Card(
                        color: white,
                        child: ListTile(
                            leading: Icon(Icons.fastfood, color: primaryColor),
                            title: Text('Buying Food',
                                style: TextStyle(color: primaryColor)),
                            trailing:
                                const Icon(Icons.circle, color: Colors.green)),
                      )
                    : const ListTile(
                        leading: Icon(
                          Icons.fastfood,
                          color: Colors.white54,
                        ),
                        title: Text('Buying Food',
                            style: TextStyle(color: Colors.white54)),
                        trailing: SizedBox(),
                      ),
              ),
            ),

            // On the way
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: offerStatus == 'onTheWay'
                    ? Card(
                        color: white,
                        child: ListTile(
                            leading: Icon(Icons.delivery_dining,
                                color: primaryColor),
                            title: Text('On The Way',
                                style: TextStyle(color: primaryColor)),
                            trailing:
                                const Icon(Icons.circle, color: Colors.green)),
                      )
                    : const ListTile(
                        leading: Icon(
                          Icons.delivery_dining_outlined,
                          color: Colors.white54,
                        ),
                        title: Text('On The Way',
                            style: TextStyle(color: Colors.white54)),
                        trailing: SizedBox(),
                      ),
              ),
            ),

            // Completed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: offerStatus == 'arrived'
                    ? Card(
                        color: white,
                        child: ListTile(
                            leading: Icon(Icons.check, color: primaryColor),
                            title: Text('Arrived',
                                style: TextStyle(color: primaryColor)),
                            trailing:
                                const Icon(Icons.circle, color: Colors.green)),
                      )
                    : const ListTile(
                        leading: Icon(
                          Icons.check,
                          color: Colors.white54,
                        ),
                        title: Text('Arrived',
                            style: TextStyle(color: Colors.white54)),
                        trailing: SizedBox(),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _startChat(String riderId) {
    // Initiate chat with the rider
    // ... (Implement using your chat library's functionalities)
  }
}
