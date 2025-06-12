import 'package:covoiart/pages/profil.page.dart';
import 'package:covoiart/pages/settings.page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart'; // Import the Lottie package

import 'details_offre.page.dart';
import 'offre_form.page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Bottom Navigation Bar Example',
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePageContent(),
    SettingsPage(),
    ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<dynamic> allOffers = [];
  List<dynamic> filteredOffers = [];

  TextEditingController departController = TextEditingController();
  TextEditingController arriveeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      final response = await http.get(Uri.parse('https://192.168.1.6:7203/api/Offre'));
      if (response.statusCode == 200) {
        setState(() {
          allOffers = jsonDecode(response.body);
          filteredOffers = List.from(allOffers); // Initialize filteredOffers with all offers
        });
      } else {
        print('Failed to fetch offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }

  void applyFilter() {
    setState(() {
      filteredOffers = allOffers
          .where((offer) =>
      offer['depart'].toLowerCase().contains(departController.text.toLowerCase()) &&
          offer['arrivee'].toLowerCase().contains(arriveeController.text.toLowerCase()))
          .toList();
    });
  }

  void refreshPage() {
    fetchOffers(); // Call the method to reload the offers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage - Covoiart'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshPage,
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Lottie animation at the top
          Lottie.network(
            'https://lottie.host/6974d595-cf7e-4d10-a3e6-d7d87600778b/ZtKIM22c3M.json',
            width: double.infinity,
            height: 200, // Adjust the height as needed
            fit: BoxFit.cover,
          ),
          SizedBox(height: 50), // Add this SizedBox for spacing
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: departController,
                    onChanged: (value) => applyFilter(),
                    decoration: InputDecoration(
                      labelText: 'Départ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.lightGreen, // You can change the border color here
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.lightGreen, // You can change the border color here
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.lightGreen, // You can change the border color here
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: arriveeController,
                    onChanged: (value) => applyFilter(),
                    decoration: InputDecoration(
                      labelText: 'Arrivée',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.lightGreen, // You can change the border color here
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.lightGreen, // You can change the border color here
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.lightGreen, // You can change the border color here
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOffers.length,
              itemBuilder: (context, index) {
                final offer = filteredOffers[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 3.0, // You can adjust the elevation here
                  margin: EdgeInsets.all(5.0),
                  child: ListTile(
                    title: Text('Offer ID: ${offer['offreID']}'),
                    subtitle: Text('Depart: ${offer['depart']} - Arrivee: ${offer['arrivee']}'),
                    onTap: () {
                      navigateToDetailsPage(offer);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                navigateToOffrePage();
              },
              child: Text('Ajouter une nouvelle offre'),
              style: ElevatedButton.styleFrom(),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToDetailsPage(Map<String, dynamic> offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsOffrePage(offerDetails: offer),
      ),
    );
  }

  void navigateToOffrePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OffrePage(),
      ),
    );
  }
}
