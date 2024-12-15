import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart'; // Import your HomeScreen file

class CreditCardPage extends StatefulWidget {
  @override
  _CreditCardPageState createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  String cardNumber = '';
  String expiryDate = '';
  String cvvCode = '';
  String cardHolderName = ''; // Added for cardholder name input
  bool isCvvFocused = false;

  void onCreditCardWidgetChange(CreditCardBrand brand) {
    print('Card Brand Changed: $brand');
  }

  Future<void> saveCard() async {
    try {
      // Retrieve the logged-in user's email from secure storage
      final email = await secureStorage.read(key: 'email');

      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in. Please log in first.')),
        );
        return;
      }

      // Make API request to save the card
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/save-card'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'cardNumber': cardNumber,
          'cardHolderName': cardHolderName,
          'expiryDate': expiryDate,
        }),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Card saved successfully!')),
        );

        // Navigate back to HomeScreen and refresh it
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false, // Remove all previous routes
        );
      } else {
        // Show error message from the server
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorResponse['message'] ?? 'Failed to save card')),
        );
      }
    } catch (error) {
      print('Error saving card: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName, // Updated to reflect cardholder name
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: onCreditCardWidgetChange,
              bankName: 'My Bank',
              cardBgColor: Colors.black87,
              obscureCardNumber: true,
              labelValidThru: 'VALID THRU',
              obscureCardCvv: true,
              isChipVisible: true,
              animationDuration: const Duration(milliseconds: 1000),
              backgroundImage: 'assets/purple.jpg',
            ),
            const SizedBox(height: 30),
            CreditCardForm(
              formKey: formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              cardNumberValidator: (String? value) {
                if (value == null || value.isEmpty || value.length != 19) {
                  return 'Please enter a valid 16-digit card number';
                }
                return null;
              },
              expiryDateValidator: (String? value) {
                if (value == null || value.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                  return 'Enter expiry date in MM/YY format';
                }
                return null;
              },
              cvvValidator: (String? value) {
                if (value == null || value.isEmpty || value.length < 3 || value.length > 4) {
                  return 'Enter valid CVV (3-4 digits)';
                }
                return null;
              },
              cardHolderValidator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Enter the cardholder\'s name';
                }
                return null;
              },
              onCreditCardModelChange: (CreditCardModel data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cvvCode = data.cvvCode;
                  cardHolderName = data.cardHolderName; // Update cardholder name
                  isCvvFocused = data.isCvvFocused;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  saveCard();
                }
              },
              child: const Text('Save Card'),
            ),
          ],
        ),
      ),
    );
  }
}
