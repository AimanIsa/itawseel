import 'package:flutter/material.dart';
import 'package:itawseel/themes/colors.dart';

class TrackingOrder extends StatelessWidget {
  const TrackingOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracking Order',
          style: TextStyle(color: white),
        ),
      ),
    );
  }
}
