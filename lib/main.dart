import 'package:flutter/material.dart';
import 'package:novafarma_front/view/screens.dart';
import 'package:novafarma_front/view/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      home: LoginScreen(), //const HomePageScreen(title: 'NovaFarma'), // scaffoldKey: _scaffoldKey),
    );
  }
}
