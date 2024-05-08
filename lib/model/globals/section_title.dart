import 'package:flutter/material.dart';

Container sectionTitle({
  required ThemeData themeData,
  required String title,
  bool isTitle = true}) {

  return Container(
    width: double.infinity,
    color: isTitle
        ? themeData.colorScheme.secondaryContainer
        : Colors.grey.shade300,
    alignment: isTitle
        ? Alignment.center
        : Alignment.topLeft,
    child: Text(
      title,
      style: TextStyle(
        color: themeData.colorScheme.primary,
        fontSize: themeData.textTheme.bodyMedium?.fontSize,
      ),
    ),
  );
}