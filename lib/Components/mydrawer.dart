import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/navigation.dart';
import 'package:itawseel/pages/Customer/chatlist.dart';
import 'package:itawseel/pages/Customer/historyc.dart';
import 'package:itawseel/pages/Customer/profile.dart';
import 'package:itawseel/themes/colors.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Colors.white,
        child: Container(
          color: Colors.white,
          child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                    child: Image.asset(
                  'lib/Images/ItawseelR.png',
                  width: 180,
                )),
              ),

              //home side menu
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text(
                  'Home',
                  style: TextStyle(fontSize: 17),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Navigation()));
                },
              ),

              //  History side menu
              ListTile(
                leading: const Icon(Icons.history_edu),
                title: const Text(
                  'History',
                  style: TextStyle(fontSize: 17),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Navigation()));
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HistoryC()));
                },
                hoverColor: const Color.fromARGB(255, 128, 10, 1),
              ),
              // message side menu
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text(
                  'Messages',
                  style: TextStyle(fontSize: 17),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatPage()));
                },
                hoverColor: const Color.fromARGB(255, 128, 10, 1),
              ),

              // profile side menu
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text(
                  'Profile',
                  style: TextStyle(fontSize: 17),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()));
                },
                hoverColor: const Color.fromARGB(255, 128, 10, 1),
              ),
              const SizedBox(
                height: 300,
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        FirebaseAuth.instance.signOut();
                        Navigator.popUntil(context, ModalRoute.withName("/"));
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 20),
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                      ],
                    )),
              )
            ],
          ),
        ));
  }
}
