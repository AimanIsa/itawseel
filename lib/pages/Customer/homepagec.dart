import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/cafeteria.dart';
import 'package:itawseel/pages/Customer/menupage.dart';
import 'package:itawseel/themes/colors.dart';

import 'Food.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.email)
                .snapshots(),
            builder: (context, snapshot) {
              // get user data
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      //search bar

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 35),
                            child: Row(
                              children: [
                                const Text('Hello',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 5),
                                Text(
                                  userData['username'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text("So, what's on your menu for today?"),
                          ),
                          const SizedBox(height: 20),
                          // Container(
                          //   decoration: BoxDecoration(color: primaryColor),
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 0.0, vertical: 5.0),
                          //     child: Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 35.0, vertical: 7.0),
                          //       child: TextField(
                          //         decoration: InputDecoration(
                          //           filled: true,
                          //           fillColor: Colors.white,
                          //           enabledBorder: OutlineInputBorder(
                          //             borderSide:
                          //                 const BorderSide(color: Colors.black),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //           focusedBorder: OutlineInputBorder(
                          //             borderSide:
                          //                 const BorderSide(color: Colors.black),
                          //             borderRadius: BorderRadius.circular(10),
                          //           ),
                          //           hintText: 'Favourite',
                          //           hintStyle: TextStyle(color: primaryColor),
                          //         ),
                          //         style: TextStyle(color: primaryColor),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(height: 10),

                          // Text title
                          Container(
                            decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20))),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Text(
                                'Cafeteria        ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Cafeteria(
                                cafeImage:
                                    const AssetImage("lib/Images/Ali.png"),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MenuPage(
                                                foodItems: [
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasigepuk.jpg",
                                                      name: "Nasi Gepuk Ali",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikicap.jpg",
                                                      name: "Nasi Kicap Ali",
                                                      price: 6.50),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikakwok.jpg",
                                                      name: "Nasi Kak Wok Ali",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasiayam.jpg",
                                                      name: "Nasi Ayam Ali",
                                                      price: 6.50),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/shawarma.png",
                                                      name: "Shawarma Ali",
                                                      price: 5.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/teh-o-ais.png",
                                                      name: "Teh O Ais Ali",
                                                      price: 1.50),
                                                ],
                                              )));
                                },
                              ),
                              Cafeteria(
                                cafeImage:
                                    const AssetImage("lib/Images/siddiq.png"),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MenuPage(
                                                foodItems: [
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasigepuk.jpg",
                                                      name: "Nasi Gepuk Siddiq",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikicap.jpg",
                                                      name: "Nasi Kicap Siddiq",
                                                      price: 6.50),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikakwok.jpg",
                                                      name:
                                                          "Nasi Kak Wok Siddiq",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasiayam.jpg",
                                                      name: "Nasi Ayam Siddiq",
                                                      price: 6.50),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/shawarma.png",
                                                      name: "Shawarma Siddiq",
                                                      price: 5.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/teh-o-ais.png",
                                                      name: "Teh O Ais Siddiq",
                                                      price: 1.50),
                                                ],
                                              )));
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Cafeteria(
                                cafeImage:
                                    const AssetImage("lib/Images/Aminah.png"),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MenuPage(
                                                foodItems: [
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasigepuk.jpg",
                                                      name: "Nasi Gepuk Aminah",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikicap.jpg",
                                                      name: "Nasi Kicap Aminah",
                                                      price: 6.50),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikakwok.jpg",
                                                      name:
                                                          "Nasi Kak Wok Aminah",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/shawarma.png",
                                                      name: "Shawarma Aminah",
                                                      price: 5.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/teh-o-ais.png",
                                                      name: "Teh O Ais Aminah",
                                                      price: 1.50),
                                                ],
                                              )));
                                },
                              ),
                              Cafeteria(
                                cafeImage:
                                    const AssetImage("lib/Images/Bilal.png"),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MenuPage(
                                                foodItems: [
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasigepuk.jpg",
                                                      name: "Nasi Gepuk Bilal",
                                                      price: 6.00),
                                                  FoodItem(
                                                      assetpath:
                                                          "lib/Images/nasikicap.jpg",
                                                      name: "Nasi Kicap Bilal",
                                                      price: 6.50),
                                                ],
                                              )));
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error" + snapshot.error.toString()),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
