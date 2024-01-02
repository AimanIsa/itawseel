import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itawseel/pages/Customer/trackingorder.dart';
import 'package:itawseel/themes/colors.dart';

class ChooseRunnerPage extends StatefulWidget {
  final String orderId;

  const ChooseRunnerPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<ChooseRunnerPage> createState() => _ChooseRunnerPageState();
}

class _ChooseRunnerPageState extends State<ChooseRunnerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Runner',
          style: TextStyle(color: white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: primaryColor,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(widget.orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                // ignore: unnecessary_nullable_for_final_variable_declarations
                final Map<String, dynamic>? orderData =
                    snapshot.data?.data() as Map<String, dynamic>;

                if (orderData != null) {
                  final offeredList = orderData['offered'];
                  return ListView.builder(
                    itemCount: offeredList.length,
                    itemBuilder: (context, index) {
                      final offer = offeredList[index];
                      // Access riderId and offered price safely
                      final riderId = offer['riderId'] as String;
                      final riderUsername = offer['username'] as String;
                      final offeredPrice = offer['offeredChargeFees'] as num;
                      final imageUrl = offer['imageUrl'] as String;

                      // Assuming offered price is a number
                      if (index != 0) {
                        return RunnerCard(
                          riderId: riderId,
                          username: riderUsername,
                          offeredChargeFees: offeredPrice,
                          profileImage: imageUrl,
                          onChooseRunner: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.orderId)
                                  .update({
                                'Runnerusername': riderUsername,
                                'offerStatus': 'riderselected',
                                'chosenRiderId': riderId,
                                'offeredChargeFees': offeredPrice,
                                // Add other chosen rider details if needed
                              });

                              // Notify the chosen rider (implement your notification logic here)
                              // ...
                            } catch (error) {
                              // Handle errors gracefully, e.g., show an error message to the user
                            }
                          },
                          orderid: widget.orderId,
                        );
                      } else if (index == 0) {
                        return Visibility(
                            visible: index != 0 || riderId.isNotEmpty,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(
                                    'Waiting for runner...',
                                    style: TextStyle(color: white),
                                  ),
                                  SizedBox(height: 20),
                                  CircularProgressIndicator(
                                    color: white,
                                  ),
                                ],
                              ),
                            ));
                      }
                    },
                  );
                } else {
                  return const Center(child: Text('No order data available'));
                }
              } else {
                return const Center(child: Text('Loading order data...'));
              }
            }, // <-- Closing curly brace for builder
          ),
        ),
      ),
    );
  }
}

_chooserunner(String riderId, num offeredPrice) async {}

class RunnerCard extends StatefulWidget {
  final String riderId;
  final String username;
  final num offeredChargeFees;
  final String profileImage;
  final String orderid;

  // Add other runner details...

  final Function onChooseRunner;

  const RunnerCard({
    Key? key,
    required this.riderId,
    required this.offeredChargeFees,
    required this.onChooseRunner,
    required this.username,
    required this.profileImage,
    required this.orderid,
  }) : super(key: key);

  @override
  State<RunnerCard> createState() => _RunnerCardState();
}

class _RunnerCardState extends State<RunnerCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.circular(12))),
          onPressed: () {
            widget.onChooseRunner();

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TrackOrderPage(
                          orderId: widget.orderid,
                        )));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.profileImage),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.username}',
                        style: TextStyle(
                            fontSize: 20,
                            color: primaryColor,
                            fontWeight: FontWeight.bold)),
                    const Text('rating'),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Fee:',
                      style: TextStyle(color: primaryColor),
                    ),
                    Row(
                      children: [
                        const Text("RM "),
                        Text(
                          '${widget.offeredChargeFees.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
