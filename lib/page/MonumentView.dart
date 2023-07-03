import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../widgets/BottomLoader.dart';
import 'MonumentView.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:flutter/widgets.dart';

class MonumentView extends StatefulWidget {
  final File? url;
  final String descrizione;
  final String monumento;

  MonumentView({required this.url, required this.descrizione, required this.monumento});

  @override
  _MonumentViewState createState() => _MonumentViewState(url, descrizione, monumento);
}

class _MonumentViewState extends State<MonumentView> {
  File? url;
  String descrizione;
  String monumento;

  _MonumentViewState(this.url, this.descrizione, this.monumento);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettagli Monumento'),
      ),
      body: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    child: Image.file(
                            widget.url!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                ListTile(
                  title: Text(
                    widget.monumento,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    widget.descrizione,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ), 
    );
  }

}