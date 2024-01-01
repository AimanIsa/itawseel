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

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                // Chosen rider and total price
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Rider: ${orderData!['Runnerusername']}',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            ' Charge Fees: ${orderData['offeredChargeFees']}',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            ' Location: ${orderData['location']}',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Total Price: ${(orderData['totalPrice'] as num) + orderData['offeredChargeFees']}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      const Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            "Food Items",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: primaryColor),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: orderData['fooditem'].length,
                              itemBuilder: (context, index) {
                                final item = orderData['fooditem'][index];
                                final count = 0 + 1;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    color: primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        leading: Text(
                                          '$count',
                                          style: TextStyle(
                                              color: white, fontSize: 15),
                                        ),
                                        title: Text(
                                          item['name'],
                                          style: TextStyle(
                                              color: white, fontSize: 15),
                                        ),
                                        trailing: Text(
                                          'RM ${item['price']}',
                                          style: TextStyle(
                                              color: white, fontSize: 15),
                                        ), // Adjust currency formatting
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle section with timeline and buttons
                Column(
                  children: [
                    SizedBox(height: 10),
                    const Row(
                      children: [
                        SizedBox(width: 20),
                        Text(
                          "Tracking Progress",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: primaryColor),
                          child: _buildTimeline(offerStatus)),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Bottom section with buttons for updating status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () => _updateOfferStatus('buyingFood'),
                      child: Icon(Icons.fastfood_rounded, color: white),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () => _updateOfferStatus('onTheWay'),
                      child: Icon(Icons.delivery_dining_rounded, color: white),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor),
                      onPressed: () => _updateOfferStatus('completed'),
                      child: Icon(Icons.check_circle_outline_rounded,
                          color: white),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(
                  height: 100,
                )
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
    ;
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
