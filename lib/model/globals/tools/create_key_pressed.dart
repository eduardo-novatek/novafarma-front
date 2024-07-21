import 'package:flutter/services.dart';

bool isEscape() =>
    HardwareKeyboard.instance.logicalKeysPressed.any((key) => key == LogicalKeyboardKey.escape);

bool isEnter() =>
    HardwareKeyboard.instance.logicalKeysPressed.any((key) => key == LogicalKeyboardKey.enter);

