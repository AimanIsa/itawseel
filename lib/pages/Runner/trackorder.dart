import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/Components/navigationR.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
    bool isarrived = true;
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
                      builder: (context) => NavigationR(),
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
              onPressed: () {},
              icon: const Icon(Icons.message),
              color: const Color.fromARGB(255, 255, 255, 255))
        ],
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
                const SizedBox(height: 10),
                // Chosen rider and total price

                // Middle section with timeline and buttons
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
                    Row(
                      children: [
                        const SizedBox(width: 30),
                        Text(
                          "( Click on the icon button below to update )",
                          style: TextStyle(color: primaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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

                const SizedBox(height: 20),

                // Bottom section with buttons for updating status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 10),
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
                      onPressed: () {
                        isarrived = true;
                        _updateOfferStatus('arrived');
                      },
                      child: Icon(Icons.check_circle_outline_rounded,
                          color: white),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 20),
                // Text("Click on this button to update order status"),
                const Divider(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
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
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          title: const Text(
                            'Charge Fees: ',
                            style: TextStyle(fontSize: 15),
                          ),
                          trailing: Text(
                            'RM ${orderData!['offeredChargeFees'].toString()}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(item['name'],
                                          style: const TextStyle(fontSize: 15)),
                                      const SizedBox(width: 30),
                                      Text(
                                        ' x ${item['quantity'].toString()} ',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),

                                  trailing: Text(
                                    'RM ${item['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 15),
                                  ), // Adjust currency formatting
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListTile(
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              title: const Text(
                                'Total Item Price : ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                // Calculate the total price directly
                                'RM ${(orderData['totalPrice'] as num)}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListTile(
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              title: const Text(
                                'Total Items Price + Fees : ',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                // Calculate the total price directly
                                'RM ${(orderData['totalPrice'] as num) + orderData['offeredChargeFees']}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Chosen rider and total price
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Visibility(
        visible: isarrived,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  QuickAlert.show(
                    onCancelBtnTap: () {
                      Navigator.pop(context);
                    },
                    onConfirmBtnTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationR()));
                    },
                    context: context,
                    type: QuickAlertType.confirm,
                    text: 'Did customer paid you?',
                    title: "Completed",
                    titleAlignment: TextAlign.center,
                    textAlignment: TextAlign.center,
                    confirmBtnText: 'Yes',
                    cancelBtnText: 'No',
                    confirmBtnColor: Colors.white,
                    backgroundColor: const Color.fromARGB(115, 255, 255, 255),
                    headerBackgroundColor: Colors.grey,
                    confirmBtnTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    barrierColor: Color.fromARGB(185, 0, 0, 0),
                    titleColor: Colors.black,
                    textColor: Colors.black,
                  );
                },
                child: Text(
                  "Completed",
                  style: TextStyle(color: white),
                )),
          ),
        ),
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
