import 'package:flutter/material.dart';

class CustomAppBarPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Title'),
      centerTitle: true,
      leading: BackButton(),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {},
        )
      ],
    ),
  );
}