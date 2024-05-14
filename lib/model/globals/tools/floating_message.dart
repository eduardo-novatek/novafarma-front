import 'package:flutter/material.dart';


void floatingMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w300)),

        showCloseIcon: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        behavior: SnackBarBehavior.floating, // Aspecto flotante

        //margin: const EdgeInsets.only(bottom: 100,),
        // 40% del ancho de la pantalla (no puede utilizarse junto a margin)
        width:  MediaQuery.of(context).size.width * 0.4,

  ));
}
