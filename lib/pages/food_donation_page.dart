import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_toastr/flutter_toastr.dart'; // Toast import

import '../config/environment.dart';
import 'intro_page.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'add_location_page.dart';
import 'volunteer_locations_page.dart';

class FoodDonationPage extends StatefulWidget {
  @override
  _FoodDonationPageState createState() => _FoodDonationPageState();
}

class _FoodDonationPageState extends State<FoodDonationPage> {
  List<dynamic> foodList = [];

  int bookedCount = 0;
  int pendingCount = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFoodDonations();
  }

  Future<void> fetchFoodDonations() async {
    final response = await http.get(Uri.parse('${Environment.baseUrl}/food'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['code'] == 'SUCCESS') {
        List<dynamic> data = jsonResponse['details']['aaData'];
        setState(() {
          foodList = data;
          bookedCount = data.where((item) => item['status'] == 'BOOKED').length;
          pendingCount = data.where((item) => item['status'] != 'BOOKED').length;
        });
      }
    } else {
      print('Failed to fetch food data');
    }
  }

  Future<void> bookFood(int index) async {
    final foodId = foodList[index]['foodId'];

    final response = await http.put(
      Uri.parse('${Environment.baseUrl}/updateDonationStatus/$foodId'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['code'] == 'SUCCESS') {
        setState(() {
          foodList[index]['status'] = 'BOOKED';
          bookedCount += 1;
          pendingCount -= 1;
        });

        FlutterToastr.show(
          "Donation status updated to Booked.",
          context,
          duration: FlutterToastr.lengthShort,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.green,
        );
      } else {
        FlutterToastr.show(
          "Failed to book donation.",
          context,
          duration: FlutterToastr.lengthShort,
          position: FlutterToastr.bottom,
          backgroundColor: Colors.red,
        );
      }
    } else {
      FlutterToastr.show(
        "Error: Could not update donation status.",
        context,
        duration: FlutterToastr.lengthShort,
        position: FlutterToastr.bottom,
        backgroundColor: Colors.red,
      );
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

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
  }

  Widget buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget buildLocationCard() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VolunteerLocationsPage()),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            border: Border.all(color: Colors.blue, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(height: 6),
              Text("Loc", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Food Donations')),
      body: Column(
        children: [
          SizedBox(height: 12),
          Row(
            children: [
              SizedBox(width: 12),
              buildStatCard("BOOKED", bookedCount, Colors.green),
              buildStatCard("PENDING", pendingCount, Colors.orange),
              buildLocationCard(),
              SizedBox(width: 12),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final food = foodList[index];
                final isBooked = food['status'] == 'BOOKED';
                final hasLocation = food['location'] != null && food['location'].toString().isNotEmpty;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isBooked ? Colors.greenAccent.shade100 : Colors.orangeAccent.shade100,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      food['foodItem'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('Location: ${food['location'] ?? "N/A"}'),
                        Text('Food ID: ${food['foodId']}'),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: isBooked ? null : () => bookFood(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBooked ? Colors.grey : Colors.green,
                              ),
                              child: Text(isBooked ? 'BOOKED' : 'BOOK'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final success = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddLocationPage(
                                      email: "volunteer@example.com", // Replace with actual user email
                                      foodId: food['foodId'],
                                    ),
                                  ),
                                );
                                if (success == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Location added successfully")),
                                  );
                                  fetchFoodDonations(); // Refresh the list
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: Text(hasLocation ? "Update Location" : "Add Location"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
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
