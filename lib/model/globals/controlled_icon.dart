import 'package:flutter/material.dart';

Tooltip controlledIcon({bool isDeleted = false}) {
  return Tooltip(
    message: 'Medicamento controlado',
    child: Icon(
      Icons.copyright,
      color: isDeleted ? Colors.grey : Colors.red,)
  );
}