import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'forgot_password.dart';
import 'flutter_credit_card.dart'; // Import flutter_credit_card.dart
import 'manage_cards.dart'; // Import ManageCardsScreen
import 'add_new_card.dart'; // Import AddNewCardScreen
import 'favorite_screen.dart';
import 'history.dart';
import 'transfer_screen.dart';

// A singleton instance of FlutterSecureStorage
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/forgotpassword': (context) => ForgotPasswordScreen(),
        '/creditcard': (context) => AddNewCardScreen(),
        '/favorite': (context) => FavoriteScreen(),
        '/history': (context) => HistoryScreen(),
        '/transfer': (context) => TransferScreen(),
        '/managecards': (context) {
          final savedCards = ModalRoute.of(context)!.settings.arguments as List<CardDatas>;
          return ManageCards(savedCards: savedCards);
        },
      },
    );
  }
}

// Helper functions for secure storage
Future<void> saveCredentials(String email, String password) async {
  await secureStorage.write(key: 'email', value: email);
  await secureStorage.write(key: 'password', value: password);
}

Future<Map<String, String?>> getCredentials() async {
  String? email = await secureStorage.read(key: 'email');
  String? password = await secureStorage.read(key: 'password');
  return {'email': email, 'password': password};
}

Future<void> deleteCredentials() async {
  await secureStorage.delete(key: 'email');
  await secureStorage.delete(key: 'password');
}
  void checkForSavedCredentials(BuildContext context) async {
    Map<String, String?> credentials = await getCredentials();
    if (credentials['email'] != null && credentials['password'] != null) {
      // Navigate to home screen if credentials exist
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

