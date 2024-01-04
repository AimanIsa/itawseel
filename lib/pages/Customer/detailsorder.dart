import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mybutton.dart';
import 'package:itawseel/pages/Customer/chooserunner.dart';
import 'package:itawseel/themes/colors.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails(
      {super.key, required this.orderID}); // Add orderID as a parameter

  final String orderID; // Store the orderID

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String _selectedLocation = 'Location'; // Initialize with a default
  // Example locations
  final TextEditingController _locationController = TextEditingController();
  bool existlocation = false;

  Future<void> _updateOrderLocation() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderID) // Access the specific order document
          .update({'location': _selectedLocation, 'offerStatus': 'pending'});
    } catch (error) {
      // Handle errors gracefully
      print('Error updating location: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update location. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderID) // Access the orderID from the widget
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Order Details',
                style: TextStyle(color: white),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 3,
                      color: white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 30),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Details ',
                                      style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Order ID: ${orderData['orderId']}',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    Text(
                                      'Your Location: ${orderData['location']}',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                const Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Items:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      (orderData['fooditem'] as List<dynamic>?)
                                              ?.length ??
                                          0, // Ensure length is available
                                  itemBuilder: (context, index) {
                                    final foodItems =
                                        orderData['fooditem'] as List<dynamic>?;
                                    if (foodItems != null &&
                                        index < foodItems.length) {
                                      final item = foodItems[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              Text(item['name']),
                                              const Spacer(),
                                              Text(
                                                  ' ${item['quantity']} x RM ${item['price'].toStringAsFixed(2)}')
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const SizedBox(); // Or display an error message
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Total : RM ${orderData['totalPrice'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                controller: _locationController,
                                obscureText: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  hintText: "Block D, Uthman",
                                  label: const Text("Enter your location"),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLocation = _locationController.text;
                                });
                              },
                              child: Text("Update",
                                  style: TextStyle(
                                    color: primaryColor,
                                  )),
                            ),
                            SizedBox(width: 20),
                            const SizedBox(height: 20),
                            Visibility(
                              visible: _selectedLocation == 'Location' ||
                                  _selectedLocation.isEmpty,
                              child: Text(
                                "To continue, Please enter you location",
                                style: TextStyle(
                                    color: primaryColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 70),
                      child: Visibility(
                        visible: _selectedLocation != '' &&
                            _locationController.text.isNotEmpty,
                        child: MyButton(
                            text: "Choose Runner",
                            onTap: () {
                              setState(() {
                                _updateOrderLocation();
                              });
                              if (_selectedLocation != 'Location') {
                                // Location is selected, proceed to the next page
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChooseRunnerPage(
                                              orderId: widget.orderID,
                                            )));
                              } else {
                                // Location is not selected, show the dialog
                                // _showLocationDialog();
                              }
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No order data found'));
        }
      },
    );
  }
}
