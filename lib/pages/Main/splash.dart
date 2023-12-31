import 'package:flutter/material.dart';
import 'package:itawseel/pages/Login&SignUp/auth_page.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(const Duration(seconds: 2), () {});
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const AuthPage()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 128, 10, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //SizedBox
              SizedBox(
                height: 300,
              ),
              //Logo
              Padding(
                padding: EdgeInsets.all(10),
                child: Image(
                  image: AssetImage('lib/Images/ItawseelW.png'),
                  height: 100,
                ),
              ),

              SizedBox(
                height: 10,
              ),
              Text(
                'IIUM Food Delivery',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
