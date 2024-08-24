
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/medicine_dto2.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/DTOs/unit_dto.dart';
import 'package:novafarma_front/model/DTOs/unit_dto_1.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show defaultFirstOption,
  defaultLastOption, uriUnitFindAll;
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/requests/add_or_update_medicine.dart';
import 'package:novafarma_front/model/globals/requests/add_or_update_presentation.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
import 'package:novafarma_front/model/globals/requests/fetch_presentation_id.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/message.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/dialogs/presentation_container_list_dialog.dart';
import 'package:novafarma_front/view/dialogs/presentation_container_quantities_list_dialog.dart';

import '../../model/DTOs/medicine_dto1.dart';
import '../../model/DTOs/presentation_dto_1.dart';
import '../../model/globals/publics.dart' show userLogged;
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/medicine_and_presentation_list_dialog.dart';
import '../dialogs/presentation_name_container_name_list_dialog.dart';
import '../dialogs/unit_show_dialog.dart';

class AddOrUpdatePresentationScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;
  final ValueChanged<bool>? onBlockedStateChange;

  const AddOrUpdatePresentationScreen({
    super.key,
    this.onBlockedStateChange,
    required this.onCancel,
  });

  @override
  State<AddOrUpdatePresentationScreen> createState() => _AddOrUpdatePresentationScreen();
}

