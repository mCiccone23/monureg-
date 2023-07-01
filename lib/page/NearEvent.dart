import 'package:flutter/material.dart';

class NearEvent extends StatefulWidget {
  @override
  _NearEventState createState() => _NearEventState();
}

class _NearEventState extends State<NearEvent> {

@override
Widget build(BuildContext context) {
  return Scaffold(
  body: Center(
  child: Text('Eventi Vicini', style: TextStyle(fontSize: 40)),
  ),
  );
}
}