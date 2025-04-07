import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/environment.dart';

class VolunteerLocationsPage extends StatefulWidget {
  @override
  _VolunteerLocationsPageState createState() => _VolunteerLocationsPageState();
}

class _VolunteerLocationsPageState extends State<VolunteerLocationsPage> {
  List<dynamic> locations = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse('${Environment.baseUrl}/volunteer/locations'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['code'] == 'SUCCESS') {
        setState(() {
          locations = jsonResponse['details']['aaData'];
        });
      }
    } else {
      print('Failed to load locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Volunteer Locations")),
      body: locations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final loc = locations[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Food ID: ${loc['foodId'] ?? 'N/A'}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text("Address: ${loc['address'] ?? 'No address'}"),
                    ],
                  ),
                ),
                Icon(Icons.location_on, color: Colors.redAccent),
              ],
            ),
          );
        },
      ),
    );
  }
}
