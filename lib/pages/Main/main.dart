import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:itawseel/pages/Login&SignUp/auth_page.dart';
import 'package:itawseel/pages/Main/splash.dart';
import 'package:itawseel/themes/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 128, 10, 1),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
            iconTheme: IconThemeData(color: white),
          )),
      home: const Splash(),
    );
  }
}
