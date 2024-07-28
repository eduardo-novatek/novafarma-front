import 'package:flutter/cupertino.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

Future<int> message({
  String? title,
  required String message,
  required BuildContext context}) async {

  return await OpenDialog(
    context: context,
    title: title ?? 'Atención',
    content: message,
  ).view();
}
