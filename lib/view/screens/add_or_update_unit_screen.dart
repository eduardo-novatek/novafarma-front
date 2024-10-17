import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/unit_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show defaultFirstOption,
  defaultLastOption, uriUnitFindAll;
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/requests/add_or_update_unit.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/unit_add_dialog.dart';
import '../dialogs/unit_list_dialog.dart';

class AddOrUpdateUnitScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;
  final ValueChanged<bool>? onBlockedStateChange;

  const AddOrUpdateUnitScreen({
    super.key,
    this.onBlockedStateChange,
    required this.onCancel,
  });

  @override
  State<AddOrUpdateUnitScreen> createState() => _AddOrUpdatePresentationScreen();
}

class _AddOrUpdatePresentationScreen extends State<AddOrUpdateUnitScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentNameController = TextEditingController();
  final _newNameController = TextEditingController();

  final _currentNameFocusNode = FocusNode();
  final _newNameFocusNode = FocusNode();

  bool? _isAdd; // true: add, false: update, null: hubo error
  bool _isLoading = false;

  final List<UnitDTO> _unitList = [];
  int _unitId = 0;

  @override
  void initState() {
    super.initState();
    _loadUnits(true);
    _createListeners();
    _initialize();
  }

  @override
  void dispose() {
    _currentNameController.dispose();
    _newNameController.dispose();

    _currentNameFocusNode.dispose();
    _newNameFocusNode.dispose();

    _currentNameFocusNode.removeListener(_currentContainerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                AbsorbPointer(
                    absorbing: _isLoading,
                    child:
                      Column(
                        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño vertical al contenido
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTitleBar(),
                          _buildBody(),
                          _buildFooter(),
                        ],
                      ),
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      child: buildCircularProgress(size: 30.0)
                      ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar() {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'Agregar o actualizar unidades de medida',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, right: 8.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño vertical al contenido
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 190,
              child: CustomTextFormField(
                label: 'Unidad',
                controller: _currentNameController,
                focusNode: _currentNameFocusNode,
                dataType: DataTypeEnum.text,
                maxValueForValidation: 4,
                viewCharactersCount: false,
                textForValidation: 'Máximo 4 caracteres',
                acceptEmpty: false,
                initialFocus: true,
                onEditingComplete: () async {
                  //Borra el evento del listener para evitar la doble llamada
                  //a _searchContainerName, que se desencadenaría en el listener
                  _currentNameFocusNode.removeListener(_currentContainerListener);
                  _currentNameFocusNode.unfocus();
                  await _searchUnitName();
                  _currentNameFocusNode.addListener(_currentContainerListener);
                }
              ),
            ),
            const SizedBox(height: 16,),
            SizedBox(
              width: 190,
              child: CustomTextFormField(
                  label: 'Nueva unidad',
                  controller: _newNameController,
                  focusNode: _newNameFocusNode,
                  enabled: _isAdd != null && ! _isAdd!, //Se habilita si es una modificacion
                  dataType: DataTypeEnum.text,
                  maxValueForValidation: 4,
                  viewCharactersCount: false,
                  textForValidation: '',
                  acceptEmpty: true,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_currentNameFocusNode);
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchUnitName() async {
    if (_currentNameController.text.trim().isEmpty) return;
    _changeStateLoading(true);
    UnitDTO? unitSelected = await unitListDialog(
      unitName: _currentNameController.text.trim(),
      context: context,
    );
    _changeStateLoading(false);
    if (unitSelected != null) {
      _unitId = unitSelected.unitId!;
      _currentNameController.value = TextEditingValue(
          text: unitSelected.name!
      );
      _newNameController.value = TextEditingValue(
          text: unitSelected.name!
      );
      setState(() {
        _isAdd = false;
      });
    } else {
      _newNameController.value = const TextEditingValue(text: '');
      _unitId = 0;
      setState(() {
        _isAdd = true;
      });
    }

    //addPostFrameCallback garantiza que la asignación del foco ocurra después
    //de que se complete el renderizado del cuadro de texto.
    //Otra opción sería mediante Future.delayed...
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_newNameFocusNode);
      }
    });
  }

 /* Future<void> _searchQuantities() async {
    if (_currentNameController.text.trim().isEmpty) return;
    _changeStateLoading(true);
    double? quantitySelected = await presentationContainerQuantitiesListDialog(
      presentationContainerName: _currentNameController.text.trim(),
      context: context,
    );
    _changeStateLoading(false);
    if (quantitySelected != null) {
      _quantityController.value = TextEditingValue(text: quantitySelected.toString());
      setState(() {
        _isAdd = false;
      });
    }
    //addPostFrameCallback garantiza que la asignación del foco ocurra después
    //de que se complete el renderizado del cuadro de texto.
    //Otra opción sería mediante Future.delayed...
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_unitNameFocusNode);
        FocusScope.of(context).nextFocus();
      }
    });
  }*/

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _disableAcceptButton() ? null : () async {
            //onPressed: () async {
              if (! _formKey.currentState!.validate()) return; //Valida el resto del formulario
              if (await _confirm() == 1) {
                _submitForm();
              }
            },
            child: const Text('Aceptar'),
          ),
          const SizedBox(width: 16.0,),
          ElevatedButton(
            onPressed: () async {
              if (await _cancel() == 1) {
                _cancelForm();
              }
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  bool _disableAcceptButton() => _isAdd == null;

  Future<void> _submitForm() async {
    _changeStateLoading(true);
    try {
      UnitDTO unitDTO = UnitDTO(
          unitId: _unitId == 0 ? null : _unitId,
          name: _newNameController.text.trim().isEmpty
              ? _currentNameController.text.trim()
              : _newNameController.text.trim(),
      );
      if (mounted) {
        //Actualiza la var. publica con el id de la nueva unidad agregada
        _unitId = (await addOrUpdateUnit(
          unit: unitDTO,
          isAdd: _isAdd!,
          context: context,
        ))!;
      }
      if (_unitId != 0) {
        if (mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Unidad de medida ${_isAdd! ? 'agregada' : 'actualizada'} con éxito',
              messageTypeEnum: MessageTypeEnum.info
          );
        }
        if (kDebugMode) {
          print('Unidad de medida  ${_isAdd! ? 'agregada' : 'actualizada'} '
              'con éxito (id=$_unitId)'
        );
        }
        _initialize();
        if (mounted) FocusScope.of(context).requestFocus(_currentNameFocusNode);

      } else {
        if(mounted) {
          FloatingMessage.show(
            context: context,
            text: 'Error creando o actualizando unidad de medida ',
            messageTypeEnum: MessageTypeEnum.error,
          );
        }
        if (kDebugMode) print('Error creando o actualizando unidad de medida ');
      }

    } catch (error) {
      if (mounted) handleError(error: error, context: context);
      _changeStateLoading(false);
      return;
    }
    _changeStateLoading(false);
  }

  void _cancelForm() {
    widget.onCancel(); // Llamar al callback de cancelación
  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: _isAdd!
          ? '¿Agregar la unidad de medida?'
          : '¿Actualizar la unidad de medida?',
        textButton1: 'Si',
        textButton2: 'No',
        context: context
    ).view();
  }

  Future<int> _cancel() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: '¿Cancelar y cerrar el formulario?',
        textButton1: 'Si',
        textButton2: 'No',
        context: context
    ).view();
  }

  void _createListeners() {
    _currentNameFocusNode.addListener(_currentContainerListener);
  }

  Future<void> _currentContainerListener() async {
    if (!_currentNameFocusNode.hasFocus) {
      await _searchUnitName();
    } else if (_currentNameFocusNode.hasFocus) {
      _initialize();
    }
  }

  ///Antes de actualizar la var. _unitSelected, chequea que la unidad de medida
  ///exista en la lista. Si no existe, refresca las unidades.
  /*Future<void> _updateUnitSelected(String unitName) async {
    if (! _unitExistInList(unitName)) {
      await _loadUnits(false);
      if (! _unitExistInList(unitName)) {
        if (mounted) {
          message(
            message: 'La unidad de medida $unitName '
                'no existe o no se pudo cargar.\n'
                'Contacte al administrador del sistema.',
            context: context
          );
        }
        return Future.value();
      }
    }
    //La unidad de medida existe en la lista, actualizo la variable.
    setState(() {
      _unitSelected = unitName;
    });
  }*/

  /*bool _unitExistInList(String unitName) {
    UnitDTO unit = _unitList.firstWhere(
      (e) => e.name == unitName,
      orElse: () => UnitDTO.empty(),
    );
    return unit.name != null;
  }*/

  void _initialize() {
    _currentNameController.value = TextEditingValue.empty;
    _newNameController.value = TextEditingValue.empty;
    _unitId = 0;
    setState(() {
      _isAdd = null;
    });
  }

  void _changeStateLoading(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
    widget.onBlockedStateChange!(isLoading);
  }

  Future<void> _loadUnits(bool isInitState) async {
    if (isInitState && mounted) {
        setState(() {
          _isLoading = true;
        });
    } else {
      _changeStateLoading(true);
    }
    await fetchDataObject<UnitDTO>(
      uri: uriUnitFindAll,
      classObject: UnitDTO.empty(),
    ).then((data) {
      _unitList.clear();
      if (mounted) {
        setState(() {
          _unitList.add(UnitDTO(unitId: 0, name: defaultFirstOption));
          _unitList.addAll(
              data.cast<UnitDTO>().map((e) =>
                  UnitDTO(unitId: e.unitId, name: e.name))
          );
          _unitList.add(UnitDTO(unitId: -1, name: defaultLastOption));
        });
      }

    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        if (error.statusCode != HttpStatus.notFound && mounted) {
          if (mounted) handleError(error: error, context: context);
        }
      }
    });

    if (isInitState && mounted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _changeStateLoading(false);
    }
  }

  /*Widget _buildRefreshUnitsButton() {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        onPressed: () async {
          if (!_isLoading) {
            // llama al callback: esta haciendo el refresh...
            if (widget.onBlockedStateChange != null) {
              widget.onBlockedStateChange!(true);
            }
            await _loadUnits(false);
            setState(() {
              _unitSelected = defaultFirstOption;
            });
            // llama al callback: no está haciendo el refresh...
            if (widget.onBlockedStateChange != null) {
              widget.onBlockedStateChange!(false);
            }
          }
        },
        icon: const Tooltip(
          message: 'Recargar unidades',
          child: Icon(
            Icons.refresh_rounded,
            color: Colors.blue,
            size: 16.0,
          ),
        ),
      ),
    );
  }*/

  Future<void> _addUnit() async {
    final String? unit = await unitAddDialog(context: context);
    if (unit != null) {
      await _loadUnits(false).then((_) {
    });
    }
  }

}
