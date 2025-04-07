import 'package:flutter/material.dart';
import 'package:food_donation_app/pages/signup_page.dart';
import 'pages/intro_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // <-- add const here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Donation App',
      home: IntroPage(),
      routes: {
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
