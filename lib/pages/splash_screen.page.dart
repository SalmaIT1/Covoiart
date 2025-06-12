import 'package:flutter/material.dart';

import 'login.page.dart'; // Import your HomePage here

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInFadeOut;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    Future.delayed(Duration(seconds:5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(), // Replace with your home page widget
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeInFadeOut,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/Covoiart.png', // Replace with your image path
                  width: 200, // Set your desired width
                  height: 200, // Set your desired height
                ),
              ),
            ),
            SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _fadeInFadeOut.value,
              duration: Duration(seconds: 2),
              child: Text(
                'Bienvenue', // Your welcome text
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Playfair Display', // Use Playfair Display font
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
