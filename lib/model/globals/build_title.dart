import 'package:flutter/material.dart';

Column buildTitle({
  required ColorScheme color,
  required String title,
  double fontSizeTitle = 18,
  double fontSizeSubTitle = 15,
  String subtitle = ""}) {

  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          color: color.primary,
          fontSize: fontSizeTitle,
        ),
      ),

      subtitle.isNotEmpty
          ? Text(
                subtitle,
                style: TextStyle(
                  color: color.secondary,
                  fontSize: fontSizeSubTitle,
                  fontStyle: FontStyle.italic,
                ),
            )
          : const SizedBox.shrink(),
    ],
  );
}