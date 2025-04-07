import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DonorFormPage extends StatefulWidget {
  final String email;

  DonorFormPage({required this.email});

  @override
  _DonorFormPageState createState() => _DonorFormPageState();
}

class _DonorFormPageState extends State<DonorFormPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController foodItemController = TextEditingController();
  String vegOrNonVeg = 'Veg';
  String statusMessage = '';

  Future<void> donateFood() async {
    final url = Uri.parse('http://192.168.29.251:8080/api/fooddonation/donate');

    final body = jsonEncode({
      "email": widget.email,
      "location": locationController.text,
      "amount": amountController.text,
      "vegOrNonVeg": vegOrNonVeg,
      "foodItem": foodItemController.text,
      "status": "Pending",
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['code'] == 'SUCCESS') {
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
                  TextField(
                    controller: locationController,
                    decoration: whiteInputDecoration("Location"),
                    style: TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: whiteInputDecoration("Amount (e.g. 5 packs)"),
                    style: TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: foodItemController,
                    decoration: whiteInputDecoration("Food Item"),
                    style: TextStyle(color: Colors.white),
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
                        .map((e) => DropdownMenuItem(
                      child: Text(e, style: TextStyle(color: Colors.white)),
                      value: e,
                    ))
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
    );
  }
}
