import 'package:flutter/material.dart';
import 'setting.dart';
import 'package:app_settings/app_settings.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GPS Location ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AskForPermission(),
    );
  }
}