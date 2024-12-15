import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'flutter_credit_card.dart'; // Import your flutter_credit_card page here

class ManageCardsScreen extends StatefulWidget {
  @override
  _ManageCardsScreenState createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends State<ManageCardsScreen> {
  final _secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> cards = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCards();
  }

  Future<String?> getEmail() async {
    try {
      return await _secureStorage.read(key: "email");
    } catch (e) {
      debugPrint("Error fetching email from storage: $e");
      return null;
    }
  }

  Future<void> fetchCards() async {
    setState(() {
      isLoading = true;
    });

    try {
      final email = await getEmail();
      if (email == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found in secure storage')),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/get-cards?email=$email'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          cards = List<Map<String, dynamic>>.from(responseData['cards']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch cards: ${response.statusCode}')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void onCardSelect(Map<String, dynamic> card) {
    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cards'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: () => onCardSelect(card),
                    child: Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Card Holder: ${card['cardHolderName']}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  '**** **** **** ${card['last4']}',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Expiry: ${card['expiryDate']}',
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreditCardPage(), // Navigate to Credit Card Page
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
                'Add New Card',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
