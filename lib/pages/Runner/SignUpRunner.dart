import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mybutton.dart';
import 'package:itawseel/Components/navigationR.dart';
import 'package:itawseel/Helper/helper_function.dart';
import 'package:itawseel/themes/colors.dart';

import '../../Components/mytextfields.dart';

class RunnerSignUpPage extends StatefulWidget {
  const RunnerSignUpPage({super.key});

  @override
  State<RunnerSignUpPage> createState() => _RunnerSignUpPageState();
}

class _RunnerSignUpPageState extends State<RunnerSignUpPage> {
  final TextEditingController matricNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Check if user is already a runner
    _auth.currentUser?.reload();
    _checkIfRunner();
  }

  void _checkIfRunner() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();
      if (doc.exists && doc.get('isRunner') == true) {
        // User is already a runner, redirect to runner homepage
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NavigationR()));
      }
    }
  }

  void signUpAsRunner() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        String riderId = FirebaseAuth.instance.currentUser!.uid + "_rider";

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .update({
          'isRunner': true,
          'matricNumber': matricNumberController.text,
          'gender': genderController.text,
          'riderId': riderId,
          'QrCode': "", // Add rider ID creation
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => NavigationR()));
      } catch (error) {
        displayMessageToUser('Error registering as a runner: $error', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sign Up as a Runner",
                  style: TextStyle(
                    fontSize: 35,
                    color: primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 50),
                MyTextfields(
                  hintText: "Matric Number",
                  obscureText: false,
                  controller: matricNumberController,
                ),
                const SizedBox(height: 10),
                MyTextfields(
                  hintText: "Gender",
                  obscureText: false,
                  controller: genderController,
                ),
                const SizedBox(height: 40),
                MyButton(
                  text: "Sign Up as Runner",
                  onTap: signUpAsRunner,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
