import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart'; // Import for Credit Card UI
import 'flutter_credit_card.dart'; // Import your existing flutter_credit_card.dart screen

class AddNewCardScreen extends StatefulWidget {
  @override
  _AddNewCardScreenState createState() => _AddNewCardScreenState(); // Correct state reference
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  // State variables to store card information
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  // Function to handle Credit Card Widget update
  void onCreditCardModelChange(CreditCardModel data) {
    setState(() {
      cardNumber = data.cardNumber;
      expiryDate = data.expiryDate;
      cardHolderName = data.cardHolderName;
      cvvCode = data.cvvCode;
      isCvvFocused = data.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Preview
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused, // Show the CVV side if focused
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
              cardBgColor: Colors.blue,
              labelCardHolder: 'Cardholder',
              obscureCardNumber: false,
              obscureCardCvv: true,
            ),
            const SizedBox(height: 20),
            // Add Card Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreditCardPage(), // Navigate to flutter_credit_card.dart
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Add Card',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
