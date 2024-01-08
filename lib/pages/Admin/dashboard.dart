import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Helper/helper_function.dart';
import 'package:itawseel/pages/Main/splash.dart';
import 'package:itawseel/themes/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int totalRiders = 0;
  int totalOrders = 0;
  int offerStatusCount = 0; // Assuming offerStatus is a boolean field

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _getOrderCount() async {
    final QuerySnapshot ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    totalOrders = ordersSnapshot.docs.length;
    // Count order IDs for more accurate total
    final Iterable<String> orderIds = ordersSnapshot.docs.map((doc) => doc.id);
    totalOrders = orderIds.length;

    setState(() {}); // Update the UI
  }

  Future<void> _getUserCounts() async {
    final QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    final QuerySnapshot ridersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('isRunner', isEqualTo: true)
        .get();

    print(ridersSnapshot);
    setState(() {
      totalUsers = usersSnapshot.docs.length;
      totalRiders = ridersSnapshot.docs.length;
    });
  }

  Future<void> _resetOrders() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });
      _getOrderCount(); // Refresh the order count
      displayMessageToUser('Orders deleted successfully!', context);
    } on FirebaseException catch (e) {
      displayMessageToUser(e.code, context);
    }
  }

  _fetchData() {
    _getUserCounts(); // Fetch user and rider counts
    _getOrderCount(); // Fetch order counts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                QuickAlert.show(
                  onCancelBtnTap: () {
                    Navigator.pop(context);
                  },
                  onConfirmBtnTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Splash()),
                    );
                  },
                  context: context,
                  type: QuickAlertType.confirm,
                  text: 'Do you want to logout?',
                  titleAlignment: TextAlign.center,
                  textAlignment: TextAlign.center,
                  confirmBtnText: 'Yes',
                  cancelBtnText: 'No',
                  confirmBtnColor: Colors.white,
                  backgroundColor: white,
                  headerBackgroundColor: Colors.grey,
                  confirmBtnTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  barrierColor: const Color.fromARGB(181, 0, 0, 0),
                  titleColor: Colors.black,
                  textColor: Colors.black,
                );
              },
              icon: const Icon(Icons.logout),
              color: const Color.fromARGB(255, 255, 255, 255))
        ],
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 40),
                Text(
                  "Welcome back,",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  " Admin!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Card(
                          child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.people),
                      )),
                      const Text('Total Users: '),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '$totalUsers',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Card(
                          child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.motorcycle),
                      )),
                      const Text('Total Runners: '),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$totalRiders',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Orders: '),
                      Text(
                        '$totalOrders',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _resetOrders,
                  child: const Text(
                    'Reset Orders',
                    style: TextStyle(color: Color.fromARGB(255, 116, 8, 0)),
                  ),
                ),
                const SizedBox(width: 60)
              ],
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () => setState(() => _fetchData()),
              child: Text(
                'Refresh',
                style: TextStyle(color: white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), color: primaryColor),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.dashboard,
                        color: white,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Dashboard",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat,
                        color: white,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "Chat",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
