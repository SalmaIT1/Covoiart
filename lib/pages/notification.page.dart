import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //
import 'package:flutter/material.dart';
class APIService {
  static Future<List<dynamic>> fetchNotifications(int requesterUserId) async {
    var apiUrl = 'https://192.168.1.6:7203/api/Notification/notifications/$requesterUserId';

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> notifications = jsonDecode(response.body);
        print('Notifications response: $notifications'); // Add this line to print the response
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

}

class NotificationPage extends StatefulWidget {
  final List<dynamic> notifications;

  NotificationPage(this.notifications);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: widget.notifications.length,
        itemBuilder: (context, index) {
          final notification = widget.notifications[index];
          return ListTile(
            title: Text(' Votre reservation sous l\'identifiant: ${notification['reservationId']} est acceptée'),
            // Display more details based on the notification data
          );
        },
      ),
    );
  }
}

// ... (rest of your code remains the same)
