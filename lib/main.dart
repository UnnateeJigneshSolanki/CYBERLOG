import 'package:flutter/material.dart';
void main() {
  runApp
  (
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter App"),
        ),
        body: Center(
          child: Text("Hello World"),
        ),
      ),
    )
  );

}