import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isConnected = false;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    checkForSavedCredentials();

  }

  Future<void> checkForSavedCredentials() async {
    Map<String, String?> credentials = await getCredentials();
    if (credentials['email'] != null && credentials['password'] != null) {
      // Perform auto-login logic here
      Navigator.pushNamed(context, '/home');
    }
  }
  Future<void> _checkConnection() async {
    const String apiUrl = 'http://127.0.0.1:3000/api/connectivity'; // Replace with your backend URL

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data['message']); // Server is online
        setState(() {
          isConnected = true;
          isChecking = false;
        });
      } else {
        setState(() {
          isConnected = false;
          isChecking = false;
        });
      }
    } catch (e) {
      print('Error during connectivity check: $e');
      setState(() {
        isConnected = false;
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[700],
      body: Center(
        child: isChecking
            ? CircularProgressIndicator(
          color: Colors.white,
        )
            : isConnected
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Mahfazty',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.purple[700],
                  fontSize: 18,
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Unable to connect to the server.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.purple[700],
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
