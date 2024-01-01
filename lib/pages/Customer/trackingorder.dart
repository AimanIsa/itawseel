import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:itawseel/themes/colors.dart';

class TrackOrderPage extends StatefulWidget {
  final String orderId;

  const TrackOrderPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
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
          'Track Order',
          style: TextStyle(color: white),
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

          return Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // Item details
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: orderData['fooditem'].length,
                      itemBuilder: (context, index) {
                        final item = orderData['fooditem'][index];
                        return ListTile(
                          title: Text(item['name']),
                          trailing: Text(
                              '${item['price']}'), // Adjust currency formatting
                        );
                      },
                    ),

                    // Chosen rider and total price
                    Column(
                      children: [
                        Text('Chosen Rider: ${orderData['chosenRiderId']}'),
                        const SizedBox(height: 8.0),
                        Text(
                            'Total Price: ${(orderData['totalPrice'] as num) + orderData['offeredChargeFees']}'),
                      ],
                    ),
                  ],
                ),
              ),
              Text("Track"),
              // Middle section with timeline
              Expanded(
                child: _buildTimeline(offerStatus),
              ),

              // Bottom section with chat button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _startChat(chosenRiderId),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat with Rider'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeline(String offerStatus) {
    return Column(
      children: [
        // Unordered list for a visual timeline
        ListView(
          shrinkWrap: true, // Use a dot as the timeline marker
          children: [
            // Rider selected
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: offerStatus == 'riderselected'
                      ? ListTile(
                          leading: Icon(Icons.person_pin, color: white),
                          title: Text('Rider Selected',
                              style: TextStyle(color: white)),
                          trailing:
                              const Icon(Icons.circle, color: Colors.green))
                      : const ListTile(
                          leading: Icon(
                            Icons.person_pin,
                            color: Colors.white54,
                          ),
                          title: Text('Rider Selected',
                              style: TextStyle(color: Colors.white54)),
                          trailing: const SizedBox(),
                        ),
                ),
              ),
            ),

            // Buying food
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: offerStatus == 'buyingFood'
                      ? ListTile(
                          leading: Icon(Icons.fastfood, color: white),
                          title: Text('Buying Food',
                              style: TextStyle(color: white)),
                          trailing:
                              const Icon(Icons.circle, color: Colors.green))
                      : const ListTile(
                          leading: Icon(
                            Icons.fastfood,
                            color: Colors.white54,
                          ),
                          title: Text('Buying Food',
                              style: TextStyle(color: Colors.white54)),
                          trailing: const SizedBox(),
                        ),
                ),
              ),
            ),

            // On the way
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: offerStatus == 'onTheWay'
                      ? ListTile(
                          leading: Icon(Icons.delivery_dining, color: white),
                          title: Text('On The Way',
                              style: TextStyle(color: white)),
                          trailing:
                              const Icon(Icons.circle, color: Colors.green))
                      : const ListTile(
                          leading: Icon(
                            Icons.delivery_dining_outlined,
                            color: Colors.white54,
                          ),
                          title: Text('On The Way',
                              style: TextStyle(color: Colors.white54)),
                          trailing: const SizedBox(),
                        ),
                ),
              ),
            ),

            // Completed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                color: primaryColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: offerStatus == 'completed'
                      ? ListTile(
                          leading: Icon(Icons.check, color: white),
                          title:
                              Text('Completed', style: TextStyle(color: white)),
                          trailing:
                              const Icon(Icons.circle, color: Colors.green))
                      : const ListTile(
                          leading: Icon(
                            Icons.check,
                            color: Colors.white54,
                          ),
                          title: Text('Completed',
                              style: TextStyle(color: Colors.white54)),
                          trailing: const SizedBox(),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startChat(String riderId) {
    // Initiate chat with the rider
    // ... (Implement using your chat library's functionalities)
  }
}
