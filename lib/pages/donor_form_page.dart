import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/environment.dart';
import 'intro_page.dart';     // Make sure path is correct
import 'login_page.dart';     // Make sure path is correct
import 'settings_page.dart';  // <-- Add this import

class DonorFormPage extends StatefulWidget {
  final String email;

  DonorFormPage({required this.email});

  @override
  _DonorFormPageState createState() => _DonorFormPageState();
}

class _DonorFormPageState extends State<DonorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController foodItemController = TextEditingController();
  String vegOrNonVeg = 'Veg';
  String statusMessage = '';

  Future<void> donateFood() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('${Environment.baseUrl}/donate');

    final body = jsonEncode({
      "email": widget.email,
      "location": locationController.text.trim(),
      "amount": amountController.text.trim(),
      "vegOrNonVeg": vegOrNonVeg,
      "foodItem": foodItemController.text.trim(),
      "status": "Pending",
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (responseData['code'] == 'SUCCESS') {
        FlutterToastr.show(
          responseData['message'] ?? "Donation successful!",
          context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.green,
        );

        setState(() {
          statusMessage = responseData['message'] ?? "Donation successful!";
        });
      } else {
        FlutterToastr.show(
          "Submission failed: ${responseData['message'] ?? 'Unknown error'}",
          context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      FlutterToastr.show(
        "Error: $e",
        context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor: Colors.red,
      );
    }
  }

  InputDecoration whiteInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Donate Food")),
      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/img_4.png"),
              fit: BoxFit.cover,
            ),
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Donate Food",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Email: ${widget.email}",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: locationController,
                      decoration: whiteInputDecoration("Location"),
                      style: TextStyle(color: Colors.white),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Location is required"
                          : null,
                    ),
                    TextFormField(
                      controller: amountController,
                      decoration: whiteInputDecoration("Amount (e.g. 5 packs)"),
                      style: TextStyle(color: Colors.white),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Amount is required"
                          : null,
                    ),
                    TextFormField(
                      controller: foodItemController,
                      decoration: whiteInputDecoration("Food Item"),
                      style: TextStyle(color: Colors.white),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? "Food item is required"
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.black87,
                      value: vegOrNonVeg,
                      onChanged: (value) {
                        setState(() {
                          vegOrNonVeg = value!;
                        });
                      },
                      items: ['Veg', 'NonVeg']
                          .map(
                            (e) => DropdownMenuItem(
                          child: Text(e,
                              style: TextStyle(color: Colors.white)),
                          value: e,
                        ),
                      )
                          .toList(),
                      decoration: whiteInputDecoration("Type of Food"),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: donateFood,
                      child: Text("Submit Donation"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white),
                        minimumSize: Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    if (statusMessage.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        statusMessage,
                        style: TextStyle(
                          color: statusMessage.contains("success")
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // DonorFormPage is center
        onTap: (index) {
          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IntroPage()),
              );
              break;
            case 1: // Settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
              break;
            case 2: // Logout
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
      ),
    );
  }
}
