import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodDonationPage extends StatefulWidget {
  @override
  _FoodDonationPageState createState() => _FoodDonationPageState();
}

class _FoodDonationPageState extends State<FoodDonationPage> {
  List<dynamic> foodList = [];

  @override
  void initState() {
    super.initState();
    fetchFoodDonations();
  }

  Future<void> fetchFoodDonations() async {
    final response = await http.get(Uri.parse('http://192.168.29.251:8080/api/fooddonation/food'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['code'] == 'SUCCESS') {
        setState(() {
          foodList = jsonResponse['details']['aaData'];
        });
      }
    } else {
      print('Failed to fetch food data');
    }
  }

  void bookFood(int index) {
    setState(() {
      foodList[index]['status'] = 'BOOKED';
    });
    // You can also send a booking request to backend here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Food Donations')),
      body: ListView.builder(
        itemCount: foodList.length,
        itemBuilder: (context, index) {
          final food = foodList[index];
          return Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              title: Text(food['foodItem'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location: ${food['location'] ?? "N/A"}'),
                  Text('Status: ${food['status']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: food['status'] == 'BOOKED'
                    ? null
                    : () => bookFood(index),
                child: Text(food['status'] == 'BOOKED' ? 'BOOKED' : 'BOOK'),
              ),
            ),
          );
        },
      ),
    );
  }
}
