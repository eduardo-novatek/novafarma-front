import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute == null) {
      // Si no hay una ruta previa, la aplicación se cierra.
      SystemNavigator.pop();
    }
  }
}