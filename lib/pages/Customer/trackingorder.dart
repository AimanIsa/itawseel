import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        title: const Text('Track Order'),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Chosen Rider: ${orderData['chosenRiderId']}'),
                          const SizedBox(height: 8.0),
                          Text(
                              'Total Price: ${(orderData['totalPrice'] as num) + orderData['offeredChargeFees']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
            ListTile(
              leading: const Icon(Icons.person_pin),
              title: const Text('Rider Selected'),
              trailing: offerStatus == 'riderSelected'
                  ? const Icon(Icons.circle, color: Colors.green)
                  : const SizedBox(), // Show a green circle if this step is active
            ),

            // Buying food
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Buying Food'),
              trailing: offerStatus == 'buyingFood'
                  ? const Icon(Icons.circle, color: Colors.green)
                  : const SizedBox(),
            ),

            // On the way
            ListTile(
              leading: const Icon(Icons.delivery_dining),
              title: const Text('On the Way'),
              trailing: offerStatus == 'onTheWay'
                  ? const Icon(Icons.circle, color: Colors.green)
                  : const SizedBox(),
            ),

            // Completed
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Completed'),
              trailing: offerStatus == 'completed'
                  ? const Icon(Icons.circle, color: Colors.green)
                  : const SizedBox(),
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
