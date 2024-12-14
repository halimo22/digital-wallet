import 'package:flutter/material.dart';

void main() {
  runApp(TransferApp());
}

class TransferApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TransferScreen(),
    );
  }
}

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final List<String> cards = ["1234 5678 9012", "2345 6789 0123", "3456 7890 1234"];
  String? selectedCard;
  double? transferAmount;

  final List<Contact> favoriteContacts = [
    Contact(name: "John Doe", accountNumber: "1234 5678 9012", profilePicture: "https://via.placeholder.com/50"),
    Contact(name: "Jane Smith", accountNumber: "2345 6789 0123", profilePicture: "https://via.placeholder.com/50"),
  ];

  final List<Contact> allContacts = [
    Contact(name: "Alice Johnson", accountNumber: "3456 7890 1234", profilePicture: "https://via.placeholder.com/50"),
    Contact(name: "Bob Miller", accountNumber: "4567 8901 2345", profilePicture: "https://via.placeholder.com/50"),
    Contact(name: "Charlie Brown", accountNumber: "5678 9012 3456", profilePicture: "https://via.placeholder.com/50"),
  ];

  Contact? selectedContact;
  String? enteredAccountNumber;

  void submitTransfer() {
    if (selectedCard == null || transferAmount == null || (selectedContact == null && enteredAccountNumber == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields!")),
      );
      return;
    }

    final recipient = selectedContact != null ? selectedContact!.name : enteredAccountNumber;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Transfer successful to $recipient!")),
    );

    setState(() {
      selectedCard = null;
      transferAmount = null;
      selectedContact = null;
      enteredAccountNumber = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer Money"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Card
            Text("Select Card", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedCard,
              hint: Text("Choose a card"),
              items: cards.map((card) {
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
            SizedBox(height: 20),

            // Step 2: Enter Amount
            Text("Enter Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter amount to transfer",
              ),
              onChanged: (value) {
                setState(() {
                  transferAmount = double.tryParse(value);
                });
              },
            ),
            SizedBox(height: 20),

            // Step 3: Choose or Enter Recipient
            Text("Choose or Enter Recipient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ElevatedButton(
              onPressed: () async {
                final Contact? contact = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipientSelectionScreen(
                      favoriteContacts: favoriteContacts,
                      allContacts: allContacts,
                    ),
                  ),
                );
                if (contact != null) {
                  setState(() {
                    selectedContact = contact;
                    enteredAccountNumber = null;
                  });
                }
              },
              child: Text(selectedContact == null ? "Select from Contacts" : selectedContact!.name),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Or enter account number manually",
              ),
              onChanged: (value) {
                setState(() {
                  enteredAccountNumber = value;
                  selectedContact = null;
                });
              },
            ),
            Spacer(),

            // Submit Transfer Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitTransfer,
                child: Text("Submit Transfer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Contact {
  final String name;
  final String accountNumber;
  final String profilePicture;

  Contact({
    required this.name,
    required this.accountNumber,
    required this.profilePicture,
  });
}

class RecipientSelectionScreen extends StatelessWidget {
  final List<Contact> favoriteContacts;
  final List<Contact> allContacts;

  RecipientSelectionScreen({required this.favoriteContacts, required this.allContacts});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Select Recipient"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Favorites"),
              Tab(text: "All Contacts"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Favorites Tab
            ListView.builder(
              itemCount: favoriteContacts.length,
              itemBuilder: (context, index) {
                final contact = favoriteContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(contact.profilePicture),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.accountNumber),
                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                );
              },
            ),
            // All Contacts Tab
            ListView.builder(
              itemCount: allContacts.length,
              itemBuilder: (context, index) {
                final contact = allContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(contact.profilePicture),
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.accountNumber),
                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}