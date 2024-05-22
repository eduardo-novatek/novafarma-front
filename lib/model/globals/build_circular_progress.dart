import 'package:flutter/material.dart';

Widget buildCircularProgress() {
  return const Center(
    child: SizedBox(
      height: 12.0,
      width: 12.0,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation(Colors.blue),
      ),
    ),
  );
}