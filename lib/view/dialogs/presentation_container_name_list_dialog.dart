import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/globals/constants.dart' show uriPresentationFindNameOnly;
import '../../model/globals/tools/create_key_pressed.dart' show isEscape;
import '../../model/globals/tools/fetch_data.dart';

///Dado el nombre de un medicamento, carga una lista de medicamentos que
///coincida parcialmente en su nombre, y cada uno con sus diferentes presentaciones.
///Devuelve el medicamento seleccionado o null si canceló o no hay coincidencias.
Future<String?> presentationContainerNameListDialog({
  required String presentationContainerName,
  required BuildContext context,}) async {

  String? containerSelected;

 /* await fetchPresentationNameList(
      presentationName: presentationContainerName,
      context: context
  ).then((data) async {
  */
  await fetchData<String>(
    uri: '$uriPresentationFindNameOnly/$presentationContainerName'
  ).then((data) async {
    containerSelected = await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _ContainerNamesDialog(
            presentationContainerList: data,
            presentationContainerName: presentationContainerName,
          ),
        );
      }
    );
  }).onError((error, stackTrace) {
    String? msg = error.toString();
    if (error is ErrorObject) {
      if (error.statusCode == HttpStatus.notFound) {
        msg = null;
      } else {
        msg = error.message;
      }
    }
    if (msg != null) {
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.error,
          context: context
      );
    }
  });
  return Future.value(containerSelected);
}

///Devuelve el envase seleccionado o null si cancela
class _ContainerNamesDialog extends StatefulWidget {
  final String presentationContainerName;
  final List<String> presentationContainerList;

  const _ContainerNamesDialog({
    required this.presentationContainerName,
    required this.presentationContainerList
  });

  @override
  State<_ContainerNamesDialog> createState() => _ContainerNamesDialogState();
}

class _ContainerNamesDialogState extends State<_ContainerNamesDialog> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    //listener para la tecla Escape
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    // Remueve el listener cuando el diálogo se cierra
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Flexible(child: _buildColumn(context)),
          ]
        ),
      ),
    );
  }

  Column _buildColumn(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8.0,),
        Flexible(
          child: ListView.builder(
            itemCount: widget.presentationContainerList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.presentationContainerList[index]),
                onTap: () => Navigator.of(context).pop(
                    widget.presentationContainerList[index]
                ),
              );
            },
          )

        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: ElevatedButton(
            onPressed: () =>Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
        )
      ]
    );
  }

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent && isEscape()) {
      Navigator.of(context).pop(null);
      return true;
    }
    return false;
  }
}
