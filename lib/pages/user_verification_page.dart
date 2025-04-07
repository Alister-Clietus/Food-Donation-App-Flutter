import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/environment.dart';
import 'intro_page.dart';
import 'login_page.dart';
import 'settings_page.dart';

class UserVerificationPage extends StatefulWidget {
  @override
  _UserVerificationPageState createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  List<dynamic> allUsers = [];
  bool isLoading = true;
  int _currentIndex = 0;

  int donorCount = 0;
  int adminCount = 0;
  int volunteerCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('${Environment.baseUrl}/users');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'SUCCESS') {
        List<dynamic> users = data['details']['aaData'];
        setState(() {
          allUsers = users;
          donorCount = users.where((u) => u['role'] == 'Donor').length;
          adminCount = users.where((u) => u['role'] == 'Admin').length;
          volunteerCount = users.where((u) => u['role'] == 'VOLUNTEER').length;
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
    final url = Uri.parse('${Environment.baseUrl}/updateStatus/$email');
    try {
      final response = await http.put(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'SUCCESS') {
        FlutterToastr.show("User Verified!", context,
            duration: FlutterToastr.lengthShort,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.green);
        fetchUsers();
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
    final url = Uri.parse('${Environment.baseUrl}/deleteUser/$email');
    try {
      final response = await http.delete(url);
      final data = jsonDecode(response.body);

      if (data['code'] == 'SUCCESS') {
        FlutterToastr.show(data['message'], context,
            duration: FlutterToastr.lengthShort,
            position: FlutterToastr.bottom,
            backgroundColor: Colors.green);
        fetchUsers();
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

    Color cardColor;
    switch (user['role']) {
      case 'Admin':
        cardColor = Colors.lightBlue.shade50;
        break;
      case 'Donor':
        cardColor = Colors.orange.shade50;
        break;
      case 'VOLUNTEER':
        cardColor = Colors.green.shade50;
        break;
      default:
        cardColor = Colors.white;
    }

    return Card(
      color: cardColor,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name, Gender, Verify
            Row(
              children: [
                Expanded(flex: 2, child: Text(user['name'], style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(user['gender'] ?? '')),
                ElevatedButton(
                  onPressed: isVerified ? null : () => verifyUser(user['email']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? Colors.grey : Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(isVerified ? "Verified" : "Verify"),
                ),
              ],
            ),

            SizedBox(height: 4),

            // Row 2: Email
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(user['email'], style: TextStyle(color: Colors.grey[800])),
            ),

            // Row 3: Address, Role, Delete
            Row(
              children: [
                Expanded(flex: 3, child: Text(user['address'], overflow: TextOverflow.ellipsis)),
                Expanded(flex: 2, child: Text(user['role'])),
                ElevatedButton(
                  onPressed: () => deleteUser(user['email']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildStatCard("Donors", donorCount, Colors.orange),
          buildStatCard("Admins", adminCount, Colors.blue),
          buildStatCard("Volu", volunteerCount, Colors.green),
        ],
      ),
    );
  }

  Widget buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => IntroPage()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsPage()));
    } else if (index == 2) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
      );
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Verification")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : allUsers.isEmpty
          ? Center(child: Text("No users found."))
          : Column(
        children: [
          buildStatsRow(),
          Expanded(
            child: ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                return buildUserCard(allUsers[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
      ),
    );
  }
}
