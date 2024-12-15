import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_new_card.dart';
import 'favorite_screen.dart';
import 'history.dart';
import 'send_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  // Secure Storage instance
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // User data variables
  String userName = "";
  String userBalance = "\$0.00";
  List<dynamic> userCards = [];
  Map<String, dynamic>? selectedCard;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Retrieve saved credentials
      final email = await secureStorage.read(key: 'email');
      final password = await secureStorage.read(key: 'password');

      if (email == null || password == null) {
        // Redirect to login if credentials are missing
        Navigator.pushReplacementNamed(context, '/signin');
        return;
      }

      // Call the login API
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['user']['fullName'];
          userBalance = "\$${data['user']['balance'].toStringAsFixed(2)}";
          userCards = data['user']['cards'];
          selectedCard = userCards.isNotEmpty ? userCards[0] : null;
          isLoading = false;
        });
      } else {
        // Handle invalid credentials
        Navigator.pushReplacementNamed(context, '/signin');
      }
    } catch (error) {
      print('Error fetching user data: $error');
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  void updateSelectedCard(Map<String, dynamic> card) {
    setState(() {
      selectedCard = card;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Row(
          children: [
            Text(
              isLoading ? 'Loading...' : 'Hi, $userName',
              style: TextStyle(fontSize: 18),
            ),
            Spacer(),
            Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Swipeable Cards Section (PageView)
          Container(
            height: 250,
            margin: EdgeInsets.all(16.0),
            child: selectedCard == null
                ? Center(child: Text("No Cards Available"))
                : _buildCard(
              userName,
              selectedCard!['cardHolderName'],
              "**** ${selectedCard!['last4']}",
              userBalance,
              Colors.blue[700]!,
            ),
          ),
          // Options Column
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              children: [
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.send,
                  'Send',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SendScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.download,
                  'Receive',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReceiveScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.favorite,
                  'Favourites',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoriteScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildColumnItem(Icons.attach_money, 'Cash/Rewards', null),
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.credit_card,
                  'My Credit Card',
                      () {
                    Navigator.pushNamed(context, '/managecards').then((value) {
                      if (value != null && value is Map<String, dynamic>) {
                        updateSelectedCard(value);
                      }
                    });
                  },
                ),
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.book,
                  'History',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Bottom Navigation
          BottomNavigationBar(
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mail),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String name, String cardType, String cardNumber, String balance, Color cardColor) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            cardType,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            cardNumber,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                balance,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnItem(IconData icon, String title, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(icon, color: Colors.blue[700], size: 30),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
