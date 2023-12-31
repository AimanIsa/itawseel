// ignore: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mydrawer.dart';
import 'package:itawseel/pages/Runner/HomepageR.dart';
import 'package:itawseel/pages/Runner/chatR.dart';
import 'package:itawseel/pages/Runner/historyR.dart';
import 'package:itawseel/pages/Runner/profileR.dart';
import 'package:itawseel/themes/colors.dart';

class NavigationR extends StatefulWidget {
  const NavigationR({super.key});

  @override
  State<NavigationR> createState() => _NavigationState();
}

class _NavigationState extends State<NavigationR> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signout() {
    setState(() {
      FirebaseAuth.instance.signOut();
      Navigator.of(context, rootNavigator: true).pop(context);
    });
  }

  final List<Widget> _pages = [
    const HomepageR(),
    const HistoryR(),
    const ChatR(),
    const ProfileR(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Column(
          children: [
            Text(
              'Welcome Back Runner',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                _signout();
              },
              icon: const Icon(Icons.login),
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
