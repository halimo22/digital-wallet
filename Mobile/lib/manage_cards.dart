import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  @override
  _ManageCardsState createState() => _ManageCardsState();
}

class _ManageCardsState extends State<ManageCards> {
  // Secure storage instance
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // List to hold fetched cards
  List<CardDatas> savedCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<void> fetchCards() async {
    try {
      // Retrieve saved email
      final email = await secureStorage.read(key: 'email');

      if (email == null) {
        // Handle missing email (e.g., redirect to login)
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // Call the get-cards API
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/get-cards?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Map the cards to the CardDatas model
        List<CardDatas> fetchedCards = (data['cards'] as List).map((card) {
          return CardDatas(
            cardNumber: "**** **** **** ${card['last4']}",
            expiryDate: card['expiryDate'],
            cardHolderName: card['cardHolderName'],
            cvvCode: '', // CVV won't be available via API for security
          );
        }).toList();

        setState(() {
          savedCards = fetchedCards;
          isLoading = false;
        });
      } else {
        print('Failed to fetch cards: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching cards: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedCards.isEmpty
          ? Center(child: Text('No cards found.'))
          : ListView.builder(
        itemCount: savedCards.length,
        itemBuilder: (context, index) {
          CardDatas card = savedCards[index];

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
