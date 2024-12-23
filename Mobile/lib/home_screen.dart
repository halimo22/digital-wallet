import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'send_screen.dart';
import 'receive_screen.dart';
import 'favorite_screen.dart';
import 'history.dart';
import 'rewards_screen.dart';
import 'notification_screen.dart';  // Import your Notification screen
import 'package:flutter/material.dart';

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

  // Notification flag
  bool hasNewNotifications = true; // Flag to indicate new notifications

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

  // Function to handle notification icon tap
  void navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()), // Navigate to the Notification Screen
    );
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
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),// Change the color here
            ),
            Spacer(),
            // Notification icon
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: navigateToNotifications, // Navigate when tapped
            ),
            if (hasNewNotifications)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Card Display
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
              Colors.pink[700]!,
            ),
          ),
          // Option Buttons
          Expanded(
            child: GridView(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              children: [
                _buildSquareButton(
                  icon: Icons.arrow_forward,
                  title: 'Send',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SendScreen()),
                    );
                  },
                ),
                _buildSquareButton(
                  icon: Icons.arrow_back,
                  title: 'Receive',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReceiveScreen()),
                    );
                  },
                ),
                _buildSquareButton(
                  icon: Icons.favorite,
                  title: 'Favourites',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FavoriteScreen()),
                    );
                  },
                ),
                _buildSquareButton(
                  icon: Icons.card_giftcard,
                  title: 'Cash/Rewards',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CashAndRewardsScreen())
                    );
                  },
                ),
                _buildSquareButton(
                  icon: Icons.credit_card,
                  title: 'My Cards',
                  onTap: () {
                    Navigator.pushNamed(context, '/managecards').then((value) {
                      if (value != null && value is Map<String, dynamic>) {
                        updateSelectedCard(value);
                      }
                    });
                  },
                ),
                _buildSquareButton(
                  icon: Icons.book,
                  title: 'History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String name, String cardType, String cardNumber, String balance, Color cardColor) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 45),
          Text(
            cardType,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28, // Fixed font size for better readability
            ),
          ),
          SizedBox(height: 35),
          Text(
            cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18, // Fixed font size for better readability
            ),
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                balance,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.0),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue[700], size: 40),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}