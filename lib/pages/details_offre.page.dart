import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailsOffrePage extends StatefulWidget {
  final Map<String, dynamic> offerDetails;

  DetailsOffrePage({required this.offerDetails});

  @override
  _DetailsOffrePageState createState() => _DetailsOffrePageState();
}

class _DetailsOffrePageState extends State<DetailsOffrePage> {
  bool reservationSuccessful = false;
  bool isSubmitting = false;
  bool reviewSubmitted = false; // New state variable
  TextEditingController _reviewController = TextEditingController();

  String getBagageType(int value) {
    switch (value) {
      case 0:
        return 'Pas de Bagage';
      case 1:
        return 'Bagage Leger';
      case 2:
        return 'Bagage Lourd';
      default:
        return 'Unknown Bagage Type';
    }
  }

  Future<void> _submitReview() async {
    final String apiUrl = 'https://192.168.1.6:7203/api/Avis/ajouter';

    final Map<String, dynamic> reviewData = {
      'clientId': widget.offerDetails['clientId'],
      'commentaire': _reviewController.text,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200) {
        // Handle successful response as needed
        setState(() {
          reviewSubmitted = true;
        });
        print('Review submitted successfully');
      } else {
        print('Failed to submit review. Status Code: ${response.statusCode}');
      }
    } catch (error) {

    }
  }

  String getBooleanString(bool? value) {
    return value == true ? 'Oui' : 'Non';
  }

  Future<void> _reserve() async {
    final String apiUrl =
        'https://192.168.1.6:7203/api/Reservation/reserve/${widget
        .offerDetails['offreID']}?requesterUserId=2';

    try {
      http.Response response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          reservationSuccessful = true;
        });
      } else {
        print('Reservation Failed. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during reservation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offer Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Depart'),
              subtitle: Text('${widget.offerDetails['depart']}'),
            ),
            ListTile(
              title: Text('Arrivee'),
              subtitle: Text('${widget.offerDetails['arrivee']}'),
            ),
            ListTile(
              title: Text('Nombre de places'),
              subtitle: Text('${widget.offerDetails['nbPlace']}'),
            ),
            ListTile(
              title: Text('Bagage'),
              subtitle: Text(getBagageType(widget.offerDetails['bagage'])),
            ),
            ListTile(
              title: Text('Climatisation'),
              subtitle: Text(
                  getBooleanString(widget.offerDetails['climatisation'])),
            ),
            ListTile(
              title: Text('Fumeur'),
              subtitle: Text(getBooleanString(widget.offerDetails['fumeur'])),
            ),
            ListTile(
              title: Text('Date'),
              subtitle: Text('${widget.offerDetails['date']}'),
            ),
            ListTile(
              title: Text('Client ID'),
              subtitle: Text('${widget.offerDetails['clientId']}'),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: () async {
                  await _reserve();
                },
                child: Text('Reserver'),
              ),
            ),

            // Display success message if reservation is successful
            if (reservationSuccessful)
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Reservation sent successfully'),
                  ],
                ),
              ),

            SizedBox(height: 16),

            Text(
              "Si vous avez déjà eu une expérience avec ce profil, veuillez mettre un avis (facultatif):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Entrez votre avis ici...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
    ElevatedButton(
    onPressed: () async {
    if (_reviewController.text.isNotEmpty) {
    await _submitReview();
    } else {
    // Show an error message or prevent submission
    print('Review cannot be empty');
    }
    },
    child: Text('Submit'),
    ),

    // Display success message if review is submitted successfully
    if (reviewSubmitted)
    ListTile(
    title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.check, color: Colors.green),
    SizedBox(width: 8),
    Text('Review submitted successfully'),
    ],
        ),
      ),
    ])));
  }
}
