import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mydrawer.dart';
import 'package:itawseel/pages/Customer/chatlist.dart';
import 'package:itawseel/pages/Customer/historyc.dart';
import 'package:itawseel/pages/Customer/homepagec.dart';
import 'package:itawseel/pages/Customer/profile.dart';
import 'package:itawseel/themes/colors.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const Homepage(),
    const HistoryC(),
    const ChatPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Column(
          children: [
            Text(
              'IIUM Food Delivery',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
              },
              icon: const Icon(Icons.person_2_outlined),
              color: const Color.fromARGB(255, 255, 255, 255))
        ],
        toolbarHeight: 70,
      ),
      drawer: const MyDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Material(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
            child: BottomNavigationBar(
              elevation: 20,
              unselectedItemColor: Colors.white54,
              fixedColor: Colors.white,
              backgroundColor: primaryColor,
              currentIndex: _selectedIndex,
              onTap: _navigateBottomBar,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: "History",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: "Message",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
