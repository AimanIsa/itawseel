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

  Future<void> _showLocationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogTheme(
            backgroundColor:
                Color.fromARGB(255, 255, 255, 255), // Adjust background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Customize shape
            ),
          ),
        ),
        child: AlertDialog(
          title: Text('Enter your Location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const SizedBox(height: 15),
                Text("Enter your specific Location"),
                const SizedBox(height: 15),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: 'eg: Block D, Uthman',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedLocation = _locationController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Set Location'),
            ),
          ],
        ),
      ),
    );
  }

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
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Details ',
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Order ID: ${orderData['orderId']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Selected Location:',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Container(
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _selectedLocation,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showLocationDialog();
                                  },
                                  icon: Icon(Icons.arrow_drop_down_rounded),
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.only(left: 15),
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          Text(item['name']),
                                          Spacer(),
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
                        const SizedBox(height: 50),
                        Text(
                          'Total Price: ${orderData['totalPrice']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Visibility(
                            visible: _selectedLocation != 'Location',
                            child: MyButton(
                                text: "Continue",
                                onTap: () {
                                  setState(() {
                                    _updateOrderLocation();
                                  });
                                  if (_selectedLocation != 'Location') {
                                    // Location is selected, proceed to the next page
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ChooseRunnerPage(
                                                  orderId: '',
                                                )));
                                  } else {
                                    // Location is not selected, show the dialog
                                    _showLocationDialog();
                                  }
                                }),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'to continue, please select your Location',
                          style: TextStyle(fontSize: 12, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
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
