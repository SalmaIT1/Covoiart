import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordChangePage extends StatefulWidget {
  @override
  _PasswordChangePageState createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final TextEditingController _newPasswordController = TextEditingController();
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

  Future<bool> _changePassword(int clientId, String newPassword) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Client/modifierMotDePasse/$clientId';

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newPassword), // Sending just the string directly
      );

      if (response.statusCode == 200) {
        print('Password changed successfully for Client ID: $clientId');
        return true;
      } else {
        print('Failed to change password for Client ID: $clientId');
        return false;
      }
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }
  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Voulez-vous vraiment changer votre mot de passe ?'),
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
                bool success = await _changePassword(_clientId, _newPasswordController.text);
                if (success) {
                  // Password changed successfully, show success message or navigate to another page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mot de passe changé avec succès pour le client $_clientId'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Password change failed, show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Échec du changement de mot de passe pour le client $_clientId'),
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
      appBar: AppBar(
        title: Text('Changer le mot de passe'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showConfirmationDialog();
              },
              child: Text('Changer le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}
