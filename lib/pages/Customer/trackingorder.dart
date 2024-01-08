import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/Components/navigation.dart';
import 'package:itawseel/pages/Customer/chatscreen.dart';
import 'package:itawseel/pages/Customer/homepagec.dart';
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

  Future<String?> getEmailByRiderId(String riderId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .where('riderId', isEqualTo: riderId)
          .limit(1) // Retrieve only one document, as riderId should be unique
          .get();

      if (userDoc.docs.isNotEmpty) {
        final user = userDoc.docs.first.data();
        return user['email'] as String?;
      } else {
        return null; // Rider ID not found
      }
    } catch (error) {
      // Handle potential errors, such as network issues or invalid riderId
      print('Error retrieving email by riderId: $error');
      return null;
    }
  }

  Future<String?> getChosenRiderId(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (orderDoc.exists) {
        final data = orderDoc.data();
        return data?['chosenRiderId'] as String?;
      } else {
        return null; // Order document not found
      }
    } catch (error) {
      // Handle potential errors, such as network issues or invalid orderId
      print('Error retrieving chosenRiderId: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Navigation(),
                    ),
                  );
                },
                icon: Icon(Icons.home)),
            Text(
              'Track Order',
              style: TextStyle(color: white),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () async {
                final riderId = await getChosenRiderId(widget
                    .orderId); // Assuming this function retrieves the rider ID

                final rideremail = await getEmailByRiderId(riderId!);
                if (rideremail != null) {
                  _startChat(
                      rideremail); // Pass the retrieved email to startChat
                } else {
                  // Handle the case where email is not found
                  print('Error: Rider email not found.');
                  // Consider displaying an error message to the user
                }
              },
              icon: Icon(Icons.message))
        ],
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

  void _startChat(String rideremail) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.email!;

    // Create chat ID using the same logic as the ChatListPage
    final chatId = getChatId(currentUserId, rideremail);
    print(currentUserId);
    print(rideremail);
    print(chatId);

    // Check for existing chat document
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Create a new chat document
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUserId, rideremail]
      });
    }

    // Navigate to ChatScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          recipientId: rideremail,
        ),
      ),
    );
  }

  String getChatId(String user1, String user2) {
    if (user1.compareTo(user2) < 0) {
      return '$user1-$user2';
    } else {
      return '$user2-$user1';
    }
  }
}
