import 'package:flutter/services.dart';

bool isEscape() =>
    HardwareKeyboard.instance.logicalKeysPressed.any((key) => key == LogicalKeyboardKey.escape);

