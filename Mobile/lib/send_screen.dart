import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_code_tools/qr_code_tools.dart'; // For decoding QR codes
import 'dart:convert';
import 'dart:typed_data'; // For web-compatible image handling
import 'package:http/http.dart' as http;

class SendScreen extends StatefulWidget {
  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String? selectedCard; // Selected card from the dropdown
  String scannedQRCode = ''; // Holds the scanned QR Code data
  Uint8List? selectedImageBytes; // Holds the uploaded image bytes (web-compatible)
  String extractedTransactionId = ''; // Transaction ID from QR code
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage(); // Secure Storage instance

  List<String> cardList = []; // Fetched card list
  bool isLoading = false;
  String? userEmail; // User email retrieved from Secure Storage

  final String baseUrl = "http://127.0.0.1:3000"; // Backend base URL

  @override
  void initState() {
    super.initState();
    fetchUserEmailAndCards();
  }

  // Fetch user email and saved cards from the backend
  Future<void> fetchUserEmailAndCards() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Retrieve email from secure storage
      userEmail = await _secureStorage.read(key: 'email');

      if (userEmail == null) {
        throw Exception("User email not found. Please log in.");
      }

      // Fetch saved cards
      final response = await http.get(
        Uri.parse("$baseUrl/get-cards?email=$userEmail"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cardList = data['cards']
              .map<String>((card) =>
          "${card['cardHolderName']} **** ${card['last4']}")
              .toList();
        });
      } else {
        throw Exception("Failed to fetch cards: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Decode QR code from the uploaded image bytes
  Future<void> decodeQRCodeFromBytes(Uint8List bytes) async {
    try {
      final result = await QrCodeToolsPlugin.decodeFrom(Uint8List.fromList(bytes) as String);
      setState(() {
        extractedTransactionId = result!;
      });
    } catch (e) {
      setState(() {
        extractedTransactionId = "Failed to decode QR code.";
      });
      print("QR Code Decoding Error: $e");
    }
  }

  // Pick image from gallery and read it as bytes
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes(); // Read as bytes for web
        setState(() {
          selectedImageBytes = bytes;
        });

        // Decode the QR code immediately after selecting the image
        await decodeQRCodeFromBytes(bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  // Send money via `complete-transaction` API
  Future<void> completeTransaction() async {
    if (userEmail == null ||
        selectedCard == null ||
        extractedTransactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a card, ensure user email is set, and provide a valid transaction ID.")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/complete-transaction"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "transactionId": extractedTransactionId, // Use extracted transaction ID
          "senderEmail": userEmail, // User email as sender
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction completed successfully!")),
        );
      } else {
        throw Exception("Transaction failed: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error completing transaction: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Send Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a Card",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              hint: Text("Choose a card"),
              value: selectedCard,
              items: cardList.map((card) {
                return DropdownMenuItem(
                  value: card,
                  child: Text(card),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCard = value;
                });
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Upload Photo"),
                  onPressed: pickImageFromGallery,
                ),
              ],
            ),
            SizedBox(height: 24),
            if (selectedImageBytes != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    "Uploaded Image:",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Image.memory(
                    selectedImageBytes!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ],
              )
            else
              Text("No image uploaded."),
            if (extractedTransactionId.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    "Extracted Transaction ID:",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    extractedTransactionId,
                    style:
                    TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
              child: Text("Send Money"),
              onPressed: selectedCard != null &&
                  extractedTransactionId.isNotEmpty
                  ? completeTransaction
                  : null, // Disable if no card or transaction ID
            ),
          ],
        ),
      ),
    );
  }
}
