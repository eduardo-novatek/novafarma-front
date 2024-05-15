import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';


void floatingMessage({
  required BuildContext context,
  required String text,
  required MessageTypeEnum messageTypeEnum,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).size.height * 0.02,
      left: MediaQuery.of(context).size.width * 0.3,
      right: MediaQuery.of(context).size.width * 0.3,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            //color: Theme.of(context).colorScheme.secondary,
            color: getColorMessage(messageTypeEnum),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w300, color: Colors.black),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });


  /*ScaffoldMessenger.of(context).clearSnackBars();

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

   */
}
