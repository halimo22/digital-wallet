import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(MaterialApp(home: HomeScreen()));

class CashAndRewardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OffersScreen(),
    );
  }
}

class Offer {
  final String title;
  final String subtitle;
  final String imageUrl;

  Offer({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final List<Offer> offers = [
    Offer(
      title: "Exclusive Offer for Noon",
      subtitle: 'noon',
      imageUrl: 'assets/noon.png',
    ),
    Offer(
      title: 'Unwind with Chic Clothes from H&M',
      subtitle: 'H&M',
      imageUrl: 'assets/hm.png',
    ),
    Offer(
      title: 'Stay Fit with Amazon Fitness Gear',
      subtitle: 'Amazon',
      imageUrl: 'assets/amazon.png',
    ),
    Offer(
      title: 'Get Exclusive Offers from Nike',
      subtitle: 'Nike',
      imageUrl: 'assets/nike.png',
    ),
  ];

  final List<Offer> favorites = [];

  void addToFavorites(Offer offer) {
    setState(() {
      favorites.add(offer);
    });
  }

  void removeFromFavorites(Offer offer) {
    setState(() {
      favorites.remove(offer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers & Rewards'),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      offer.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(offer.title),
                  subtitle: Text(offer.subtitle),
                  trailing: IconButton(
                    icon: Icon(
                      favorites.contains(offer)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (favorites.contains(offer)) {
                        removeFromFavorites(offer);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text('${offer.title} removed from favorites'),
                          ),
                        );
                      } else {
                        addToFavorites(offer);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${offer.title} added to favorites'),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
