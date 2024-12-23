import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(MaterialApp(home: HomeScreen()));


class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FavoriteAccountsScreen(),
    );
  }
}

class FavoriteAccount {
  final String name;
  final String accountNumber;
  final String profilePicture;

  FavoriteAccount({
    required this.name,
    required this.accountNumber,
    required this.profilePicture,
  });
}

class FavoriteAccountsScreen extends StatefulWidget {
  @override
  _FavoriteAccountsScreenState createState() => _FavoriteAccountsScreenState();
}

class _FavoriteAccountsScreenState extends State<FavoriteAccountsScreen> {
  final List<FavoriteAccount> favoriteAccounts = [
    FavoriteAccount(
      name: "John Doe",
      accountNumber: "1234 5678 9012",
      profilePicture: "https://via.placeholder.com/50",
    ),
    FavoriteAccount(
      name: "Jane Smith",
      accountNumber: "2345 6789 0123",
      profilePicture: "https://via.placeholder.com/50",
    ),
  ];

  void addToFavorites(FavoriteAccount account) {
    setState(() {
      favoriteAccounts.add(account);
    });
  }

  void removeFromFavorites(FavoriteAccount account) {
    setState(() {
      favoriteAccounts.remove(account);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Accounts'),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false, // Remove all previous routes
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: favoriteAccounts.length,
              itemBuilder: (context, index) {
                final account = favoriteAccounts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(account.profilePicture),
                  ),
                  title: Text(account.name),
                  subtitle: Text(account.accountNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          removeFromFavorites(account);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${account.name} removed from favorites'),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Send money to ${account.name}')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ContactsScreen(onAddToFavorites: addToFavorites),
                  ),
                );
              },
              child: Text('Add to Favorites'),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactsScreen extends StatelessWidget {
  final Function(FavoriteAccount) onAddToFavorites;

  ContactsScreen({required this.onAddToFavorites});

  final List<FavoriteAccount> contacts = [
    FavoriteAccount(
      name: "Alice Johnson",
      accountNumber: "3456 7890 1234",
      profilePicture: "https://via.placeholder.com/50",
    ),
    FavoriteAccount(
      name: "Bob Miller",
      accountNumber: "4567 8901 2345",
      profilePicture: "https://via.placeholder.com/50",
    ),
    FavoriteAccount(
      name: "Charlie Brown",
      accountNumber: "5678 9012 3456",
      profilePicture: "https://via.placeholder.com/50",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(contact.profilePicture),
            ),
            title: Text(contact.name),
            subtitle: Text(contact.accountNumber),
            trailing: IconButton(
              icon: Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                onAddToFavorites(contact);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${contact.name} added to favorites')),
                );
                Navigator.pop(context); // Return to the previous screen
              },
            ),
          );
        },
      ),
    );
  }
}
