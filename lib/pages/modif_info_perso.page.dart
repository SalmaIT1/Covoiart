import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ModifyPersonalInfoPage extends StatefulWidget {
  @override
  _ModifyPersonalInfoPageState createState() => _ModifyPersonalInfoPageState();
}

class _ModifyPersonalInfoPageState extends State<ModifyPersonalInfoPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  int _clientId = 0; // Default value, will be updated from SharedPreferences

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


  Future<bool> _updateInfo() async {
    var updatedInfo = {
      "clientId": _clientId,
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "email": _emailController.text,
      "image": "string", // Placeholder, add logic for image
      "tel": int.parse(_phoneNumberController.text),
      "password": "testing" // Placeholder, consider removing this from here for security reasons
    };

    print('Updating personal information for Client ID: $_clientId...');
    var apiUrl = 'https://192.168.1.6:7203/api/Client/modifierInformationsPersonnelles/$_clientId';

    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedInfo),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Personal information updated successfully for Client ID: $_clientId');
        return true;
      } else {
        print('Failed to update personal information for Client ID: $_clientId');
        return false;
      }
    } catch (e) {
      print('Error updating personal information: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Personal Info'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/default_avatar.png'), // Add logic to load/change the image
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _updateInfo();
              },
              child: Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}
