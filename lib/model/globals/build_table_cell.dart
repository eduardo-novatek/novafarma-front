import 'package:flutter/material.dart';

TableCell buildTableCell({
  required String text,
  bool bold = false,
  bool rightAlign = false,
  double size = 13,
  bool iconControlled = false}) {
  return TableCell(
    child: Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment: rightAlign
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          _buildControlledIcon(iconControlled, size),
          Text(
            text,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: size,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildControlledIcon(bool controlled, double size) {
  return controlled
      ? Tooltip(
          message: 'Medicamento controlado',
          child: Icon(
            Icons.copyright,
            color: Colors.red,
            size: size,
          ),
        )
      : const SizedBox.shrink();
}