import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
// Import the CardData model

// Model class for Card
class CardDatas {
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;

  CardDatas({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
  });
}

class ManageCards extends StatefulWidget {
  final List<CardDatas> savedCards;

  ManageCards({required this.savedCards});

  @override
  _ManageCardsState createState() => _ManageCardsState();
}

class _ManageCardsState extends State<ManageCards> {
  // Callback to handle card widget change (even if not needed, you can leave it empty for now)
  void onCreditCardWidgetChange(CreditCardBrand brand) {
    // Handle the card brand change if needed
    print('Card Brand Changed: $brand');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cards'),
      ),
      body: ListView.builder(
        itemCount: widget.savedCards.length,
        itemBuilder: (context, index) {
          CardDatas card = widget.savedCards[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: CreditCardWidget(
                cardNumber: card.cardNumber,
                expiryDate: card.expiryDate,
                cardHolderName: card.cardHolderName,
                cvvCode: card.cvvCode,
                showBackView: false, // Don't show the back view here
                bankName: 'My Bank',
                cardBgColor: Colors.blueAccent,
                obscureCardNumber: true,
                labelValidThru: 'VALID TILL',
                obscureCardCvv: true,
                isChipVisible: true,
                animationDuration: const Duration(milliseconds: 1000),
                // Pass the onCreditCardWidgetChange callback here
                onCreditCardWidgetChange: onCreditCardWidgetChange,
              ),
            ),
          );
        },
      ),
    );
  }
}