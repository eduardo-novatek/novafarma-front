import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

Future<void> genericError(Object error, BuildContext context) async {
  if (error.toString().contains('XMLHttpRequest error')) {
    await OpenDialog(
        context: context,
        title: 'Error de conexión',
        content: 'No es posible conectar con el servidor',
    ).view();
  } else {
    if (error.toString().contains('TimeoutException')) {
      await OpenDialog(
          context: context,
          title: 'Error de conexión',
          content: 'No es posible conectar con el servidor.\nTiempo expirado.',
      ).view();
    } else {
      await OpenDialog(
          context: context,
          title: 'Error desconocido',
          content: error.toString(),
      ).view();
    }
  }
}