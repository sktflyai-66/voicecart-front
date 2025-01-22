import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/selection_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Accessibility App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SelectionPage(),
    );
  }
}
