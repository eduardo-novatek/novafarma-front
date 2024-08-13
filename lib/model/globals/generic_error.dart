import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

Future<void> genericError(
  Object error,
  BuildContext context,
  {bool isFloatingMessage = false}
  ) async {

  if (error.toString().contains('XMLHttpRequest error')) {
    if (isFloatingMessage) {
      FloatingMessage.show(
        context: context,
        text: 'Error de conexión',
        messageTypeEnum: MessageTypeEnum.error,
        secondsDelay: 8,
      );
    } else {
      await OpenDialog(
        context: context,
        title: 'Error de conexión',
        content: 'No es posible conectar con el servidor',
      ).view();
    }

  } else {
    if (error.toString().contains('TimeoutException')) {
      if (isFloatingMessage) {
        FloatingMessage.show(
          context: context,
          text: 'No es posible conectar con el servidor.\nTiempo expirado.',
          messageTypeEnum: MessageTypeEnum.error,
          secondsDelay: 8,
        );
      } else {
        await OpenDialog(
          context: context,
          title: 'Error de conexión',
          content: 'No es posible conectar con el servidor.\nTiempo expirado.',
        ).view();
      }

    } else {
      if (isFloatingMessage) {
        FloatingMessage.show(
          context: context,
          text: error.toString(),
          messageTypeEnum: MessageTypeEnum.error,
          secondsDelay: 8,
        );
      } else {
        await OpenDialog(
          context: context,
          title: 'Error desconocido',
          content: error.toString(),
        ).view();
      }
    }
  }
}