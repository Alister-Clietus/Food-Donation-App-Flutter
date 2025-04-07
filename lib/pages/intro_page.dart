import 'package:flutter/material.dart';
import 'about_page.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/img.png',
              fit: BoxFit.cover,
            ),
          ),

          // Button at the top
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios, size: 18),
                label: Text(
                  "Go to the App",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
