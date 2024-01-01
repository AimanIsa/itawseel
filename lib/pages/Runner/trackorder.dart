import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/themes/colors.dart';

class TrackOrderRunnerPage extends StatefulWidget {
  final String orderId;

  const TrackOrderRunnerPage({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<TrackOrderRunnerPage> createState() => _TrackOrderRunnerPageState();
}

class _TrackOrderRunnerPageState extends State<TrackOrderRunnerPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _orderStream;
  String offerStatus = 'riderSelected'; // Initial status

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

          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: orderData!['fooditem'].length,
                itemBuilder: (context, index) {
                  final item = orderData['fooditem'][index];
                  return ListTile(
                    title: Text(item['name']),
                    trailing:
                        Text('${item['price']}'), // Adjust currency formatting
                  );
                },
              ),

              // Chosen rider and total price
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Chosen Rider: ${orderData!['chosenRiderId']}'),
                    const SizedBox(height: 8.0),
                    Text(' Charge Fees: ${orderData!['offeredChargeFees']}'),
                    const SizedBox(height: 8.0),
                    Text(
                        'Total Price: ${(orderData!['totalPrice'] as num) + orderData!['offeredChargeFees']}'),
                  ],
                ),
              ),

              // Middle section with timeline and buttons
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: primaryColor),
                      child: _buildTimeline(offerStatus)),
                ),
              ),

              // Bottom section with buttons for updating status
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateOfferStatus('buyingFood'),
                      child: const Text('Mark as Buying Food'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateOfferStatus('onTheWay'),
                      child: const Text('Mark as On the Way'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateOfferStatus('completed'),
                      child: const Text('Mark as Completed'),
                    ),
                  ],
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
            Card(
              color: primaryColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  leading: Icon(
                    Icons.person_pin,
                    color: white,
                  ),
                  title: Text(
                    'Rider Selected',
                    style: TextStyle(color: white),
                  ),
                  trailing: offerStatus == 'riderSelected'
                      ? const Icon(Icons.circle, color: Colors.green)
                      : const SizedBox(), // Show a green circle if this step is active
                ),
              ),
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

  void _updateOfferStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({'offerStatus': newStatus});
    setState(() {
      offerStatus = newStatus;
    });
  }
}
