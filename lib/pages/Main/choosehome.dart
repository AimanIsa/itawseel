import 'package:flutter/material.dart';
import 'package:itawseel/Components/navigation.dart';
import 'package:itawseel/pages/Runner/SignUpRunner.dart';
import 'package:itawseel/themes/colors.dart';

class ChooseCategory extends StatefulWidget {
  const ChooseCategory({super.key});

  @override
  State<ChooseCategory> createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: const Color.fromARGB(255, 128, 10, 1),
          title: const Text("IIUM Food Delivery",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ),
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Text("Categories                 ",
                    style: TextStyle(
                        fontSize: 40,
                        color: primaryColor,
                        fontWeight: FontWeight.w800)),
                Text("You can choose to be a runner or a customer.",
                    style: TextStyle(
                      fontSize: 17,
                      color: primaryColor,
                    )),
                const SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const RunnerSignUpPage()));
                          },
                          child: const Image(
                            image: AssetImage('lib/Images/Rider.png'),
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text("Runner",
                            style: TextStyle(
                                fontSize: 20,
                                color: primaryColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const Navigation()));
                          },
                          child: const Image(
                            image: AssetImage('lib/Images/Food.png'),
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("Customer",
                            style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 128, 10, 1),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ));
  }
}
