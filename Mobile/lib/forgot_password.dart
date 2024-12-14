import 'package:flutter/material.dart';
import 'otp_screen.dart'; // Import the OtpScreen

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController _phoneController = TextEditingController();

  // Validate phone number to ensure it's exactly 11 digits
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    } else if (value.length != 11) {
      return 'Phone number must be 11 digits';
    }
    return null;
  }

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
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone number input section
            Text(
              'Type your phone number',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Number pad keyboard
              decoration: InputDecoration(
                hintText: 'Enter your phone no',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5), // Set the opacity to 50%
                ),
                border: OutlineInputBorder(),
              ),
              validator: _validatePhoneNumber,
            ),
            SizedBox(height: 20),
            Text(
              'We will text you a code to verify your phone number',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            // Send button
            ElevatedButton(
              onPressed: () {
                // Validate phone number and navigate to OTP screen
                if (_validatePhoneNumber(_phoneController.text) == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OtpScreen(phoneNumber: _phoneController.text)),
                  );
                } else {
                  // If phone number is invalid, show a snackbar message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid phone number')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
