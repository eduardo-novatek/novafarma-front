import 'package:flutter/material.dart';
import '../../view/screens/login_screen.dart';

Widget logout(BuildContext context) {
  return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        doLogout(context);
      },
    );
}

void doLogout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Evita que el usuario pueda volver atrás
  );
}