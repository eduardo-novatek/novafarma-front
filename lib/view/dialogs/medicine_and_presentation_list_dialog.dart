import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto3.dart';
import 'package:novafarma_front/model/globals/controlled_icon.dart';

import '../../model/enums/message_type_enum.dart';
import '../../model/globals/constants.dart' show sizePageMedicineAndPresentationList, uriMedicineFindNamePage;
import '../../model/globals/tools/fetch_data_pageable.dart';
import '../../model/globals/tools/floating_message.dart';
import '../../model/globals/tools/pagination_bar.dart';
import '../../model/objects/error_object.dart';

///Dado el nombre de un medicamento, carga una lista de medicamentos que
///coincida parcialmente en su nombre, y cada uno con sus diferentes presentaciones.
///Devuelve el medicamento seleccionado o  null si canceló.
Future<MedicineDTO3?> medicineAndPresentationListDialog(
    {required String medicineName, required BuildContext context,}) async {

  MedicineDTO3? medicineSelected = await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _MedicineDialog(medicineName: medicineName),
        );
      }
  );
  return Future.value(medicineSelected);
}

class _MedicineDialog extends StatefulWidget {
  //final Function(MedicineDTO3?) onSelect;
  final String medicineName;

  const _MedicineDialog({
    required this.medicineName,
    //required this.onSelect,
  });

  @override
  State<_MedicineDialog> createState() => _MedicineDialogState();
}

class _MedicineDialogState extends State<_MedicineDialog> {
  final List<MedicineDTO3> medicines = [];

  bool _loading = true;

  final Map<String, int> _metadata = {
    'pageNumber': 0,
    'totalPages': 0,
    'totalElements': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadMedicines(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Esquinas rectas
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.7,
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
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: medicines[index].controlled!
                    ? controlledIcon()
                    : const SizedBox.shrink(),
                title: Text('${medicines[index].name} '
                    '${medicines[index].presentation!.name} '
                    '${medicines[index].presentation!.quantity} '
                    '${medicines[index].presentation!.unitName}'
                ),
                onTap: () => Navigator.of(context).pop(medicines[index]),
              );
            },
          )

        ),
        const Divider(),
        _buildButtonsPage(context),
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

  Widget _buildButtonsPage(BuildContext context) {
    return _metadata['totalPages'] != 0
      ? PaginationBar(
          totalPages: _metadata['totalPages']!,
          initialPage: _metadata['pageNumber']! + 1,
          onPageChanged: (page) {
              _metadata['pageNumber'] = page - 1;
              _loadMedicines(context);
          },
        )
      : const SizedBox.shrink();
  }

  ///Carga la lista de medicamentos segun el nombre ingresado
  Future<void> _loadMedicines(BuildContext context) async {
    setLoading(true);
    await fetchDataPageable<MedicineDTO3>(
        uri: '$uriMedicineFindNamePage/${widget.medicineName}'
            '/true' //isLike = true (busqueda con LIKE)
            '/${_metadata['pageNumber']!}'
            '/$sizePageMedicineAndPresentationList',
        classObject: MedicineDTO3.empty(),
      ).then((pageObject) {
          if (pageObject.totalElements == 0) {
            Navigator.of(context).pop(null);
            return;
          }
          medicines.clear();
          medicines.addAll(pageObject.content as Iterable<MedicineDTO3>);
          _metadata['pageNumber'] = pageObject.pageNumber;
          _metadata['totalPages'] = pageObject.totalPages;
          _metadata['totalElements'] = pageObject.totalElements;
      }).onError((error, stackTrace) {
        String? msg;
        if (error is ErrorObject) {
          msg = error.message;
        } else {
          msg = error.toString().contains('XMLHttpRequest error')
              ? 'Error de conexión'
              : error.toString();
        }
        if (msg != null) {
          FloatingMessage.show(
            context: context,
            text: msg,
            messageTypeEnum: MessageTypeEnum.error,
          );
          if (kDebugMode) print(error);
        }
      });
    setLoading(false);
  }

  void setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }
}
