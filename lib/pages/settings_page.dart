import 'package:flutter/material.dart';
import 'intro_page.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Home"),
            onTap: () => _navigateTo(context, IntroPage()),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () => _logout(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Food Donation App',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 YourAppName',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
            subtitle: Text("English"),
            onTap: () {
              // Later: Show language picker
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Language setting coming soon!")),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text("Theme"),
            subtitle: Text("Light"),
            onTap: () {
              // Later: Add theme toggle
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Theme toggle coming soon!")),
              );
            },
          ),
        ],
      ),
    );
  }
}
