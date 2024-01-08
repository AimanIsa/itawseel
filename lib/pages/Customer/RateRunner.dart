import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingRunner extends StatefulWidget {
  const RatingRunner(
      {super.key,
      required String orderID,
      required Future<String?> choosenRunnerId});

  @override
  State<RatingRunner> createState() => _RatingRunnerState();
}

class _RatingRunnerState extends State<RatingRunner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text("Rate Runner"),
      ),
    );
  }
}
