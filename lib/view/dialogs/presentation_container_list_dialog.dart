import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/presentation_dto.dart';
import '../../model/globals/constants.dart' show uriPresentationFindName, uriPresentationFindNameOnly;
import '../../model/globals/tools/create_key_pressed.dart' show isEscape;
import '../../model/globals/tools/fetch_data.dart';
import '../../model/globals/tools/fetch_data_object.dart';

///Dado el nombre un envase, carga una lista de envases (presentaciones) que
///coincida parcialmente en su nombre. Devuelve la presentacion seleccionada o
///null si canceló o no hay coincidencias.
Future<PresentationDTO?> presentationContainerListDialog({
  required String presentationContainerName,
  required BuildContext context,}) async {

  PresentationDTO? containerSelected;

  await fetchDataObject<PresentationDTO>(
    uri: '$uriPresentationFindName/$presentationContainerName',
    classObject: PresentationDTO.empty()
  ).then((data) async {
    containerSelected = await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _ContainerNamesDialog(
            presentationList: data as List<PresentationDTO>,
           // presentationFind: presentationContainerName,
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
      genericError(error!, context);
    }
  });
  return Future.value(containerSelected);
}

///Devuelve el envase seleccionado o null si cancela
class _ContainerNamesDialog extends StatefulWidget {
  //final PresentationDTO presentationFind;
  final List<PresentationDTO> presentationList;

  const _ContainerNamesDialog({
   // required this.presentationFind,
    required this.presentationList
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
            itemCount: widget.presentationList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  '${widget.presentationList[index].name!} '
                  '${widget.presentationList[index].quantity!} '
                  '${widget.presentationList[index].unitName!} '
                ),
                onTap: () => Navigator.of(context).pop(
                    widget.presentationList[index]
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
