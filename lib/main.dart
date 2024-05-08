import 'package:flutter/material.dart';
import 'package:novafarma_front/view/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaFarma',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlueAccent,
        ),
      ),
      home: const HomePageScreen(title: 'NovaFarma'),
    );
  }
}
