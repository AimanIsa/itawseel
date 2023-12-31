import 'package:flutter/material.dart';

class WaitingCustomer extends StatelessWidget {
  const WaitingCustomer({super.key, required String orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
            child: Text(
                "Jap eh, tgh tunggu customer accept. Kalau dia reject, amik order lain ya ")),
      ),
    );
  }
}
