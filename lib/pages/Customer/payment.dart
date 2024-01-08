import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/navigation.dart';
import 'package:itawseel/pages/Customer/RateRunner.dart';
import 'package:itawseel/themes/colors.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key, required this.orderID});

  final String orderID; // Store the orderID

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _orderStream;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderID)
        .snapshots();
  }

  String _selectedPaymentMethod = 'Cash'; // Initial value
  final CollectionReference _ordersCollection =
      FirebaseFirestore.instance.collection('orders');

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
              "Payment Method",
              style: TextStyle(color: white),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RunnerRatingPage(
                  choosenRunnerId: getChosenRiderId(widget.orderID),
                  orderId: widget.orderID,
                ),
              ),
            );
          },
          icon: Icon(
            Icons.star,
            color: white,
          ),
          label: Text(
            'Rate Runner',
            style: TextStyle(color: white),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "Select Your Payment Method",
                        style: TextStyle(color: white, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      PopupMenuButton<String>(
                        initialValue: _selectedPaymentMethod,
                        onSelected: (newValue) {
                          setState(() {
                            _selectedPaymentMethod = newValue;
                          });
                        },
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'Cash',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cash'),
                                Icon(Icons
                                    .money), // Optional icon for visual representation
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'QrCode',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('QR Code'),
                                Icon(Icons
                                    .qr_code), // Optional icon for visual representation
                              ],
                            ),
                          ),
                        ],
                        child: Text(
                          _selectedPaymentMethod ??
                              'Select Payment Method', // Display selected item or placeholder
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _orderStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching order data'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final orderData = snapshot.data!.data();
                    final chosenRiderId = orderData!['chosenRiderId'] as String;
                    final offerStatus = orderData['offerStatus'] as String;

                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            SizedBox(width: 20),
                            Text(
                              'Details',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            title: const Text(
                              'Charge Fees: ',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              'RM ${orderData['offeredChargeFees'].toString()}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            title: const Text(
                              'Location: ',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              orderData['location'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListTile(
                            visualDensity: const VisualDensity(
                                horizontal: 0, vertical: -4),
                            title: const Text(
                              'Runner Name: ',
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              orderData['Runnerusername'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        const Row(
                          children: [
                            SizedBox(width: 20),
                            Text(
                              "Food Items",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: orderData['fooditem'].length,
                              itemBuilder: (context, index) {
                                final item = orderData['fooditem'][index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Text(item['name'],
                                            style:
                                                const TextStyle(fontSize: 15)),
                                        const SizedBox(width: 30),
                                        Text(
                                          ' x ${item['quantity'].toString()} ',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),

                                    trailing: Text(
                                      'RM ${item['price']}',
                                      style: const TextStyle(fontSize: 15),
                                    ), // Adjust currency formatting
                                  ),
                                );
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ListTile(
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                title: const Text(
                                  'Total Item Price : ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  // Calculate the total price directly
                                  'RM ${(orderData['totalPrice'] as num)}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: ListTile(
                                visualDensity: const VisualDensity(
                                    horizontal: 0, vertical: -4),
                                title: const Text(
                                  'Total Items Price + Fees : ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  // Calculate the total price directly
                                  'RM ${(orderData['totalPrice'] as num) + orderData['offeredChargeFees']}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Chosen rider and total price
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveOrder() async {
    await _ordersCollection.add({
      'payment': _selectedPaymentMethod,

      // Add other order details here
    });

    print(_selectedPaymentMethod);
  }
}
