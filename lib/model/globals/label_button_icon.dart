import 'package:flutter/cupertino.dart';

import 'constants.dart' show buttonsTextSize;

//Label con los valores por defecto para botones con iconos
Widget labelButtonIcon(String label) {
  return Text(
    label,
    style: const TextStyle(
        fontSize: buttonsTextSize,
        fontWeight: FontWeight.w400
    ),
  );
}