class _AddOrUpdatePresentationScreen extends State<AddOrUpdatePresentationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formBarCodeKey = GlobalKey<FormState>();

  final _currentContainerController = TextEditingController();
  final _newNameController = TextEditingController();
  final _quantityController = TextEditingController();

  final _currentContainerFocusNode = FocusNode();
  final _newNameFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();
  final _unitNameFocusNode = FocusNode();

  bool? _isAdd; // true: add, false: update, null: hubo error
  bool _isLoading = false;

  final List<UnitDTO> _unitList = [
    UnitDTO(unitId: 0, name: defaultFirstOption)
  ];
  String _unitSelected = defaultFirstOption;
  int _presentationId = 0;

  @override
  void initState() {
    super.initState();
    _loadUnits(true);
    _createListeners();
    _initialize();
  }

  @override
  void dispose() {
    _currentContainerController.dispose();
    _newNameController.dispose();
    _quantityController.dispose();

    _currentContainerFocusNode.dispose();
    _newNameFocusNode.dispose();
    _quantityFocusNode.dispose();
    _unitNameFocusNode.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.35,
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
        'Agregar o actualizar presentaciones',
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
              child: CreateTextFormField(
                label: 'Envase',
                controller: _currentContainerController,
                focusNode: _currentContainerFocusNode,
                dataType: DataTypeEnum.text,
                maxValueForValidation: 20,
                viewCharactersCount: false,
                textForValidation: 'Máximo 20 caracteres',
                acceptEmpty: false,
                onEditingComplete: () async {
                  _currentContainerFocusNode.removeListener(() =>
                    _currentContainerListener
                  );
                  await _searchContainerName();
                  _currentContainerFocusNode.addListener(() =>
                    _currentContainerListener
                  );
                }
              ),
            ),
            const SizedBox(height: 16,),
            SizedBox(
              width: 190,
              child: CreateTextFormField(
                  label: 'Nuevo envase',
                  controller: _newNameController,
                  focusNode: _newNameFocusNode,
                  enabled: _isAdd != null && ! _isAdd!, //Se habilita si es una modificacion
                  dataType: DataTypeEnum.text,
                  maxValueForValidation: 20,
                  viewCharactersCount: false,
                  textForValidation: '',
                  acceptEmpty: true,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(_quantityFocusNode);
                  },
              ),
            ),
            const SizedBox(height: 16,),
            SizedBox(
              width: 160,
              child: CreateTextFormField(
                label: 'Cantidad',
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                dataType: DataTypeEnum.number,
                minValueForValidation: 0,
                maxValueForValidation: 99999.99,
                viewCharactersCount: false,
                textForValidation: 'Requerido (máx: 99999.99)',
                acceptEmpty: false,
                onEditingComplete: () {
                  _searchQuantities();
                },
              ),
            ),
            const SizedBox(height: 16,),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Unidad',
                          style: TextStyle(fontSize: 12),
                        ),
                        _buildRefreshUnitsButton(),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: CustomDropdown<String>(
                      focusNode: _unitNameFocusNode,
                      themeData: ThemeData(),
                      optionList:  _unitList.map((e) => e.name).toList(),
                      selectedOption: _unitSelected,
                      isSelected: true, //! _isAdd!,
                      callback: (unit) {
                        if (unit == defaultLastOption) _addUnit();
                        if (mounted) {
                          setState(() {
                            _unitSelected  = unit!;
                          });
                        }
                        // Callback function
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchContainerName() async {
    if (_currentContainerController.text.trim().isEmpty) return;
    _changeStateLoading(true);
    PresentationDTO? presentationSelected = await presentationContainerListDialog(
        presentationContainerName: _currentContainerController.text.trim(),
        context: context,
    );
    _changeStateLoading(false);
    if (presentationSelected != null) {
      _presentationId = presentationSelected.presentationId!;
      _currentContainerController.value = TextEditingValue(
          text: presentationSelected.name!
      );
      _newNameController.value = TextEditingValue(
          text: presentationSelected.name!
      );
      _quantityController.value = TextEditingValue(
          text: presentationSelected.quantity!.toString()
      );
      _updateUnitSelected(presentationSelected.unitName!);
      setState(() {
        _isAdd = false;
      });
    } else {
      _newNameController.value = const TextEditingValue(text: '');
      _presentationId = 0;
      setState(() {
        _isAdd = true;
      });
    }

    //addPostFrameCallback garantiza que la asignación del foco ocurra después
    //de que se complete el renderizado del cuadro de texto.
    //Otra opción sería mediante Future.delayed...
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_isAdd!
            ? _quantityFocusNode
            : _newNameFocusNode
        );
      }
    });
  }

  Future<void> _searchQuantities() async {
    if (_currentContainerController.text.trim().isEmpty) return;
    _changeStateLoading(true);
    double? quantitySelected = await presentationContainerQuantitiesListDialog(
      presentationContainerName: _currentContainerController.text.trim(),
      context: context,
    );
    _changeStateLoading(false);
    //_isAdd = true;
    if (quantitySelected != null) {
      _quantityController.value = TextEditingValue(text: quantitySelected.toString());
      _isAdd = false;
    }
    if (mounted) FocusScope.of(context).requestFocus(_quantityFocusNode);
  }


  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _disableAcceptButton() ? null : () async {
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

  bool _disableAcceptButton() =>
    _currentContainerController.text.trim().isEmpty
      || _quantityController.text.trim().isEmpty
      || _unitSelected == defaultFirstOption
      || _unitSelected == defaultLastOption;
  /*_isAdd == null
      || _nameController.text.trim().isEmpty
      || _quantityController.text.trim().isEmpty
      || _unitSelected == defaultFirstOption
      || _unitSelected == defaultLastOption;*/

  Future<void> _submitForm() async {
    _changeStateLoading(true);
    try {
      PresentationDTO1 presentationDTO1 = PresentationDTO1(
          presentationId: _presentationId == 0 ? null : _presentationId,
          name: _newNameController.text.trim().isEmpty
              ? _currentContainerController.text.trim()
              : _newNameController.text.trim(),
          quantity: double.parse(_quantityController.text),
          unit: UnitDTO1(unitId: _getSelectedUnitId())
      );

      if (mounted) {
        //Actualiza la var. publica con el id de la nueva presentacion agregada
        _presentationId = await addOrUpdatePresentation(
          presentation: presentationDTO1,
          isAdd: _isAdd!,
          context: context,
        );
      }
      if (_presentationId != 0) {
        if (mounted) {
          FloatingMessage.show(
              context: context,
              text: 'Presentación ${_isAdd! ? 'agregada' : 'actualizada'} con éxito',
              messageTypeEnum: MessageTypeEnum.info
          );
        }
        if (kDebugMode) {
          print('Presentación ${_isAdd! ? 'agregada' : 'actualizada'} '
              'con éxito (id=$_presentationId)'
        );
        }
        _initialize();

      } else {
        if(mounted) {
          FloatingMessage.show(
            context: context,
            text: 'Error creando o actualizando presentación',
            messageTypeEnum: MessageTypeEnum.error,
          );
        }
        if (kDebugMode) print('Error creando o actualizando presentación');
      }

    } catch (error) {
      if (error is ErrorObject) {
        if (error.message != null) {
          String msg = error.message!;
          if (error.message!.contains("NO EXISTE UNA UNIDAD DE MEDIDA")) {
            msg = 'La unidad de medida $_unitSelected fué eliminada por '
                'otro usuario.\nLa lista ha sido actualizada.';
            _loadUnits(false);
            setState(() {
              _unitSelected = defaultFirstOption;
            });
          }
          if (mounted) {
            FloatingMessage.show(
              context: context,
              text: msg,
              messageTypeEnum: MessageTypeEnum.warning,
            );
          }
        }
      } else {
        if (mounted) genericError(error, context);
      }
      _changeStateLoading(false);
      return;
    }
    _changeStateLoading(false);
  }

  //Devuelve el id de la unidad de medidad seleccionada
  int? _getSelectedUnitId() => _unitList.firstWhere((element)
    => element.name == _unitSelected).unitId;

  void _cancelForm() {
    widget.onCancel(); // Llamar al callback de cancelación
  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: _isAdd! ? '¿Agregar la presentación?' : '¿Actualizar la presentación?',
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
    _currentContainerFocusNode.addListener(() => _currentContainerListener);
    //_currentContainerListener();
  }

  void _currentContainerListener() {
    //_currentContainerFocusNode.addListener(() {
      if (!_currentContainerFocusNode.hasFocus) {
        _searchContainerName();
      } else if (_currentContainerFocusNode.hasFocus) {
        _initialize();
      }
    //});
  }

  /// true/false si el codigo de barras ya existe/no existe;
  /// null si se lanzó un error.
  /*Future<bool?> _isRegisteredBarCode() async {
    bool? registered = false;
    MedicineDTO1? medicine = MedicineDTO1.empty();

    _changeStateLoading(true);
    try {
      await fetchMedicineBarCode(
          barCode: _barCodeController.value.text.trim(),
          medicine: medicine,
      );
      if (medicine.medicineId != null) {
        if (! medicine.deleted!) {
          _updateFields(medicine);
          registered = true;
        } else {
          throw ErrorObject(
            statusCode: HttpStatus.conflict,
            message: 'El medicamento está eliminado'
          );
        }
      }

    } catch (error) {
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {
          registered = false;
        } else {
          registered = null;
          if (error.message!.contains('El medicamento está eliminado')) {
            FloatingMessage.show(
              context: context,
              text: error.message!,
              messageTypeEnum: MessageTypeEnum.warning
            );
          } else {
            await OpenDialog(
                context: context,
                title: 'Error',
                content: error.message != null
                    ? error.message!
                    : 'Error ${error.statusCode}'
            ).view();
          }
        }
      } else {
        registered = null;
        if (error.toString().contains('XMLHttpRequest error')) {
          await OpenDialog(
            context: context,
            title: 'Error de conexión',
            content: 'No es posible conectar con el servidor',
          ).view();
        } else {
          if (error.toString().contains('TimeoutException')) {
            await OpenDialog(
              context: context,
              title: 'Error de conexión',
              content: 'No es posible conectar con el servidor.\nTiempo expirado.',
            ).view();
          } else {
            await OpenDialog(
              context: context,
              title: 'Error desconocido',
              content: error.toString(),
            ).view();
          }
        }
      }
    } finally {
      _changeStateLoading(false);
    }
    if (registered == null && mounted) {
      FocusScope.of(context).removeListener(() {_barCodeFocusNode;});
      FocusScope.of(context).requestFocus(_barCodeFocusNode);
      FocusScope.of(context).addListener(() {_barCodeFocusNode;});
    }
    return Future.value(registered);
  }*/

  /*
  /// true/false si el medicamento (nombre+presentacion) ya existe/no existe;
  /// null si se lanzó un error.
  Future<bool?> _isRegisteredMedicine() async {
    bool? registered = false;
    List<MedicineDTO1> medicineList = [];

    _changeStateLoading(true);
    try {
      await fetchSupplierList(
          supplierList: medicineList,
          uri: '$uriSupplierFindName/${_nameController.text.trim()}'
      );
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SupplierSelectionDialog(
            suppliers: medicineList,
            onSelect: (index) {
              //Si no canceló
              if (index != -1) {
                _updateFields(medicineList[index]);
                registered = true;
                //Canceló...Si encontró solo uno y es el mismo nombre...
              } else if (medicineList.length == 1
                  && _nameController.text.trim().toUpperCase()
                      == medicineList[0].name) {
                registered = null;
              }
            },
          );
        }
      );
    } catch (error) {
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {
          registered = false;
        } else {
          registered = null;
          await OpenDialog(
              context: context,
              title: 'Error',
              content: error.message != null
                  ? error.message!
                  : 'Error ${error.statusCode}'
          ).view();
        }
      } else {
        registered = null;
        if (error.toString().contains('XMLHttpRequest error')) {
          await OpenDialog(
            context: context,
            title: 'Error de conexión',
            content: 'No es posible conectar con el servidor',
          ).view();
        } else {
          if (error.toString().contains('TimeoutException')) {
            await OpenDialog(
              context: context,
              title: 'Error de conexión',
              content: 'No es posible conectar con el servidor.\nTiempo expirado.',
            ).view();
          } else {
            await OpenDialog(
              context: context,
              title: 'Error desconocido',
              content: error.toString(),
            ).view();
          }
        }
      }
    } finally {
      _changeStateLoading(false);
    }
    if (registered == null && mounted) {
      FocusScope.of(context).removeListener(() {_nameFocusNode;});
      FocusScope.of(context).requestFocus(_nameFocusNode);
      FocusScope.of(context).addListener(() {_nameFocusNode;});
    }

    return Future.value(registered);
  }
*/

  ///Antes de actualizar la var. _unitSelected, chequea que la unidad de medida
  ///exista en la lista. Si no existe, refresca las unidades.
  Future<void> _updateUnitSelected(String unitName) async {
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
  }

  bool _unitExistInList(String unitName) {
    UnitDTO unit = _unitList.firstWhere(
      (e) => e.name == unitName,
      orElse: () => UnitDTO.empty(),
    );
    return unit.name != null;
  }

  void _initialize() {
    _currentContainerController.value = TextEditingValue.empty;
    _newNameController.value = TextEditingValue.empty;
    _quantityController.value = TextEditingValue.empty;
    _presentationId = 0;
    setState(() {
      _unitSelected = defaultFirstOption;
      _isAdd = null;
    });
  }

  void _changeStateLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
    widget.onBlockedStateChange!(isLoading);
  }

  Future<void> _loadUnits(bool isInitState) async {
    if (isInitState) {
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
      genericError(error!, context);
    });

    if (isInitState) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _changeStateLoading(false);
    }
  }

  Widget _buildRefreshUnitsButton() {
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
  }

  Future<void> _addUnit() async {
    final String? unit = await unitShowDialog(context: context);
    if (unit != null) {
      await _loadUnits(false).then((_) {
        if (mounted) {
          setState(() {
            _unitSelected = unit;
          });
        }
      });
    }
  }


}
