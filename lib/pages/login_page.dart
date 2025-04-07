import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'food_donation_page.dart';
import 'donor_form_page.dart';
import 'user_verification_page.dart'; // Make sure this file exists

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final url = Uri.parse('http://192.168.29.251:8080/api/fooddonation/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['code'] == 'SUCCESS') {
        final role = jsonResponse['details']['role'];

        FlutterToastr.show(
          "Login Successful!",
          context,
          duration: FlutterToastr.lengthShort,
          position: FlutterToastr.bottom,
        );

        if (role == 'VOLUNTEER') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodDonationPage()),
          );
        } else if (role == 'Donor') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DonorFormPage(email: emailController.text)),
          );
        } else if (role == 'Admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserVerificationPage()),
          );
        } else {
          FlutterToastr.show(
            "Login allowed only for VOLUNTEERS, DONORS, or ADMIN.",
            context,
            duration: FlutterToastr.lengthLong,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.red,
          );
        }
      } else {
        FlutterToastr.show(
          "Login failed. Check credentials.",
          context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      FlutterToastr.show(
        "Error occurred: $e",
        context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/img_6.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
                  child: Text("Login"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text("Sign Up"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
