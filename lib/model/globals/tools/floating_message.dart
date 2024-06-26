import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';

class FloatingMessage {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String text,
    required MessageTypeEnum messageTypeEnum,
    int secondsDelay = 3,
    bool allowFlow = false,
  }) async {
    if (_isShowing) return;

    final overlay = Overlay.of(context);

    void removeOverlay() {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
        _isShowing = false;
      }
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * 0.3,
        right: MediaQuery.of(context).size.width * 0.3,
        child: GestureDetector(
          onTap: () {
            if (!allowFlow) removeOverlay();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: getColorMessage(messageTypeEnum),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getIconMessage(messageTypeEnum),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17.0, color: Colors.black),
                    ),
                  ),
                  !allowFlow
                      ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: removeOverlay,
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    _isShowing = true;

    await Future.delayed(Duration(seconds: secondsDelay));

    if (_overlayEntry != null) {
      removeOverlay();
    }
  }
}




//
// Impementarion 2
//
/*Future<void> floatingMessage({
  required BuildContext context,
  required String text,
  required MessageTypeEnum messageTypeEnum,
  int? secondsDelay = 3,
  bool? allowFlow = false, // Si debe "permitir el flujo" de la app mientras se muestra el mensaje (por defecto, espera)
}) async {

  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  bool isRemoved = false;
  final completer = Completer(); //Controla el Future manualmente (captura la instancia del Future actual)

  void removeOverlay() {
    if (!isRemoved) {
      isRemoved = true;
      overlayEntry.remove();
      completer.complete(); // Completa el Future y notifica a cualquier codigo que esté esperando por este Future
    }
  }

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).size.height * 0.02,
      left: MediaQuery.of(context).size.width * 0.3,
      right: MediaQuery.of(context).size.width * 0.3,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: getColorMessage(messageTypeEnum),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getIconMessage(messageTypeEnum),
              const SizedBox(width: 8.0), // Espaciado entre el icono y el texto
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17.0, color: Colors.black),
                ),
              ),
              ! allowFlow! // Permite cerrar manualmente solo si se detiene el flujo de la app
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: removeOverlay,
                  )
                : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: secondsDelay!), removeOverlay);
  if (! allowFlow!) return completer.future; // Espera antes de continuar
}
*/


//
// Impementarion 1
//
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

