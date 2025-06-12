import 'package:flutter/material.dart';
import 'login.page.dart';
import 'modif_info_perso.page.dart';
import 'modif_mdp.page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _clientId = 0; // Initialize client ID

  @override
  void initState() {
    super.initState();
    _getClientIdFromSharedPrefs(); // Fetch client ID when page initializes
  }

  Future<void> _getClientIdFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _clientId = prefs.getInt('loggedInClientId') ?? 0;
    });
  }

  Future<bool> _deleteAccount() async {
    var apiUrl = 'https://192.168.1.6:7203/api/Client/$_clientId';

    try {
      var response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Account deleted successfully for Client ID: $_clientId');
        return true;
      } else {
        print('Failed to delete account for Client ID: $_clientId');
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Voulez-vous vraiment supprimer votre compte ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () async {
                bool success = await _deleteAccount();
                if (success) {
                  // Account deleted successfully
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Compte supprimé avec succès pour le client $_clientId'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                } else {
                  // Failed to delete account
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Échec de la suppression du compte pour le client $_clientId'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Lottie.network(
                'https://lottie.host/aaab0d30-58b0-4d7f-9c84-56e81cc6b625/bCEztEAYxq.json',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Modifier Mot de Passe'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordChangePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Modifier Information Personnelle'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ModifyPersonalInfoPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Supprimer Mon Compte'),
                  onTap: () {
                    _showConfirmationDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));

                  },
                ),
              ],
            ),
          ),
        ],
      ),

    );
  }
}
