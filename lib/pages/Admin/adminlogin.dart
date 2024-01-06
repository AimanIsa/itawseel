import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:itawseel/Components/mybutton.dart';
import 'package:itawseel/Components/mytextfields.dart';
import 'package:itawseel/Helper/helper_function.dart';
import 'package:itawseel/pages/Admin/dashboard.dart';
import 'package:itawseel/themes/colors.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isPasswordVisible = true;

  Future<void> adminLogin() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc('admin123@gmail.com')
          .get();
      if (adminDoc.exists &&
          adminDoc.data()!['password'] == passwordController.text) {
        // await FirebaseAuth.instance
        //     .signInAnonymously(); // Use anonymous sign-in for admin
        Navigator.pop(context);
        // Navigate to admin page
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AdminDashboard()));
      } else {
        Navigator.pop(context);
        displayMessageToUser('Invalid email or password', context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (rest of your UI structure)
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Text login
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 35,
                              color: primaryColor,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),

                    // Text Login to your account to continue
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Login as administrator",
                          style: TextStyle(fontSize: 13, color: primaryColor),
                        ),
                      ],
                    ),

                    // TextField Email
                    const SizedBox(height: 30),
                    MyTextfields(
                        hintText: "Email",
                        obscureText: false,
                        controller: emailController),

                    // Textfield password
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: passwordController,
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

                    // Text Forgot Password
                    const SizedBox(height: 5),

                    // Button Login
                    const SizedBox(height: 40),
                    MyButton(
                      text: "Login",
                      onTap: adminLogin,
                    ),

                    // Text Don’t have an account ? SignUp
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
