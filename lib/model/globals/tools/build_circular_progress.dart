import 'package:flutter/material.dart';

Widget buildCircularProgress({double size = 24.0}) {
  return Center(
    child: SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation(Colors.blue),
      ),
    ),
  );
}