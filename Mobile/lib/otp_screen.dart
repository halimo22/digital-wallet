import 'package:flutter/material.dart';
import 'change_password.dart'; // Import the ChangePasswordScreen

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  OtpScreen({required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone number display
            Text(
              'We sent a code to your phone number: ${widget.phoneNumber}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // OTP input section
            Text(
              'Enter the code sent to your phone',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number, // For numeric code
              decoration: InputDecoration(
                hintText: 'Enter verification code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // Continue button to proceed with password change
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to ChangePasswordScreen after clicking Continue
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
