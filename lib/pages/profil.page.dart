import 'dart:convert';
import 'package:covoiart/pages/reservation.page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'notification.page.dart';
import 'offre_form.page.dart';

class APIService {
  static Future<Map<String, dynamic>> fetchUserProfile(int clientId) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Client/$clientId';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('Failed to fetch user profile');
        return {};
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return {};
    }
  }
  static Future<List<dynamic>> fetchNotifications(int requesterUserId) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Notification/notifications/$requesterUserId';

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> notifications = jsonDecode(response.body);
        return notifications;
      } else {
        print('Failed to fetch notifications. Status Code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  static Future<List<dynamic>> fetchUserOffers(int clientId) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Offre/client/$clientId';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Offers Response: $responseData');
        return responseData;
      } else {
        print('Failed to fetch user offers');
        return [];
      }
    } catch (e) {
      print('Error fetching user offers: $e');
      return [];
    }
  }

  static Future<List<dynamic>> fetchUserReviews(int clientId) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Avis/client/$clientId';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      print('Reviews Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<dynamic> reviews = jsonDecode(response.body);
        print('Fetched user reviews: $reviews');
        return reviews;
      } else {
        print('Failed to fetch user reviews');
        return [];
      }
    } catch (e) {
      print('Error fetching user reviews: $e');
      return [];
    }
  }
}
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userProfile = {};
  List<dynamic> userOffers = [];
  int loggedInClientId = 0;
  List<dynamic> userReviews = [];
  List<Map<String, dynamic>> acceptedReservations = [];


  @override
  void initState() {
    super.initState();
    loadClientId();
    fetchAcceptedReservations(); // Call this function in initState to fetch notifications

  }

  Future<void> loadClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInClientId = prefs.getInt('loggedInClientId') ?? 0;
    });

    await fetchUserProfileAndOffers();
    await fetchUserReviews();
    await fetchAcceptedReservations();

  }
  Future<void> fetchAcceptedReservations() async {
    if (loggedInClientId != 0) {
      var notifications = await APIService.fetchNotifications(loggedInClientId);

      setState(() {
        acceptedReservations = notifications.cast<Map<String, dynamic>>();
      });
    }
  }
  Future<void> fetchUserReviews() async {
    if (loggedInClientId != 0) {
      var reviews = await APIService.fetchUserReviews(loggedInClientId);

      setState(() {
        userReviews = reviews;
      });
    }
  }

  Future<void> fetchUserProfileAndOffers() async {
    if (loggedInClientId != 0) {
      var profile = await APIService.fetchUserProfile(loggedInClientId);
      var offers = await APIService.fetchUserOffers(loggedInClientId);

      setState(() {
        userProfile = profile;
        userOffers = offers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Container(
        height: 200,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          color: Colors.greenAccent.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0.0),
            topRight: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(190.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.topLeft,
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.transparent,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.transparent,
                        child: userProfile.containsKey('image')
                            ? ClipOval(
                          child: Image.memory(
                            base64Decode(userProfile['image']),
                            fit: BoxFit.cover,
                            width: 110,
                            height: 110,
                          ),
                        )
                            : Center(
                          child: Text('No Image'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${userProfile['firstName']} ${userProfile['lastName']}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text('${userProfile['email']}'),
                Text('${userProfile['tel']}'),
              ],
            ),
          ],
        ),
      ),


          Expanded(
            child: Container(
              margin: EdgeInsets.all(16.0),
              decoration: BoxDecoration(

              ),
              child: ListView.builder(
                itemCount: userOffers.length,
                itemBuilder: (context, index) {
                  final offer = userOffers[index];
                  return ListTile(
                    title: Text('Offer ID: ${offer['offreID']}'),
                    subtitle: Text('Depart: ${offer['depart']} - Arrivee: ${offer['arrivee']}'),
                  );
                },
              ),
            ),
          ),
          // Container to display user reviews
          Container(
            height: 100,
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(

              border: Border.all(width: 0.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'User Reviews',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                // Display user reviews using a ListView.builder
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(
                        userReviews.length,
                            (index) {
                          final review = userReviews[index];
                          return Container(
                            height: 70, // Set the height of each review container
                            child: ListTile(
                              title: Text('Avis: ${review['avisID']}'),
                              subtitle: Text(' ${review['commentaire']}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the existing ReservationPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationPage()),
                );

              },

              child: Text('Consulter mes réservations'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the NotificationPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage(acceptedReservations)),
                );
              },
              child: Text('View Notifications'), // Button text
            ),
          ),
        ],
      ),
    );
  }
}




void main() {
  runApp(MaterialApp(
    title: 'Profile App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: ProfilePage(),
  ));
}