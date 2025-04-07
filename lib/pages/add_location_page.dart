import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/environment.dart';

class AddLocationPage extends StatefulWidget {
  final String email;
  final int foodId;

  AddLocationPage({required this.email, required this.foodId});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  late TextEditingController _emailController;
  late TextEditingController _foodIdController;
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _foodIdController = TextEditingController(text: widget.foodId.toString());
  }

  Future<void> submitLocation() async {
    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.parse('${Environment.baseUrl}/volunteerdetails');
    final body = jsonEncode({
      "email": _emailController.text,
      "foodid": widget.foodId.toString(),
      "location": _locationController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      setState(() {
        _isSubmitting = false;
      });

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse["code"] == "SUCCESS") {
        FlutterToastr.show(
          jsonResponse["message"] ?? "Location added!",
          context,
          duration: FlutterToastr.lengthShort,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        FlutterToastr.show(
          jsonResponse["message"] ?? "Unexpected response",
          context,
          duration: FlutterToastr.lengthShort,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      FlutterToastr.show(
        "Error submitting location: $e",
        context,
        duration: FlutterToastr.lengthShort,
        position: FlutterToastr.bottom,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/img.png'), // Ensure it's in pubspec.yaml
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Location",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _foodIdController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Food ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Enter location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : submitLocation,
                      child: Text(_isSubmitting ? "Submitting..." : "Submit"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
