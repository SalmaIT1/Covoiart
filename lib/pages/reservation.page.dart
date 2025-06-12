import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Map<String, dynamic>> reservationRequests = [];

  @override
  void initState() {
    super.initState();
    _loadReservationRequests();
  }

  Future<void> _loadReservationRequests() async {
    // Replace 1 with the actual logged-in user ID
    final int loggedInUserId = 1;

    final String apiUrl =
        'https://192.168.1.6:7203/api/Reservation/reserved-offers/$loggedInUserId';

    try {
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          reservationRequests = responseData
              .map<Map<String, dynamic>>((dynamic item) => Map<String, dynamic>.from(item))
              .toList();
        });
      } else {
        print('Failed to load reservation requests. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during API call: $error');
    }
  }

  Future<void> _acceptReservation(int reservationId) async {
    final String apiUrl = 'https://192.168.1.6:7203/api/Reservation/accept/$reservationId';

    try {
      http.Response response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Assuming the backend returns updated reservation data after acceptance
        final dynamic responseData = jsonDecode(response.body);
        // Find the index of the accepted reservation in the list
        final int index = reservationRequests.indexWhere((request) => request['reservationId'] == reservationId);
        if (index != -1) {
          setState(() {
            // Update the UI to reflect the accepted reservation
            reservationRequests[index] = responseData;
          });
        }

        // Display "Reservation Accepted" in the UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reservation Accepted'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('Failed to accept reservation. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during API call: $error');
    }
  }


  Future<void> _declineReservation(int reservationId) async {
    // API logic for declining reservation
    final String apiUrl = 'https://192.168.1.6:7203/api/Reservation/refuse/$reservationId';

    try {
      http.Response response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Handle successful response as needed
        print('Reservation declined successfully');
        _loadReservationRequests();
      } else {
        print('Failed to decline reservation. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during API call: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Requests'),
      ),
      body: ListView.builder(
        itemCount: reservationRequests.length,
        itemBuilder: (context, index) {
          final request = reservationRequests[index];
          if (request['status'] != 'Reservation Accepted') {
            return Card(
              child: ListTile(
                title: Text('Reservation ID: ${request['reservationId']}'),
                // Add more details based on your data structure
                // For example: subtitle: Text('Status: ${request['status']}'),
                // and customize the UI accordingly
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => _acceptReservation(request['reservationId']),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                      ),
                      child: Text('Accept'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _declineReservation(request['reservationId']),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                      ),
                      child: Text('Decline'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(); // Hide accepted reservations
          }
        },
      ),
    );
  }
}