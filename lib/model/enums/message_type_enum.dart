import 'dart:ui';

import 'package:flutter/material.dart';

enum MessageTypeEnum {
  info, warning, error
}

Color getColorMessage(MessageTypeEnum messageTypeEnum) {
  if (messageTypeEnum == MessageTypeEnum.info) {
    return Colors.green;
  } else if (messageTypeEnum == MessageTypeEnum.warning) {
    return Colors.yellowAccent.shade100;
  } else { // error
    return Colors.redAccent;
  }



}