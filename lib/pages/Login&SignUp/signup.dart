//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mybutton.dart';
import 'package:itawseel/Components/mytextfields.dart';
import 'package:itawseel/Helper/helper_function.dart';
import 'package:itawseel/themes/colors.dart';

class SignUpPage extends StatefulWidget {
  final void Function()? onTap;

  const SignUpPage({super.key, required this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Text editing Controller
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPwController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = true;
  bool _isCFPasswordVisible = true;

  void SignUpUser() async {
    //show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // make sure password match
    if (passwordController.text != confirmPwController.text) {
      Navigator.pop(context);
      //Show error message
      displayMessageToUser("Password don't match", context);
    }

    // creating the user
    else {
      try {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //afer creating user, create a new document in the firebase
        FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.email!)
            .set({
          'username': emailController.text.split('@')[0],
          'email': emailController.text,
          'password': passwordController.text,
          'phonenumber': phoneController.text,
          'imageUrl': "default",
          'location': "currentLocation",
          'isRunner': false,
        });

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        // Show Error Message
        displayMessageToUser(e.code, context);
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
                  // Text login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 35,
                            color: primaryColor,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),

                  // Text Create your first account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Create your first account ",
                        style: TextStyle(fontSize: 15, color: primaryColor),
                      ),
                    ],
                  ),

                  // TextField Email
                  const SizedBox(height: 50),

                  // Textfield password
                  const SizedBox(height: 10),
                  MyTextfields(
                      hintText: "Email",
                      obscureText: false,
                      controller: emailController),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmPwController,
                    obscureText: _isPasswordVisible,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(18),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      labelText: 'Password',
                    ),
                  ),

                  // Textfield password
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _isCFPasswordVisible,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(18),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            _isCFPasswordVisible = !_isCFPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isCFPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      labelText: 'Confirm Password',
                    ),
                  ),

                  const SizedBox(height: 10),
                  MyTextfields(
                      hintText: "Phone Number",
                      obscureText: false,
                      controller: phoneController),

                  // Button Login
                  const SizedBox(height: 40),
                  MyButton(
                    text: "SignUp",
                    onTap: SignUpUser,
                  ),

                  // Text Don’t have an account ? SignUp
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account ?"),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          " Login here",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
