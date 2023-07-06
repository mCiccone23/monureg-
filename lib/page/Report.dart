import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:monureg/page/AddPhoto.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

import 'MonumentView.dart';

class Report extends StatefulWidget {
  final String url;
  final File? image;

  Report({required this.url, this.image});

  @override
  _ReportState createState() => _ReportState(url, image);
}

class _ReportState extends State<Report> {
  String url;
  File? image;

  _ReportState(this.url, this.image);

 final _formKey = GlobalKey<FormState>();
 TextEditingController _emailController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _monumentController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  String? _emailErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _cityController.dispose();
    _monumentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  File? _image;
  String _monumento = '';
  String _descrizione = '';
  double? _latitudine = 0;
  double? _longitudine = 0;
  String ip = '172.29.37.4';
  



  String? _imageUrl = ' ';

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
       return;
      }
          geo.Position position = await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitudine = position.latitude;
          print(_latitudine);
          _longitudine = position.longitude;
          print(_longitudine);
        });
    
      
    } catch (e) {
      print(e);
    }
      
  }
  void apriDartFile(BuildContext context) {
    Navigator.push(
      context,
     PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => MonumentView(url: image, descrizione: _descrizione, monumento: _monumento,),
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    ),
    
    );
  }
  void apriDartFile2(BuildContext context) {
    Navigator.push(
      context,
     PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => Report(url: url, image: image),
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    ),
    
    );
  }

  void validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailErrorMessage = 'Campo obbligatorio';
      });
    } else if (!EmailValidator.validate(value)) {
      setState(() {
        _emailErrorMessage = 'Inserisci un indirizzo email valido';
      });
    } else {
      setState(() {
        _emailErrorMessage = null;
      });
    }
  }

  Future<Map<String, dynamic>> fetchLandmarks(String imagePath, double latitudine, double longitudine) async {
    showDialog(context: this.context, 
    builder: (context){
      return Center(child: CircularProgressIndicator());
      }
    );
  
    final apiUrl = 'http://${ip}:105//vision/landmarks';
    final response = await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'image': imagePath, 'latitudine': latitudine, 'longitudine': longitudine, 'tipo': 2}));
    
    if (response.statusCode == 200) {
      Navigator.of(this.context).pop();
      return json.decode(response.body);
    } else{
      apriDartFile2(context);
      throw Exception('Failed to fetch landmarks');
    }
  }  

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final city = _cityController.text;
      final monument = _monumentController.text;
      final note = _noteController.text;

      final apiUrl = 'http://${ip}:105//upload_report';
      final response = await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'email' : email, 'city': city, 'monument' : monument, 'note': note}));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dati salvati con successo')),
      );
        Navigator.of(context).popUntil((route) => route.isFirst);
        return json.decode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel salvataggio dei dati')),
        );
        apriDartFile2(this.context);
        throw Exception('Report Error');
      }
      // Connessione al database MongoDB
    //   final db = mongo.Db("mongodb://10.0.2.2:27017/monureg");
    //   await db.open();

    //   // Collezione nel database in cui verranno salvati i dati
    //   final collection = db.collection('reports');

    //   var objectId = mongo.ObjectId(); // Crea un nuovo ObjectId

    //   // Documento da salvare nel database
    //   final document = {
    //     '_id': objectId.toHexString(),
    //     'email': email,
    //     'city': city,
    //     'monument': monument,
    //     'note': note,
    //     'imagePath' : url
    //   };

  

    //   // Inserimento del documento nella collezione
    //   await collection.insertOne(document);

    //   // Chiusura della connessione al database
    //   await db.close();

    //   // Mostrare una notifica o effettuare un'azione di conferma
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Dati salvati con successo')),
    //   );

    //   Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => AddPhoto(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return child;
            },
          ),
          );
          },
        ),
        title: Text('Report'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text(
                    "Ci dispiace ma non siamo riusciti a riconoscere l'immagine",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _getCurrentLocation();
            fetchLandmarks(url, _latitudine!, _longitudine!)
              .then((landmarks) {
                setState(() {
                  _monumento = landmarks.values.first.toString();
                  _descrizione = landmarks.values.elementAt(1).toString();;
                });
                print(_monumento);
                print(_descrizione);
                apriDartFile(context);
              })
              .catchError((error) {
                print(error);
              });
                    },
                    child: Text('Monumento + vicino GPS'),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailErrorMessage,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo obbligatorio';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Inserisci un indirizzo email valido';
                      }
                      return null;
                    },
                    onChanged: validateEmail,
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(labelText: 'Città del monumento'),
                  ),
                  TextFormField(
                    controller: _monumentController,
                    decoration: InputDecoration(labelText: 'Nome del monumento (facoltativo)'),
                  ),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(labelText: 'Note'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: submitForm,
                    child: Text('Committare le informazioni'),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}