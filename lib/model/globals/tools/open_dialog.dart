import 'dart:async';

import 'package:flutter/material.dart';

class OpenDialog {
  final BuildContext context;
  final String title;
  final String content;
  final bool smallFont;
  final String textButton1;
  final String textButton2;
  final String textButton3;
  //final String focus; //texto del boton que recibe el foco (por defecto es textButton1)

  OpenDialog({
    required this.context,
    this.title = '¿Confirma?',
    this.content = '',
    this.smallFont = false,
    this.textButton1 = 'Ok',
    this.textButton2 = '',
    this.textButton3 = '',
    //this.focus = 'Ok',
  });

  Future<int> view() async {
    Completer<int> completer = Completer<int>();
    double fontSize = smallFont ? 13.0 : 18.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
            child: Text(
              content,
               style: TextStyle(fontSize: fontSize),)
        ),

        actions: [
          TextButton.icon(
            autofocus: textButton2.isEmpty ,
            onPressed: () {
              completer.complete(1);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check, color: Colors.green),
            label: Text(textButton1, style: const TextStyle(fontSize: 22)),
          ),

          textButton2.isNotEmpty
              ? TextButton.icon(
                  autofocus: textButton2.isNotEmpty,
                  onPressed: () {
                    completer.complete(2);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: Text(textButton2, style: const TextStyle(fontSize: 22)),
                )
              : const SizedBox.shrink(),

          textButton3.isNotEmpty
              ? TextButton.icon(
                  onPressed: () {
                    completer.complete(3);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.info),
                  label: Text(textButton3, style: const TextStyle(fontSize: 22)),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );

    return completer.future;
  }

}
