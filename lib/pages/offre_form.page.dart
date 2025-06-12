import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:shared_preferences/shared_preferences.dart';

class OffrePage extends StatefulWidget {
  @override
  _OffrePageState createState() => _OffrePageState();
}

class _OffrePageState extends State<OffrePage> {
  final _formKey = GlobalKey<FormState>();

  String _depart = '';
  String _arrivee = '';
  int _nbPlace = 0;
  int _bagage = 0;
  bool _climatisation = false;
  bool _funleur = false;
  DateTime _date = DateTime.now();
  int _clientId = 0;
  String _formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadClientId();
  }

  Future<void> loadClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _clientId = prefs.getInt('loggedInClientId') ?? 0;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> requestData = {
        'depart': _depart,
        'arrivee': _arrivee,
        'nbPlace': _nbPlace,
        'bagage': _bagage,
        'climatisation': _climatisation,
        'funleur': _funleur,
        'date': _date.toIso8601String(),
        'clientId': _clientId,
      };

      try {
        final response = await http.post(
          Uri.parse('https://192.168.1.6:7203/api/Offre'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          print('Form submitted successfully');
        } else {
          print('Failed to submit form: ${response.statusCode}');
        }
      } catch (e) {
        print('Error submitting form: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _formattedDate = DateFormat('yyyy-MM-dd').format(_date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offre Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Départ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a departure location';
                  }
                  return null;
                },
                onChanged: (value) {
                  _depart = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Arrivée'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an arrival location';
                  }
                  return null;
                },
                onChanged: (value) {
                  _arrivee = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre de places'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  _nbPlace = int.tryParse(value) ?? 0;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Bagage'),
                value: _bagage,
                onChanged: (int? newValue) {
                  setState(() {
                    _bagage = newValue ?? 0;
                  });
                },
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text('Pas de Bagage'),
                  ),
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('Bagage Leger'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('Bagage Lourd'),
                  ),
                ],
              ),
              CheckboxListTile(
                title: Text('Climatisation'),
                value: _climatisation,
                onChanged: (newValue) {
                  setState(() {
                    _climatisation = newValue ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Fumeur'),
                value: _funleur,
                onChanged: (newValue) {
                  setState(() {
                    _funleur = newValue ?? false;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Pickup Date'),
                controller: TextEditingController(text: _formattedDate),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            onPressed: _submitForm,
            child: Text('Submit'),
          ),),
            ],
          ),
        ),
      ),
    );
  }
}
