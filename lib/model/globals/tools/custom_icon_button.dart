import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Function onTap; // Acepta cualquier tipo de función
  final String tooltipMessage;
  final IconData icon;
  final double iconSize;
  final Color iconColor;

  const CustomIconButton({
    super.key,
    required this.onTap,
    required this.tooltipMessage,
    required this.icon,
    required this.iconSize,
    this.iconColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Tooltip(
        message: tooltipMessage,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              var result = onTap();
              if (result is Future) {
                // Si es un Future, espera a que se complete
                result.then((_) {
                  // Manejar el resultado del Future
                }).catchError((error) {
                  if (kDebugMode) print("Error en CustomIconButton: $error");
                });
              }
            },
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.transparent,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
