import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReceiveScreen extends StatefulWidget {
  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  TextEditingController amountController = TextEditingController();
  String base64QRCode = ''; // Holds the Base64-encoded QR code from the backend
  bool isLoading = false;

  Future<void> fetchQRCode(String amount) async {
    setState(() {
      isLoading = true;
    });

    try {
      const String apiUrl = "http://127.0.0.1:3000/request-money";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "receiverEmail": "receiver@example.com", // Replace with dynamic user email
          "amount": double.parse(amount),
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        setState(() {
          base64QRCode = responseData['qrCode'].split(',').last; // Extract Base64 data
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch QR Code: ${response.body}")),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Receive Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Amount",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter amount",
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String amount = amountController.text.trim();
                  if (amount.isEmpty || double.tryParse(amount) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid amount")),
                    );
                  } else {
                    fetchQRCode(amount);
                  }
                },
                child: Text("Fetch QR Code"),
              ),
            ),
            SizedBox(height: 24),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading && base64QRCode.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Scan this QR Code to Receive Money",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Image.memory(
                      base64Decode(base64QRCode),
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: ReceiveScreen()));
