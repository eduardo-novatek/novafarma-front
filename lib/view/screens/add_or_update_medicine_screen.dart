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
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/requests/add_or_update_medicine.dart';
import 'package:novafarma_front/model/globals/requests/add_or_update_presentation.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
import 'package:novafarma_front/model/globals/requests/fetch_presentation_id.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/message.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/medicine_dto1.dart';
import '../../model/DTOs/presentation_dto_1.dart';
import '../../model/globals/publics.dart' show userLogged;
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/tools/fetch_data_object.dart';
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/medicine_and_presentation_list_dialog.dart';
import '../dialogs/presentation_name_container_name_list_dialog.dart';
import '../dialogs/unit_add_dialog.dart';

class AddOrUpdateMedicineScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;
  final ValueChanged<bool>? onBlockedStateChange;

  const AddOrUpdateMedicineScreen({
    super.key,
    this.onBlockedStateChange,
    required this.onCancel,
  });

  @override
  State<AddOrUpdateMedicineScreen> createState() => _AddOrUpdateMedicineScreen();
}

class _AddOrUpdateMedicineScreen extends State<AddOrUpdateMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formBarCodeKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _presentationContainerController = TextEditingController();
  final _presentationQuantityController = TextEditingController();
  final _barCodeController = TextEditingController();
  final _lastAddDateController = TextEditingController();
  final _lastCostPriceController = TextEditingController();
  final _lastSalePriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  bool? _controlled;

  final _nameFocusNode = FocusNode();
  final _presentationContainerFocusNode = FocusNode();
  final _presentationQuantityFocusNode = FocusNode();
  final _presentationUnitNameFocusNode = FocusNode();
  final _barCodeFocusNode = FocusNode();
  final _lastAddDateFocusNode = FocusNode();
  final _lastCostPriceFocusNode = FocusNode();
  final _lastSalePriceFocusNode = FocusNode();
  final _currentStockFocusNode = FocusNode();
  final _controlledFocusNode = FocusNode();

  int _medicineId = 0, _presentationId = 0;
  bool? _isAdd; // true: add, false: update, null: hubo error
  bool _isLoading = false;

  final List<UnitDTO> _unitList = [
    UnitDTO(unitId: 0, name: defaultFirstOption),
    UnitDTO(unitId: -1, name: defaultLastOption)
  ];
  String _unitSelected = defaultFirstOption;

  @override
  void initState() {
    super.initState();
    _loadUnits(true);
    _createListeners();
    _initialize(initNameAndPresentation: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _presentationContainerController.dispose();
    _presentationQuantityController.dispose();
    _barCodeController.dispose();
    _lastAddDateController.dispose();
    _lastCostPriceController.dispose();
    _lastSalePriceController.dispose();
    _currentStockController.dispose();

    _nameFocusNode.dispose();
    _presentationContainerFocusNode.dispose();
    _presentationQuantityFocusNode.dispose();
    _presentationUnitNameFocusNode.dispose();
    _barCodeFocusNode.dispose();
    _lastAddDateFocusNode.dispose();
    _lastCostPriceFocusNode.dispose();
    _lastSalePriceFocusNode.dispose();
    _currentStockFocusNode.dispose();
    _controlledFocusNode.dispose();

    _barCodeFocusNode.removeListener(() {_barCodeListener;});
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
        'Agregar o actualizar medicamentos',
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
            Form(
              key: _formBarCodeKey,
              child:  CustomTextFormField(
                label: 'Código',
                controller: _barCodeController,
                focusNode: _barCodeFocusNode,
                dataType: DataTypeEnum.text,
                maxValueForValidation: 13,
                textForValidation: 'Ingrese un código de hasta 13 caracteres',
                viewCharactersCount: false,
                acceptEmpty: false,
                initialFocus: true,
                onEditingComplete: () =>
                    FocusScope.of(context).requestFocus(_nameFocusNode),
              ),
            ),
            CustomTextFormField(
              label: 'Nombre',
              controller: _nameController,
              focusNode: _nameFocusNode,
              dataType: DataTypeEnum.text,
              maxValueForValidation: 50,
              viewCharactersCount: false,
              textForValidation: 'Ingrese un nombre de hasta 50 caracteres',
              acceptEmpty: false,
              onEditingComplete: () async {
                await _searchMedicineName();
              }
            ),
            _buildFormPresentation(),
            CustomTextFormField(
              label: 'Precio de costo',
              controller: _lastCostPriceController,
              focusNode: _lastCostPriceFocusNode,
              dataType: DataTypeEnum.number,
              minValueForValidation: 0,
              maxValueForValidation: 999999.99,
              textForValidation: 'Ingrese un precio de costo de hasta 999999.99',
              viewCharactersCount: false,
              acceptEmpty: false,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_lastSalePriceFocusNode),
            ),
            CustomTextFormField(
              label: 'Precio de venta',
              controller: _lastSalePriceController,
              focusNode: _lastSalePriceFocusNode,
              dataType: DataTypeEnum.number,
              minValueForValidation: 0,
              maxValueForValidation: 999999.99,
              textForValidation: 'Ingrese un precio de venta de hasta 999999.99',
              viewCharactersCount: false,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_currentStockFocusNode),
            ),
            _isAdd != null && _isAdd! //Si es un alta, permite la edicion del Stock
              ? CustomTextFormField(
                  label: 'Stock',
                  controller: _currentStockController,
                  focusNode: _currentStockFocusNode,
                  dataType: DataTypeEnum.number,
                  acceptEmpty: false,
                  minValueForValidation: 0.001,
                  maxValueForValidation: 99999.99,
                  textForValidation: 'Ingrese un stock de hasta 99999.99',
                  viewCharactersCount: false,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_controlledFocusNode),
                )
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Stock: ${_currentStockController.text}'),
              ),
            Row(
              children: [
                const Text('Controlado '),
                Focus(
                  focusNode: _controlledFocusNode,
                  child: Checkbox(value: _controlled, onChanged: (value) {
                    setState(() {
                      _controlled = value;
                    });
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _searchMedicineName() async {
    if (_nameController.text.trim().isEmpty) return;
    _changeStateLoading(true);
    await medicineAndPresentationListDialog(
        medicineName: _nameController.text.trim(),
        context: context
    ).then((medicine) {
      _changeStateLoading(false);
      if (medicine != null) _updatePresentationFields(medicine);
      if (mounted) {
        FocusScope.of(context).requestFocus(_presentationContainerFocusNode);
      }
    }).onError((error, stackTrace) {
      if (mounted) handleError(error: error, context: context);
    });
  }

  Future<void> _searchPresentationContainerName() async {
    if (_presentationContainerController.text.trim().isEmpty) return;
    _changeStateLoading(true);
    String? containerSelected = await presentationContainerNameListDialog(
        presentationContainerName: _presentationContainerController.text.trim(),
        context: context,
    );
    _changeStateLoading(false);
    if (containerSelected != null) {
      _presentationContainerController.value = TextEditingValue(
          text: containerSelected
      );
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_presentationQuantityFocusNode);
    }
  }

  Widget _buildFormPresentation() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: Container(
        width: double.infinity, // Para asegurar que el contenedor tome tod-o el ancho disponible
        decoration: BoxDecoration(
          border: Border.all(
            style: BorderStyle.solid,
            color: Colors.blue,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none, // Permite que los elementos se superpongan fuera del contenedor
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, top: 8.0, right: 10.0, bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 190,
                    child: CustomTextFormField(
                      label: 'Envase',
                      controller: _presentationContainerController,
                      focusNode: _presentationContainerFocusNode,
                      dataType: DataTypeEnum.text,
                      maxValueForValidation: 20,
                      viewCharactersCount: false,
                      textForValidation: 'Requerido',
                      acceptEmpty: false,
                      onEditingComplete: () async =>
                          await _searchPresentationContainerName()
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 60,
                    child: CustomTextFormField(
                      label: 'Cantidad',
                      controller: _presentationQuantityController,
                      focusNode: _presentationQuantityFocusNode,
                      dataType: DataTypeEnum.number,
                      minValueForValidation: 0,
                      maxValueForValidation: 99999.99,
                      viewCharactersCount: false,
                      textForValidation: 'Requerido',
                      acceptEmpty: false,
                      onEditingComplete: () {
                        if (mounted) {
                          FocusScope.of(context)
                              .requestFocus(_presentationUnitNameFocusNode);
                          FocusScope.of(context).nextFocus();
                        }
                      }),
                  ),
                  const Spacer(),
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Unidad',
                                style: TextStyle(fontSize: 12),
                              ),
                              //_buildRefshUnitsButtreon(),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: CustomDropdown<String>(
                              focusNode: _presentationUnitNameFocusNode,
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
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10.0,
              top: -10.0,
              child: Container(
                color: Colors.white, // Color de fondo para que el título no se solape con el borde
                padding: const EdgeInsets.symmetric(horizontal: 5.0), // Padding interno del título
                child: const Text(
                  'Presentación',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      _isAdd == null
          || _presentationContainerController.text.trim().isEmpty
          || _presentationQuantityController.text.trim().isEmpty
          || _unitSelected == defaultFirstOption
          || _unitSelected == defaultLastOption;

  Future<void> _submitForm() async {
    _changeStateLoading(true);
    PresentationDTO presentationDTO = PresentationDTO(
        name: _presentationContainerController.text.trim(),
        quantity: double.parse(_presentationQuantityController.text),
        unitName: _unitSelected
    );

    try {
      //Actualiza la var. publica con el id de la presentacion ingresada
      _presentationId = await fetchPresentationId(presentationDTO);
    } catch (e) {
      if (mounted) handleError(error: e, context: context);
      _changeStateLoading(false);
      return;
    }

    if (_presentationId == 0) {
      try {
        PresentationDTO1 presentationDTO1 = PresentationDTO1(
            name: _presentationContainerController.text.trim(),
            quantity: double.parse(_presentationQuantityController.text),
            unit: UnitDTO1(unitId: _getSelectedUnitId())
        );

        //Actualiza la var. publica con el id de la nueva presentacion agregada
        _presentationId = await addOrUpdatePresentation(
          presentation: presentationDTO1,
          isAdd: true,
          context: mounted ? context : context,
        );
        if (kDebugMode) print('Presentación agregada con éxito (id=$_presentationId)');

      } catch (error) {
        if (error is ErrorObject) {
          if (error.message!.contains('ES INCORRECTA')) {
            if (mounted) {
              FloatingMessage.show(
                  context: context,
                  text: error.message!,
                  messageTypeEnum: MessageTypeEnum.warning,
                  secondsDelay: 8
              );
            }
          } else if (error.message != null &&
              error.message!.contains("NO EXISTE UNA UNIDAD DE MEDIDA")) {

            String msg = 'La unidad de medida $_unitSelected fué eliminada por '
                'otro usuario.\nLa lista ha sido actualizada.';

            if (mounted) {
              FloatingMessage.show(
                  context: context,
                  text: msg,
                  messageTypeEnum: MessageTypeEnum.warning,
                  secondsDelay: 8
              );
            }
            _loadUnits(false);
            setState(() {
              _unitSelected = defaultFirstOption;
            });
            if (kDebugMode) print (msg);
          }
        } else {
          if (error.toString().contains('XMLHttpRequest error')) {
            if (mounted) {
              FloatingMessage.show(
                context: context,
                text: 'Error de conexión',
                messageTypeEnum: MessageTypeEnum.error,
              );
            }
          }
        }
        _changeStateLoading(false);
        return;
      }
    }
    await _addOrUpdateMedicine();
    _changeStateLoading(false);
  }

  //Devuelve el id de la unidad de medidad seleccionada
  int? _getSelectedUnitId() => _unitList.firstWhere((element)
    => element.name == _unitSelected).unitId;

  Future<void> _addOrUpdateMedicine() async {
     await addOrUpdateMedicine(
        medicine: _buildMedicine(),
        isAdd: _isAdd!,
        context: context

    ).then((medicineId) {
      String msg = 'Medicamento ${_isAdd! ? 'agregado' : 'actualizado'} con éxito';
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.info,
          context: context
      );
      _initialize(initNameAndPresentation: true);
      FocusScope.of(context).requestFocus(_barCodeFocusNode);
      if (kDebugMode) print('$msg (id: $medicineId)');

      // Se captura el error para evitar el error en consola. Este se manejó en
      // addOrUpdateCustomer
    }).onError((error, stackTrace) => null);
  }

  MedicineDTO1 _buildMedicine() {
    return MedicineDTO1(
      medicineId: _medicineId == 0 ? null : _medicineId,
      userId: userLogged!.userId,
      barCode: _barCodeController.text.trim(),
      name: _nameController.text.trim(),
      presentation: _buildPresentation(),
      lastCostPrice: double.parse(_lastCostPriceController.text.trim()),
      lastSalePrice: double.parse(_lastSalePriceController.text.trim()),
      currentStock: double.parse(_currentStockController.text.trim()),
      controlled: _controlled!,
      deleted: false,
    );
    //Nota: no se especifica 'deleted' porque lo maneja el backend
  }

  PresentationDTO _buildPresentation() {
    return PresentationDTO(
      presentationId: _presentationId == 0 ? null : _presentationId,
      name: _presentationContainerController.text.trim(),
      quantity: double.parse(_presentationQuantityController.text.trim()),
      unitName: _unitSelected,
    );
  }

  void _cancelForm() {
    widget.onCancel(); // Llamar al callback de cancelación
  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: _isAdd! ? '¿Agregar el medicamento?' : '¿Actualizar el medicamento?',
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
    _barCodeListener();
  }

  void _barCodeListener() {
    _barCodeFocusNode.addListener(() async {
      if (!_barCodeFocusNode.hasFocus) {
        if (_barCodeController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(_barCodeFocusNode);
          return;
        }
        if (! _formBarCodeKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(_barCodeFocusNode);
          return;
        }
        await _isRegisteredBarCode().then((registered) {
          if (registered != null) {
            _isAdd = ! registered;
          }
          return null;
        });

        // Recibe foco
      } else if (_barCodeFocusNode.hasFocus) {
        _initialize(initNameAndPresentation: true);
      }
    });
  }

  /// true/false si el codigo de barras ya existe/no existe;
  /// null si se lanzó un error.
  Future<bool?> _isRegisteredBarCode() async {
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
          if (error.message != null &&
              error.message!.contains('El medicamento está eliminado')) {
            FloatingMessage.show(
              context: mounted ? context : context,
              text: error.message!,
              messageTypeEnum: MessageTypeEnum.warning
            );
          } else {
            if (mounted) handleError(error: error, context: context);
          }
        }
      } else {
        registered = null;
        if (mounted) handleError(error: error, context: context);
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
  }

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

  void _updatePresentationFields(MedicineDTO2 medicine) {
    _nameController.value = TextEditingValue(text: medicine.name!);
    _presentationContainerController.value = TextEditingValue(
        text: medicine.presentation!.name!);
    _presentationQuantityController.value = TextEditingValue(
        text: medicine.presentation!.quantity!.toString());
    _updateUnitSelected(medicine.presentation!.unitName!);
    _controlled = medicine.controlled;
  }

  Future<void> _updateUnitSelected(String unitName) async {
    //Antes de actualizar la var. _unitSelected, chequea que la unidad de medida
    //exista en la lista. Si no existe, refresca las unidades.
    if (! _unitExistInList(unitName)) {
      await _loadUnits(false);
      if (! _unitExistInList(unitName)) {
        message(
            message: 'La unidad de medida $unitName '
                'no existe o no se pudo cargar.\n'
                'Contacte al administrador del sistema.',
            context: mounted ? context : context
        );
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
      (e) => e.name ==unitName,
      orElse: () => UnitDTO.empty(),
    );
    return unit.name != null;
  }
  void _updateFields(MedicineDTO1 medicine) {
    _medicineId = medicine.medicineId!;
    _presentationId = medicine.presentation!.presentationId!;

    _barCodeController.value = TextEditingValue(text: medicine.barCode!);
    _nameController.value = TextEditingValue(text: medicine.name!);
    _presentationContainerController.value = TextEditingValue(
        text: medicine.presentation!.name!);
    _presentationQuantityController.value = TextEditingValue(
        text: medicine.presentation!.quantity!.toString());
    _lastCostPriceController.value = TextEditingValue(
        text: medicine.lastCostPrice!.toString());
    _lastSalePriceController.value = TextEditingValue(
        text: medicine.lastSalePrice!.toString());
    _currentStockController.value = TextEditingValue(
        text: medicine.currentStock!.toString());
    _controlled = medicine.controlled!;
    _updateUnitSelected(medicine.presentation!.unitName!);
  }

  void _initialize({required bool initNameAndPresentation}) {
    setState(() {
      if (initNameAndPresentation) {
        _nameController.value = TextEditingValue.empty;
        _presentationContainerController.value = TextEditingValue.empty;
        _presentationQuantityController.value = TextEditingValue.empty;
        _unitSelected = defaultFirstOption;
      }
      _barCodeController.value = TextEditingValue.empty;
      _lastCostPriceController.value = TextEditingValue.empty;
      _lastSalePriceController.value = TextEditingValue.empty;
      _currentStockController.value = TextEditingValue.empty;
      _controlled = false;
    });
    _isAdd = null;
    _medicineId = 0;
    _presentationId = 0;
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
      if (error is! ErrorObject || error.statusCode != HttpStatus.notFound) {
        if (mounted) handleError(error: error, context: context);
      }
        /*if (error is ErrorObject){
        if (error.statusCode != HttpStatus.notFound) {
          genericError(error, isFloatingMessage: true, mounted ? context : context);
        }
      } else {
        genericError(error!, mounted ? context : context);
      }*/
    });

    if (isInitState) {
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
            await _updateUnits(false);
            // llama al callback: no está haciendo el refresh...
            if (widget.onBlockedStateChange != null) {
              widget.onBlockedStateChange!(false);
            }
          }
        },
        icon: const Tooltip(
          message: 'Actualizar unidades',
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
        if (mounted) {
          setState(() {
            _unitSelected = unit;
          });
        }
      });
    }
  }

}
