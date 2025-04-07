import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/environment.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedGender = 'Male';
  String selectedRole = 'Donor';

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('${Environment.baseUrl}/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "phoneNumber": phoneController.text.trim(),
          "name": nameController.text.trim(),
          "gender": selectedGender,
          "address": addressController.text.trim(),
          "role": selectedRole,
          "password": passwordController.text,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['code'] == 'SUCCESS') {
        FlutterToastr.show("Signup Successful!", context,
            duration: FlutterToastr.lengthShort, position: FlutterToastr.bottom);
        Navigator.pop(context);
      } else {
        FlutterToastr.show("Signup failed: ${jsonResponse['message']}", context,
            duration: FlutterToastr.lengthLong,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      FlutterToastr.show("Error occurred: $e", context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (value.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 335,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/img_3.png"),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 350),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: "Name"),
                        validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Name is required' : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Email"),
                        validator: _validateEmail,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: "Phone Number"),
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: "Address"),
                        validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Address is required' : null,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(labelText: "Gender"),
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(labelText: "Role"),
                        items: ['Donor', 'VOLUNTEER', 'Admin']
                            .map((role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Password"),
                        validator: _validatePassword,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: signup,
                        child: Text("Sign Up"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
