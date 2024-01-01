import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChooseRunnerPage extends StatelessWidget {
  final String orderId;

  const ChooseRunnerPage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Runner'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            print(snapshot.hasData);
            print(orderId);

            final Map<String, dynamic>? orderData =
                snapshot.data?.data() as Map<String, dynamic>;
            print(orderData);

            if (orderData != null) {
              final offeredList = orderData['offered'];
              print(offeredList);
              return ListView.builder(
                itemCount: offeredList.length,
                itemBuilder: (context, index) {
                  final offer = offeredList[index];
                  // Access riderId and offered price safely
                  final riderId = offer['riderId'] as String;
                  final riderUsername = offer['username'] as String;
                  final offeredPrice = offer['offeredChargeFees'] as num;
                  // Assuming offered price is a number
                  if (index > 0) {
                    return RunnerCard(
                      riderId: riderId,
                      username: riderUsername,
                      offeredChargeFees: offeredPrice,
                      // ... other runner details from offer ...
                      onChooseRunner: () async {
                        // Handle runner selection logic here
                        try {
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({
                            'offerStatus': 'riderSelected',
                            'chosenRiderId': riderId,
                            'chosenRiderOfferedPrice': offeredPrice,
                            // Add other chosen rider details if needed
                          });

                          // Notify the chosen rider (implement your notification logic here)
                          // ...

                          // Navigate to a new screen or show a success message
                          // ...
                        } catch (error) {
                          print('Error updating order: $error');
                          // Handle errors gracefully, e.g., show an error message to the user
                        }
                      },
                    );
                  } else {
                    return Center(child: Text('Waiting for Runner..'));
                  }
                },
              );
            } else {
              return Center(child: Text('No order data available'));
            }
          } else {
            return Center(child: Text('Loading order data...'));
          }
        }, // <-- Closing curly brace for builder
      ),
    );
  }
}

class RunnerCard extends StatelessWidget {
  final String riderId;
  final String username;
  final num offeredChargeFees;

  // Add other runner details...

  final Function onChooseRunner;

  const RunnerCard({
    Key? key,
    required this.riderId,
    required this.offeredChargeFees,

    // Add other required variables...
    required this.onChooseRunner,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Name: $username'),
            Text('Offered Fee: $offeredChargeFees'),

            // Add other details like profile picture, rating, etc. ...
            ElevatedButton(
              onPressed: () {
                onChooseRunner;
              },
              child: Text('Choose Runner'),
            ),
          ],
        ),
      ),
    );
  }
}
