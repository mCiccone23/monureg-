import 'package:flutter/material.dart';

class PhotoBook extends StatefulWidget {
  @override
  _PhotoBookState createState() => _PhotoBookState();
}

class _PhotoBookState extends State<PhotoBook> {

@override
Widget build(BuildContext context) {
  return Scaffold(
  body: Center(
  child: Text('Book fotografico', style: TextStyle(fontSize: 40)),
  ),
  );
}
}