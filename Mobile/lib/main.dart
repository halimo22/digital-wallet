import 'package:flutter/material.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'forgot_password.dart';
import 'flutter_credit_card.dart';  // Import flutter_credit_card.dart
import 'manage_cards.dart';  // Import ManageCardsScreen
import 'add_new_card.dart';  // Import AddNewCardScreen
import 'favorite_screen.dart';
import 'history.dart';
import 'transfer_screen.dart';
// Import the CardData model

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => WelcomeScreen(), // Welcome or Splash Screen
        '/signin': (context) => SignInScreen(), // Sign-In Screen
        '/signup': (context) => SignUpScreen(), // Sign-Up Screen
        '/home': (context) => HomeScreen(), // Main Home Screen
        '/forgotpassword': (context) => ForgotPasswordScreen(), // Forgot Password Screen
        '/creditcard': (context) => AddNewCardScreen(), // AddNewCardScreen for card entry
        '/favorite': (context) => FavoriteScreen(), // Favorite Screen
        '/history': (context) => HistoryScreen(), // History Screen
        '/transfer': (context) => TransferScreen(), // Transfer Screen
        '/managecards': (context) {
          final savedCards = ModalRoute.of(context)!.settings.arguments as List<CardDatas>;
          return ManageCards(savedCards: savedCards);  // Pass savedCards to ManageCards screen
        },
      },
    );
  }
}
