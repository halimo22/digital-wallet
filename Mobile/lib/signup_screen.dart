import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String fullName='';
  String email='';
  String mobileNumber='';
  String password='';
  String dateOfBirth='';
  String userName='';
  int numErrors=0;

  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final Color _violetColor = Colors.purple[700]!;
  final Set<String> _usernames = {'user1', 'john'}; // Mock database for usernames

  void _register() async {
    if (_formKey.currentState!.validate() && isChecked) {
      // Collect form data
      final Map<String, dynamic> registrationData = {
        'fullName': _fullNameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'birthday': _dobController.text,
        'mobilePhone': _phoneController.text,
      };

      try {
        // Send a POST request to the API
        final response = await http.post(
          Uri.parse('http://localhost:3000/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(registrationData),
        );

        if (response.statusCode == 201) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful!')),
          );

          // Redirect to the sign-in screen
          Navigator.pushNamed(context, '/signin');
        } else {
          // Registration failed
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Registration failed')),
          );
        }
      } catch (error) {
        // Handle network or server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server. Please try again.')),
        );
      }
    } else if (!isChecked) {
      // Show error message for terms and conditions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please accept the terms and conditions.')),
      );
    } else {
      // Generic error message for validation failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields correctly.')),
      );
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required.';
      numErrors=numErrors+1;
    } else {userName=value;}
    return null;
  }

  String? _validateDob(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required.';
      numErrors=numErrors+1;
    }
    final dob = DateFormat('yyyy-MM-dd').parse(value);
    final today = DateTime.now();
    final age = today.year - dob.year - (today.month < dob.month || (today.month == dob.month && today.day < dob.day) ? 1 : 0);
    if (age < 18) {
      numErrors=numErrors+1;
      return 'You must be at least 18 years old.';
    } else {dateOfBirth=value;}
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 18 * 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: _violetColor,
        title: Text('Sign up'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  'Welcome to us,',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Hello there, create New account',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(
                      color: _violetColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required.';
                      numErrors=numErrors+1;
                    } else {fullName=value;}
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: _violetColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                  ),
                  validator: _validateUsername,
                ),
                SizedBox(height: 15),
                // Date of Birth Field
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: _violetColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: _violetColor),
                  ),
                  validator: _validateDob,
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 15),
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    labelStyle: TextStyle(
                      color: _violetColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required.';
                      numErrors=numErrors+1;
                    } else if (value.length != 11) {
                      numErrors=numErrors+1;
                      return 'Phone number must be 11 digits.';
                    } else {mobileNumber=value;}
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: _violetColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required.';
                      numErrors=numErrors+1;
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                      return 'Enter a valid email address.';
                      numErrors=numErrors+1;
                    } else {email=value;}
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: _violetColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      numErrors=numErrors+1;

                      return 'Password is required.';
                    } else if (value.length < 8) {
                      numErrors=numErrors+1;

                      return 'Password must be at least 8 characters long.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(
                      color: _violetColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _violetColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password.';
                      numErrors=numErrors+1;

                    } else if (value != _passwordController.text) {
                      numErrors=numErrors+1;
                      return 'Passwords do not match.';
                    } else {password=value;}
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Terms and Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                      activeColor: _violetColor,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'By creating an account you agree to our ',
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: _violetColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Register Button
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _violetColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Sign In Text
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: _violetColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if(numErrors==0) {

                                Navigator.pop(context);
                              }
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
      ),
    );
  }
}