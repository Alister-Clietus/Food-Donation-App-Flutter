import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserVerificationPage extends StatefulWidget {
  @override
  _UserVerificationPageState createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  List<dynamic> allUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('http://192.168.29.251:8080/api/fooddonation/users');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'SUCCESS') {
        setState(() {
          allUsers = data['details']['aaData'];
          isLoading = false;
        });
      } else {
        FlutterToastr.show("Failed to fetch users.", context,
            duration: FlutterToastr.lengthLong,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      FlutterToastr.show("Error: $e", context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red);
    }
  }

  Future<void> verifyUser(String email) async {
    final url = Uri.parse('http://192.168.29.251:8080/api/fooddonation/updateStatus/$email');

    try {
      final response = await http.put(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'SUCCESS') {
        FlutterToastr.show("User Verified!", context,
            duration: FlutterToastr.lengthShort,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.green);
        fetchUsers(); // refresh list
      } else {
        FlutterToastr.show("Verification failed!", context,
            duration: FlutterToastr.lengthLong,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      FlutterToastr.show("Error: $e", context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red);
    }
  }

  Future<void> deleteUser(String email) async {
    final url = Uri.parse('http://192.168.29.251:8080/api/fooddonation/deleteUser/$email');

    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'SUCCESS') {
        FlutterToastr.show(data['message'], context,
            duration: FlutterToastr.lengthShort,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.green);
        fetchUsers(); // refresh list
      } else {
        FlutterToastr.show("Deletion failed!", context,
            duration: FlutterToastr.lengthLong,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.red);
      }
    } catch (e) {
      FlutterToastr.show("Error: $e", context,
          duration: FlutterToastr.lengthLong,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red);
    }
  }

  Widget buildUserCard(Map<String, dynamic> user) {
    bool isVerified = user['status'] == 'VERIFY';

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user['name']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Email: ${user['email']}"),
            Text("Role: ${user['role']}"),
            Text("Phone: ${user['phoneNumber']}"),
            Text("Gender: ${user['gender']}"),
            Text("Address: ${user['address']}"),
            Text("Status: ${user['status']}"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: isVerified ? null : () => verifyUser(user['email']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? Colors.grey : Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(isVerified ? "Verified" : "Verify"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => deleteUser(user['email']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Verification")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : allUsers.isEmpty
          ? Center(child: Text("No users found."))
          : ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          return buildUserCard(allUsers[index]);
        },
      ),
    );
  }
}
