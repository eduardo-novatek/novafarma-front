import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto2.dart';
import 'package:novafarma_front/model/globals/controlled_icon.dart';
import 'package:novafarma_front/model/objects/page_object.dart';

import '../../model/globals/requests/fetch_medicine_by_name_list.dart';
import '../../model/globals/tools/create_key_pressed.dart' show isEscape;
import '../../model/globals/tools/pagination_bar.dart';

///Dado el nombre de un medicamento, carga una lista de medicamentos que
///coincida parcialmente en su nombre, y cada uno con sus diferentes presentaciones.
///Devuelve el medicamento seleccionado o null si canceló o no hay coincidencias.
Future<MedicineDTO2?> medicineAndPresentationListDialog(
    {required String medicineName, required BuildContext context,}) async {

  PageObject<MedicineDTO2> pageObject = PageObject.empty();
  await fetchMedicineByNameList(
    medicineName: medicineName,
    isLike: true,
    includeDeleted: false,
    pageObject: pageObject,
    context: context
  );
  if (pageObject.totalElements == 0) return null;
  MedicineDTO2? medicineSelected = await showDialog(
      context: context,
      barrierDismissible: false, //modal
      builder: (BuildContext context) {
        return PopScope( //Evita salida con flecha atras del navegador
          canPop: false,
          child: _MedicineDialog(
            medicineName: medicineName,
            pageObject: pageObject,
          ),
        );
      }
  );
  return Future.value(medicineSelected);
}

///Recibe y actualiza el pageObject
class _MedicineDialog extends StatefulWidget {
  final String medicineName;
  final PageObject<MedicineDTO2> pageObject;

  const _MedicineDialog({
    required this.medicineName,
    required this.pageObject,
  });

  @override
  State<_MedicineDialog> createState() => _MedicineDialogState();
}

class _MedicineDialogState extends State<_MedicineDialog> {
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
            itemCount: widget.pageObject.content.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: widget.pageObject.content[index].controlled!
                    ? controlledIcon()
                    : const SizedBox.shrink(),
                title: Text('${widget.pageObject.content[index].name} '
                  '${widget.pageObject.content[index].presentation!.name} '
                  '${widget.pageObject.content[index].presentation!.quantity} '
                  '${widget.pageObject.content[index].presentation!.unitName}'
                ),
                onTap: () => Navigator.of(context).pop(
                    widget.pageObject.content[index]
                ),
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
    return widget.pageObject.totalPages != 0
      ? PaginationBar(
          totalPages: widget.pageObject.totalPages,
          initialPage:widget.pageObject.pageNumber + 1,
          onPageChanged: (page) async {
            widget.pageObject.pageNumber = page - 1;
            setLoading(true);
            await fetchMedicineByNameList(
                medicineName: widget.medicineName,
                isLike: true,
                includeDeleted: false,
                pageObject: widget.pageObject,
                context: context
            );
            setLoading(false);
          },
        )
      : const SizedBox.shrink();
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
