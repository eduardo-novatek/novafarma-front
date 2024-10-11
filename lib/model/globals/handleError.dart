import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';

import '../enums/message_type_enum.dart';
import '../objects/error_object.dart';

void handleError({required Object? error, required BuildContext context}) {
  if (error is ErrorObject) {
    if (error.statusCode == HttpStatus.notFound) {
      FloatingMessage.show(
        context: context,
        text: 'No encontrado',
        messageTypeEnum: MessageTypeEnum.warning,
      );
    } else {
      FloatingMessage.show(
        context: context,
        text: error.message ?? 'Error ${error.statusCode}',
        messageTypeEnum: _getMessageType(error),
      );
    }
    if (kDebugMode) {
      print(error.message ?? 'Error ${error.statusCode}');
    }
  } else {
    genericError(error!, context, isFloatingMessage: true);
    if (kDebugMode) {
      print('Error: ${error.toString()}');
    }
  }
}

MessageTypeEnum _getMessageType(ErrorObject error) {
  return error.message != null && ! error.message!.contains('Sesión expirada')
        ? MessageTypeEnum.warning
        : MessageTypeEnum.error;
}