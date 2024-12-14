import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Credit Card',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreditCardPage(),
    );
  }
}

class CreditCardPage extends StatefulWidget {
  @override
  _CreditCardPageState createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  void onCreditCardWidgetChange(CreditCardBrand brand) {
    print('Card Brand Changed: $brand');
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
              cardHolderName: 'CARDHOLDER', // Static cardholder text
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
              backgroundImage: 'assets/images/purple.jpg',
            ),
            const SizedBox(height: 30),
            CreditCardForm(
              formKey: formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: '', // Leave this empty since we're not collecting it
              cvvCode: cvvCode,
              cardNumberValidator: (String? value) {
                if (value == null || value.isEmpty || value.length != 16) {
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
              onCreditCardModelChange: (CreditCardModel data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cvvCode = data.cvvCode;
                  isCvvFocused = data.isCvvFocused;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  print("Card Saved!");
                  formKey.currentState!.reset();
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