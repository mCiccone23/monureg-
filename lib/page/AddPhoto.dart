import 'dart:ffi';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_vision/google_vision.dart' as google_vision;
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:monureg/page/Report.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'MonumentView.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';


class AddPhoto extends StatefulWidget {
  @override
  _AddPhotoState createState() => _AddPhotoState();
}


class _AddPhotoState extends State<AddPhoto> {

  File? _image;
  String _monumento = '';
  String _descrizione = '';
  double? _latitudine = 41;
  double? _longitudine = 16;
   String ip = '192.168.1.56';

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
     PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => MonumentView(url: _image, descrizione: _descrizione, monumento: _monumento,),
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    ),
    
    );
  }
  void apriDartFile2(BuildContext context) {
    Navigator.push(
      context,
     PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => Report(url: _imageUrl, image: _image),
     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    ),
    
    );
  }

  //Funzione per il riconoscimento di monumenti
  Future<Map<String, dynamic>> fetchLandmarks(String imagePath, double latitudine, double longitudine, int tipo) async {
    showDialog(context: this.context, 
    builder: (context){
      return Center(child: CircularProgressIndicator());
      }
    );
    final apiUrl = 'http://${ip}:105//vision/landmarks';
    final response = await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'image': imagePath, 'latitudine': latitudine, 'longitudine': longitudine, 'tipo': 1}));
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirMon = referenceRoot.child('images');
    
    if (response.statusCode == 200) {
      Navigator.of(this.context).pop();
      return json.decode(response.body);
    } else {
      apriDartFile2(this.context);
      throw Exception('Failed to fetch landmarks');
    }
  }  

String _imageUrl = '';

  Future getImage(ImageSource source) async {
    try{

      final image = await ImagePicker().pickImage(source: source);

      if(image == null) return;
      
      //final imageTemporary = File(image.path);
      final imagePermanent = await saveFilePermanently(image.path);

      setState(() {
        this._image = imagePermanent;
      });
    } on PlatformException catch (e) {
      print('Failed to pick Image: $e');
    } 
  
    try {
      uploadImage(_image!);
        } catch (e) {
                  
                }
  }

  Future<void> uploadImage(File imageFile) async {
  var url = 'http://${ip}:105/upload';
  
  var request = http.MultipartRequest('POST', Uri.parse(url));
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
  
  var response = await request.send();
  
  if (response.statusCode == 200) {
    var jsonResponse = await response.stream.bytesToString();
    var data = jsonDecode(jsonResponse);
    String filePath = data['file_path'];
    setState(() {
      _imageUrl = filePath;
    });
    print('Immagine caricata con successo!');
  } else {
    print('Errore durante il caricamento dell\'immagine.');
  }
}
//ciao a tutti

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');
    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40,),
            _image != null ? Image.file(_image!, width: 250, height: 250, fit: BoxFit.cover,) : Image.network("https://cdn-icons-png.flaticon.com/512/4211/4211763.png", width: 250, height: 250,),
            SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: () {
                    getImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera),
                    label: Text('Snap picture'),
                    ),
                ),
                Container(
                  width: 150,
                  child: ElevatedButton.icon(
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              icon: Icon(Icons.photo_album),
              label: Text('Upload from gallery'),
            ),
            )
              ],
            ),
            ElevatedButton( 
          onPressed: () {
            fetchLandmarks(_imageUrl, _latitudine!, _longitudine!, 1)
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
          child: Text('Get Landmarks'),
        ),

          ],
        ),
      ),
    );
  }
}
