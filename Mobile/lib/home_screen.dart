import 'package:flutter/material.dart';
import 'add_new_card.dart'; // Adjust the path if the file is in a different directory
import 'favorite_screen.dart';
import 'history.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller to manage PageView
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: Row(
          children: [
            Text('Hi, Push Puttichai', style: TextStyle(fontSize: 18)),
            Spacer(),
            Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
      body: Column(
        children: [
          // Swipeable Cards Section (PageView)
          Container(
            height: 250, // Card height
            margin: EdgeInsets.all(16.0),
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              children: [
                _buildCard(
                  'John Smith',
                  'Amazon Platinum',
                  '4756 **** 9018',
                  '\$3,469.52',
                  Colors.blue[700]!,
                ),
                _buildCard(
                  'Jane Doe',
                  'Visa Gold',
                  '3456 **** 1234',
                  '\$1,239.85',
                  Colors.green[700]!,
                ),
                _buildCard(
                  'Mike Tyson',
                  'MasterCard Black',
                  '8945 **** 6789',
                  '\$5,100.23',
                  Colors.red[700]!,
                ),
              ],
            ),
          ),
          // Options Column
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              children: [
                //_buildColumnItem(Icons.account_balance_wallet, 'Account info', null),
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.compare_arrows,
                  'Transfer',
                      (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TransferScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildColumnItem(
                  Icons.favorite,
                  'Favourites',
                      (){
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddNewCardScreen()),
                    );
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
                size: 80, // Increased size for the credit card icon
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
              offset: Offset(0, 3), // Shadow position
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
