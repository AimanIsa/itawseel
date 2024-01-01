import 'package:flutter/material.dart';
import 'package:itawseel/themes/colors.dart';

class TrackOrderPage extends StatefulWidget {
  final String ChoosenRiderId;
  const TrackOrderPage({super.key, required this.ChoosenRiderId});

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Track Order",
          style: TextStyle(color: white),
        ),
      ),
    );
  }
}
