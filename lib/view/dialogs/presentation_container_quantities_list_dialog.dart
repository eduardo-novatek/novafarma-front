import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/globals/constants.dart' show uriPresentationFindNameOnly, uriPresentationFindQuantities;
import '../../model/globals/tools/create_key_pressed.dart' show isEscape;
import '../../model/globals/tools/fetch_data.dart';

///Dado el nombre un envase, carga una lista cantidades relacionadas a dicho
///envase que (coincida parcial en su nombre). Devuelve la cantiad seleccionada
///o null si canceló o no existe el envase.
Future<double?> presentationContainerQuantitiesListDialog({
  required String presentationContainerName,
  required BuildContext context,}) async {

  double? quantitySelected;

  await fetchData<String>(
    uri: '$uriPresentationFindQuantities/$presentationContainerName'
  ).then((data) async {
    quantitySelected = await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _QuantitiesDialog(
            quantityList: data as List<double>,
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
  return Future.value(quantitySelected);
}

///Devuelve el envase seleccionado o null si cancela
class _QuantitiesDialog extends StatefulWidget {
  final List<double> quantityList;

  const _QuantitiesDialog({
    required this.quantityList
  });

  @override
  State<_QuantitiesDialog> createState() => _QuantitiesDialogState();
}

class _QuantitiesDialogState extends State<_QuantitiesDialog> {
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
            itemCount: widget.quantityList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.quantityList[index].toString()),
                onTap: () => Navigator.of(context).pop(
                    widget.quantityList[index]
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
