import 'package:flutter/material.dart';

class BottomLoader extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(16.0),
      child: CircularProgressIndicator(),
    );
  }
}
