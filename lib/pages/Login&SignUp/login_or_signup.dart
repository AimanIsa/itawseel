import 'package:flutter/material.dart';
import 'package:itawseel/pages/Login&SignUp/loginpage.dart';
import 'package:itawseel/pages/Login&SignUp/signup.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  bool isLogin = true;

  void togglePage() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginPage(onTap: togglePage);
    } else {
      return SignUpPage(onTap: togglePage);
    }
  }
}
