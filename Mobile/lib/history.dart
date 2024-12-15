import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(HistoryScreen());
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TransactionHistoryScreen(),
    );
  }
}

enum TransactionState { completed, beingTransacted, error }

class Transaction {
  final String type; // "Sent" or "Received"
  final double amount;
  final String cardNumber;
  final DateTime dateTime;
  final TransactionState state;
  final String contactName; // Name of sender or recipient

  Transaction({
    required this.type,
    required this.amount,
    required this.cardNumber,
    required this.dateTime,
    required this.state,
    required this.contactName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: json['type'], // Sent or Received
      amount: json['amount'].toDouble(),
      cardNumber: json['cardNumber'] ?? '**** **** **** ****',
      dateTime: DateTime.parse(json['date']),
      state: TransactionState.values.firstWhere(
              (e) => e.toString().split('.').last == json['state'],
          orElse: () => TransactionState.error),
      contactName: json['contactName'],
    );
  }
}

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final List<Transaction> transactions = [];
  final _storage = const FlutterSecureStorage();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      // Get email from secure storage
      final email = await _storage.read(key: 'email');
      if (email == null) {
        throw Exception('Email not found in secure storage');
      }

      // Fetch transactions from the API
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/get-transactions?email=$email'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['transactions'];
        setState(() {
          transactions.addAll(data.map((json) => Transaction.fromJson(json)));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? Center(child: Text('No transactions found'))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isSent = transaction.type == "Sent";

          // Determine status icon, color, and text
          IconData stateIcon;
          Color stateColor;
          String stateText;

          switch (transaction.state) {
            case TransactionState.completed:
              stateIcon = Icons.check_circle;
              stateColor = Colors.green;
              stateText = "Completed";
              break;
            case TransactionState.beingTransacted:
              stateIcon = Icons.hourglass_empty;
              stateColor = Colors.orange;
              stateText = "Being Transacted";
              break;
            case TransactionState.error:
            default:
              stateIcon = Icons.error;
              stateColor = Colors.red;
              stateText = "Error";
              break;
          }

          return Card(
            margin:
            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(
                isSent ? Icons.arrow_upward : Icons.arrow_downward,
                color: isSent ? Colors.red : Colors.green,
              ),
              title: Text(
                "${transaction.type} - \$${transaction.amount.toStringAsFixed(2)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSent
                        ? "Recipient: ${transaction.contactName}"
                        : "Sender: ${transaction.contactName}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    maskCardNumber(transaction.cardNumber),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    formatDateTime(transaction.dateTime),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      Icon(stateIcon, color: stateColor, size: 16),
                      SizedBox(width: 5),
                      Text(
                        stateText,
                        style: TextStyle(color: stateColor),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String maskCardNumber(String cardNumber) {
    List<String> parts = cardNumber.split(' ');
    if (parts.length < 3) return cardNumber; // Fallback for unexpected format

    return "${parts[0]} **** **** ${parts.last}";
  }
}
