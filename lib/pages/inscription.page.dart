import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'login.page.dart';

class APIService {
  static var client = http.Client();

  static Future<bool> registerUser(Map<String, dynamic> userData) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Client'; // Replace with your API endpoint URL

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData), // Convert map to JSON string
      );

      if (response.statusCode == 200) {
        return true; // Registration successful
      } else {
        return false; // Registration failed
      }
    } catch (e) {
      print('Error during registration: $e');
      return false; // Error during registration
    }
  }
}

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }


  Future<void> _registerUser() async {
    var userData = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "email": _emailController.text,
      "image": _selectedImage != null ? base64Encode(_selectedImage!.readAsBytesSync()) : "",
      "tel": _phoneController.text,
      "password": _passwordController.text,
    };

    bool registrationStatus = await APIService.registerUser(userData);

    if (registrationStatus) {
      print('Registration successful');
      // Navigate to the LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      print('Registration failed');
      // Show an error message or handle the failure
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // Logo Image
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/images/Covoiart.png', // Replace with your logo image path
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20),
                // Image Upload Section
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : Center(
                    child: IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Registration Form

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.green.withOpacity(0.25),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.green.withOpacity(0.25),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre mail ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.green.withOpacity(0.25),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre numéro ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.green.withOpacity(0.25),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre mot de passe ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.green.withOpacity(0.25),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerUser,
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                     // Green button color
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Déjà inscrit ? Connexion!'),
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
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Registration App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: RegistrationPage(),
  ));
}