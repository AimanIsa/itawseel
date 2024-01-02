import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mybutton.dart';
import 'package:itawseel/pages/Customer/edit_profile.dart';
import 'package:itawseel/themes/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userDoc = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        // Text("PROFILE",
                        //     style: TextStyle(
                        //         fontSize: 20,
                        //         fontWeight: FontWeight.bold,
                        //         color: primaryColor)),
                        SizedBox(height: 20),
                        Card(
                          color: primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        userDoc['imageUrl'] != 'default' &&
                                                userDoc['imageUrl'].isNotEmpty
                                            ? NetworkImage(userDoc['imageUrl'])
                                            : NetworkImage(userDoc['imageUrl']),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      userDoc['username'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                    SingleChildScrollView(
                                      child: Text(
                                        userDoc['email'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Text(
                                      userDoc['phonenumber'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                            "                                "),
                                        TextButton(
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const EditProfilePage())),
                                            child: const Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 200),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: MyButton(
                              text: "Logout",
                              onTap: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.popUntil(
                                    context, ModalRoute.withName("/"));
                              }),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
