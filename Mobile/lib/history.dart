import 'package:flutter/material.dart';

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
}

class TransactionHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions = [
    Transaction(
      type: "Sent",
      amount: 150.75,
      cardNumber: "1234 5678 9012",
      dateTime: DateTime.now().subtract(Duration(hours: 1)),
      state: TransactionState.completed,
      contactName: "John Doe",
    ),
    Transaction(
      type: "Received",
      amount: 200.00,
      cardNumber: "2345 6789 0123",
      dateTime: DateTime.now().subtract(Duration(days: 1, hours: 3)),
      state: TransactionState.error,
      contactName: "Jane Smith",
    ),
    Transaction(
      type: "Sent",
      amount: 50.50,
      cardNumber: "3456 7890 1234",
      dateTime: DateTime.now().subtract(Duration(days: 2)),
      state: TransactionState.beingTransacted,
      contactName: "Alice Johnson",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
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
              stateIcon = Icons.error;
              stateColor = Colors.red;
              stateText = "Error";
              break;
          }

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
