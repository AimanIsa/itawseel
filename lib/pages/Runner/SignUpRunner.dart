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
  String? selectedGender; // Initially unselected

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
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const NavigationR()));
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
          'gender': selectedGender,
          'riderId': riderId,
          'QrCode': "", // Add rider ID creation
        });
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const NavigationR()));
      } catch (error) {
        // ignore: use_build_context_synchronously
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
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 35,
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " as a Runner.",
                      style: TextStyle(
                        fontSize: 20,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                MyTextfields(
                  hintText: "Matric Number",
                  obscureText: false,
                  controller: matricNumberController,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Select Your Gender",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Radio<String>(
                              value: 'Brother',
                              groupValue: selectedGender,
                              onChanged: (value) =>
                                  setState(() => selectedGender = value),
                            ),
                            const Text('Brother'),
                          ],
                        ),

                        Row(
                          children: [
                            Radio<String>(
                              value: 'Sister',
                              groupValue: selectedGender,
                              onChanged: (value) =>
                                  setState(() => selectedGender = value),
                            ),
                            const Text('Sister    '),
                          ],
                        ),
                        // Add more options as needed, ensuring inclusivity
                      ],
                    )
                  ],
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
