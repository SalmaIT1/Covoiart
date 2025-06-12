import 'package:flutter/material.dart';

import '../pages/accueil.page.dart';
import '../pages/profil.page.dart';
import '../pages/settings.page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Bottom Navigation Bar Example',
    home: BottomMenu(),
  ));
}

class BottomMenu extends StatefulWidget {
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    HomePage(),
    Search(), // Change the position to index 1
    ProfilePage(),
    SettingsPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation to ProfilePage when the Profile icon is tapped (index 2)
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bottom Navigation Bar'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Search icon
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}

class Search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Enter your search query',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
