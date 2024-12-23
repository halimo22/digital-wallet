import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNotificationItem(
              'New Reward Available',
              'You have earned a new reward! Check it out now.',
            ),
            _buildNotificationItem(
              'Account Update',
              'Your account information has been successfully updated.',
            ),
            _buildNotificationItem(
              'Card Expiry Reminder',
              'Your card is set to expire in 7 days. Please update your details.',
            ),
            // Add more notifications as needed
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        leading: Icon(Icons.notifications, color: Colors.blue),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle notification tap, navigate to appropriate screen if needed
        },
      ),
    );
  }
}
