import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/DTOs/unit_dto.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/globals/constants.dart' show uriUnitFindNameLike;
import '../../model/globals/tools/create_key_pressed.dart' show isEscape;
import '../../model/globals/tools/fetch_data_object.dart';

///Dado el nombre una unidad, carga una lista de unidades que coincida
///parcialmente en su nombre. Devuelve la unidad seleccionada o
///null si canceló o no hay coincidencias.
Future<UnitDTO?> unitListDialog({
  required String unitName,
  required BuildContext context,}) async {

  UnitDTO? unitSelected;

  await fetchDataObject<UnitDTO>(
    uri: '$uriUnitFindNameLike/$unitName',
    classObject: UnitDTO.empty()
  ).then((data) async {
    unitSelected = await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _UnitNamesDialog(unitList: data as List<UnitDTO>),
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
      handleError(error: error, context: context);
    }
  });
  return Future.value(unitSelected);
}

///Devuelve el envase seleccionado o null si cancela
class _UnitNamesDialog extends StatefulWidget {
  final List<UnitDTO> unitList;

  const _UnitNamesDialog({
    required this.unitList
  });

  @override
  State<_UnitNamesDialog> createState() => _UnitNamesDialogState();
}

class _UnitNamesDialogState extends State<_UnitNamesDialog> {
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
            itemCount: widget.unitList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.unitList[index].name!),
                onTap: () => Navigator.of(context).pop(
                    widget.unitList[index]
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
