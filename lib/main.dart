import 'dart:io';
import 'package:covoiart/pages/accueil.page.dart';
import 'package:covoiart/pages/profil.page.dart';
import 'package:covoiart/pages/settings.page.dart';
import 'package:covoiart/pages/splash_screen.page.dart';
import 'package:flutter/material.dart';
import 'package:covoiart/pages/inscription.page.dart';
import 'package:covoiart/pages/login.page.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App',
      initialRoute: '/', // Set the initial route to be '/'
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(), // Set the login page as the initial route
        '/inscription': (context) => RegistrationPage(),
        '/settings': (context) => SettingsPage(),
        '/profile': (context) => ProfilePage(),
        '/HomePage':(context)=>HomePage(),
        // Set the route for InscriptionPage
      },
    );
  }
}
