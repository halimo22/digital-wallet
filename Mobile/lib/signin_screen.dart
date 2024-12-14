import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import "home_screen.dart";

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Top Section with purple background and title
          Container(
            width: double.infinity,
            height: 125,
            decoration: BoxDecoration(
              color: Colors.purple[700],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 100),
          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  // Username or Phone Field
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username or phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the ForgotPasswordScreen
                        Navigator.pushNamed(context, '/forgotpassword');
                      },
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Sign-in Button
                  ElevatedButton(
                    onPressed: () {
                      final username = usernameController.text.trim();
                      final password = passwordController.text.trim();

                      // Check if username is not empty and phone number has 11 digits, password has at least 8 characters
                      if ((username.isNotEmpty || _isValidPhoneNumber(username)) && password.length >= 8) {
                        // Navigate to home screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      } else {
                        // Show error if validation fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid username/phone number and password (at least 8 characters).'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Redirect to Register (Sign-Up) Screen
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Colors.purple[700],
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signup');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to validate phone number (should be 11 digits)
  bool _isValidPhoneNumber(String phone) {
    // Only check if the phone contains exactly 11 digits
    return phone.length == 11 && RegExp(r'^\d{11}$').hasMatch(phone);
  }
}
