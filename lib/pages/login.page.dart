import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'accueil.page.dart';
import 'inscription.page.dart';

class APIService {
  static var client = http.Client();

  static Future<bool> loginUser(String email, String password) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Client/login';

    try {
      var response = await client.post(Uri.parse('$apiUrl?email=$email&password=$password'));
      var responseBody = response.body;

      if (response.statusCode == 200) {
        print('Login successful');
        var responseData = jsonDecode(responseBody);
        var clientId = responseData['clientId'];

        // Store clientId in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('loggedInClientId', clientId);

        // Print clientId to console
        print('Logged In Client ID: $clientId');

        return true;
      } else {
        print('Login failed');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }
}class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    bool loginStatus = await APIService.loginUser(email, password);

    if (loginStatus) {
      print('Login successful');
      // Navigate to HomePage upon successful login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      print('Login failed');
      // Show an error message or handle the failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email not found or wrong password.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                SizedBox(
                  width: 259,
                  height: 259,
                  child: Image.asset(
                    'assets/images/Covoiart.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 330,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green.withOpacity(0.25),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Entrez votre mail...',
                            contentPadding: EdgeInsets.all(12),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 60),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green.withOpacity(0.25),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Entrez votre mot de passe...',
                            contentPadding: EdgeInsets.all(12),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Container(
                    width: 150,
                    height: 37,
                    alignment: Alignment.center,
                    child: Text('Connecter'),
                  ),
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage()),
                    );
                  },
                  child: Text(
                    'Nouveau sur l\'app ? Inscrivez vous',
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.7),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '© Covoit\'Art 2023',
                  style: TextStyle(color: Colors.grey.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}


void main() {
  runApp(MaterialApp(
    title: 'Login App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: LoginPage(),
  ));
}