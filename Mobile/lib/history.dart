import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      // Replace with your backend API endpoint and valid email
      final url = Uri.parse('http://127.0.0.1:3000/get-transactions?email=s@gmail.com');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['transactions'] as List;

        setState(() {
          transactions = data.map((item) => Transaction.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load transactions. Status: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Transaction History"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
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
                      stateText = "Pending";
                      break;
                    case TransactionState.error:
                      stateIcon = Icons.error;
                      stateColor = Colors.red;
                      stateText = "Failed";
                      break;
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        isSent ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isSent ? Colors.red : Colors.green,
                      ),
                      title: Text(
                        "\$${transaction.amount.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${transaction.type} - ${transaction.contactName}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            transaction.cardNumber,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            formatDateTime(transaction.dateTime),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(stateIcon, color: stateColor),
                          SizedBox(width: 4),
                          Text(
                            stateText,
                            style: TextStyle(color: stateColor),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Performing an action with transactions..."),
                  ),
                );
              },
              child: Text("View Summary"),
            ),
          ],
        ),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
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
    final isSent = json['senderEmail'] != null;

    return Transaction(
      type: isSent ? "Sent" : "Received",
      amount: (json['amount'] ?? 0).toDouble(),
      cardNumber: json['cardNumber'] ?? "N/A",
      dateTime: DateTime.parse(json['createdAt']),
      state: json['status'] == "completed"
          ? TransactionState.completed
          : json['status'] == "pending"
          ? TransactionState.beingTransacted
          : TransactionState.error,
      contactName: isSent ? json['receiverEmail'] : json['senderEmail'] ?? "Unknown",
    );
  }
}

void main() => runApp(MaterialApp(home: HistoryScreen()));
