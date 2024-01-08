import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:itawseel/Components/navigation.dart';
import 'package:itawseel/pages/Customer/homepagec.dart';
import 'package:itawseel/themes/colors.dart';

class RunnerRatingPage extends StatefulWidget {
  final String orderId;

  const RunnerRatingPage(
      {Key? key, required this.orderId, required choosenRunnerId})
      : super(key: key);

  @override
  State<RunnerRatingPage> createState() => _RunnerRatingPageState();
}

class _RunnerRatingPageState extends State<RunnerRatingPage> {
  int _rating = 0;

  getChosenRiderId(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (orderDoc.exists) {
        final data = orderDoc.data();
        return data?['chosenRiderId'] as String?;
      } else {
        return null; // Order document not found
      }
    } catch (error) {
      print(orderId);
      // Handle potential errors, such as network issues or invalid orderId
      print('Error retrieving chosenRiderId: $error');
      return null;
    }
  }

  Future<void> rateRunner(String orderId, int rating) async {
    try {
      // Fetch the order document
      DocumentSnapshot orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      // Get the chosen rider ID from the order
      var riderId = getChosenRiderId(orderId);

      print(riderId);
      // Update the user document with the new rating
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(riderId as String?)
          .update({'ratingrunner': FieldValue.increment(rating)});

      // Handle success
      print('Runner rated successfully!');
    } catch (error) {
      // Handle errors
      print('Error rating runner: $error');
      var riderId = getChosenRiderId(orderId);
      print(riderId);
      // Consider displaying an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rate Runner',
          style: TextStyle(color: white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('How would you rate the runner?'),
                  RatingBar.builder(
                    initialRating: _rating.toDouble(),
                    minRating: 1,
                    itemCount: 5,
                    allowHalfRating: true,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating.toInt();
                      });
                    },
                  ),
                  // ...
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await rateRunner(widget.orderId, _rating);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Navigation()),
                );
              },
              child: Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}
