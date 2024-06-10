import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthy/app/auth/login.dart';
import 'package:healthy/app/auth/signup.dart';
import 'package:healthy/app/auth/success.dart';
import 'package:healthy/app/home.dart';
import 'package:http/http.dart' as http;  // Import the http package
import 'app/vitsalsigns/add.dart';

late SharedPreferences sharedPref;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPref = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IOT MEDICAL APPLICATION',
      initialRoute: sharedPref.getString("id") == null ? "login" : "home",
      routes: {
        "login": (context) => Login(httpClient: http.Client()),  // Pass http.Client instance
        // "signup": (context) => const SignUp(),
        "home": (context) => Home(),
        "success": (context) => Success(),
        "AddVs": (context) => AddVs(),
        // "edit": (context) => EditVs(),
      },
    );
  }
}
