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
            final orderData = snapshot.data!.data() as Map<String, dynamic>;
            var riderOffered = orderData['offered'];

            if (riderOffered.isEmpty) {
              return Center(child: Text('No offers available yet'));
            }

            return ListView.builder(
              itemCount: riderOffered.length,
              itemBuilder: (context, index) {
                final offer = riderOffered[index];
                return RunnerCard(
                  riderId: offer['riderId'],
                  offeredChargeFees: offer['offeredChargeFees'],
                  // ... other runner details from offer ...
                  onChooseRunner: () async {
                    // Handle runner selection logic here
                    try {
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderId)
                          .update({
                        'offered': {
                          'offerStatus': 'riderSelected',
                          'chosenRiderId': offer['riderId'],
                          'chosenRiderOfferedFees': offer['offeredChargeFees'],
                          // Add other chosen rider details if needed
                          'totalPrice':
                              FieldValue.increment(offer['offeredChargeFees']),
                        }
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
              },
            );
          }

          return Center(child: Text('Loading...'));
        },
      ),
    );
  }
}

class RunnerCard extends StatelessWidget {
  final String riderId;
  final double offeredChargeFees;

  // Add other runner details...

  final Function onChooseRunner;

  const RunnerCard({
    Key? key,
    required this.riderId,
    required this.offeredChargeFees,

    // Add other required variables...
    required this.onChooseRunner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ... Display runner details based on available data...
            // Examples:
            Text('ID: $riderId'),
            Text('Offered Fee: \${offeredChargeFees.toStringAsFixed(2)}'),

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
