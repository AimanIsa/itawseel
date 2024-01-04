import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/pages/Runner/Ordercard.dart';
import 'package:itawseel/pages/Runner/waitingcustomer.dart';
import 'package:itawseel/themes/colors.dart';

class HomepageR extends StatefulWidget {
  const HomepageR({Key? key}) : super(key: key);

  @override
  State<HomepageR> createState() => _HomepageRState();
}

class _HomepageRState extends State<HomepageR> {
  final _firestore = FirebaseFirestore.instance;
  final currentUserUid = FirebaseAuth.instance.currentUser!.email;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream;

  get riderId => getRiderId();

  @override
  void initState() {
    super.initState();
    _ordersStream = _firestore.collection('orders').snapshots();
  }

  void _updateOfferedChargeFees(String orderId, double newChargeFees) async {
    setState(() {});

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'offeredChargeFees': newChargeFees,
      });
    } catch (error) {
      // Handle errors as before
    }
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

  Future<String?> getimageurl() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.email;
    final userDoc = _firestore.collection('Users').doc(currentUserUid);
    final imageSnapshot = await userDoc.get();
    return imageSnapshot.data()!['imageUrl'];
  }

  Future<String?> getgender() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.email;
    final userDoc = _firestore.collection('Users').doc(currentUserUid);
    final imageSnapshot = await userDoc.get();
    return imageSnapshot.data()!['gender'];
  }

  void _offerChargeFees(String orderId, double newChargeFees) async {
    print('orderId: $orderId');
    print('orderId: $newChargeFees');

    try {
      // Fetch riderId from the user document
      final username = await getusername();
      final imageUrl = await getimageurl();
      final gender = await getgender();
      final riderId = await getRiderId();
      if (riderId != null) {
        // Proceed with offer submission only if riderId is available
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
          'offered': FieldValue.arrayUnion([
            {
              'riderId': riderId,
              'username': username,
              'imageUrl': imageUrl,
              'gender': gender,
              'offeredChargeFees': newChargeFees,
              //'timestamp': FieldValue.serverTimestamp(),
            }
          ])
        });
        setState(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WaitingForCustomerPage(orderId: orderId)));
        });
        print('Offer submitted successfully!');
      } else {
        print(
            'riderId not found in user document.'); // Handle the case where riderId is missing
      }

      // Indicate success
    } catch (error) {
      print('Error submitting offer: $error');

      print('riderId: $riderId'); // Print riderId after fetching it
      // Print orderId before updating the order document
// Log detailed error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Available Orders',
          style: TextStyle(color: white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching orders'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderData = snapshot.data!.docs[index].data();
              if (orderData['offerStatus'] == 'pending') {
                return OrderCard(
                  orderData: orderData,
                  offeredChargeFees:
                      (orderData['offeredChargeFees'] as num?)?.toDouble() ??
                          0.0,
                  onUpdateOfferedChargeFees: _updateOfferedChargeFees,
                  onOfferChargeFees: _offerChargeFees,
                );
              } else {
                return const SizedBox();
              }
            },
          );
        },
      ),
    );
  }
}
