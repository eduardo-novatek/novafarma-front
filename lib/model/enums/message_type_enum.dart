import 'dart:ui';

import 'package:flutter/material.dart';

enum MessageTypeEnum {
  info, warning, error
}

Color getColorMessage(MessageTypeEnum messageTypeEnum) {
  if (messageTypeEnum == MessageTypeEnum.info) {
    return Colors.green.shade100;
  } else if (messageTypeEnum == MessageTypeEnum.warning) {
    return Colors.yellow.shade100;
  } else { // error
    return Colors.red.shade100;
  }
}

Icon getIconMessage(MessageTypeEnum messageTypeEnum) {
  if (messageTypeEnum == MessageTypeEnum.info) {
    return const Icon(
      Icons.info_outline,
      color: Colors.green,
      size: 40.0,
    );

  } else if (messageTypeEnum == MessageTypeEnum.warning) {
    return const Icon(
      Icons.warning_outlined,
      color: Colors.yellow,
      size: 40.0,
    );

  } else { // error
    return const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 40.0,
    );
  }

}
