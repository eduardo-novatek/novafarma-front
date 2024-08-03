
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/presentation_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show uriSupplierFindName;
import 'package:novafarma_front/model/globals/requests/add_or_update_medicine.dart';
import 'package:novafarma_front/model/globals/requests/fetch_medicine_bar_code.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/medicine_dto1.dart';
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/floating_message.dart';

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
  State<AddOrUpdateMedicineScreen> createState() => _AddOrUpdateCustomerScreen();
}

class _AddOrUpdateCustomerScreen extends State<AddOrUpdateMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formBarCodeKey = GlobalKey<FormState>();
  final _formNameKey = GlobalKey<FormState>();
  final _formPresentationKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _presentationNameController = TextEditingController();
  final _presentationQuantityController = TextEditingController();
  final _presentationUnitNameController = TextEditingController();
  final _barCodeController = TextEditingController();
  final _lastAddDateController = TextEditingController();
  final _lastCostPriceController = TextEditingController();
  final _lastSalePriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  bool? _controlled;

  final _nameFocusNode = FocusNode();
  final _presentationNameFocusNode = FocusNode();
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
  //bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _createListeners();
    _initialize(initNameAndPresentation: true);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _presentationNameController.dispose();
    _presentationQuantityController.dispose();
    _presentationUnitNameController.dispose();
    _barCodeController.dispose();
    _lastAddDateController.dispose();
    _lastCostPriceController.dispose();
    _lastSalePriceController.dispose();
    _currentStockController.dispose();

    _nameFocusNode.dispose();
    _presentationNameFocusNode.dispose();
    _presentationQuantityFocusNode.dispose();
    _presentationUnitNameFocusNode.dispose();
    _barCodeFocusNode.dispose();
    _lastAddDateFocusNode.dispose();
    _lastCostPriceFocusNode.dispose();
    _lastSalePriceFocusNode.dispose();
    _currentStockFocusNode.dispose();
    _controlledFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
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
      padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño vertical al contenido
          children: [
            Form(
              key: _formBarCodeKey,
              child:  CreateTextFormField(
                label: 'Código',
                controller: _barCodeController,
                focusNode: _barCodeFocusNode,
                dataType: DataTypeEnum.text,
                maxValueForValidation: 13,
                textForValidation: 'Ingrese un código de hasta 13 caracteres',
                acceptEmpty: false,
                onFieldSubmitted: (p0) =>
                    FocusScope.of(context).requestFocus(_nameFocusNode),
              ),
            ),
            Form(
              key: _formNameKey,
              child: CreateTextFormField(
                label: 'Nombre',
                controller: _nameController,
                focusNode: _nameFocusNode,
                dataType: DataTypeEnum.text,
                maxValueForValidation: 50,
                viewCharactersCount: true,
                textForValidation: 'Ingrese un nombre de hasta 50 caracteres',
                acceptEmpty: false,
                onFieldSubmitted: (p0) =>
                    FocusScope.of(context).requestFocus(_lastCostPriceFocusNode),
              ),
            ),
            CreateTextFormField(
              label: 'Precio de costo',
              controller: _lastCostPriceController,
              focusNode: _lastCostPriceFocusNode,
              dataType: DataTypeEnum.number,
              minValueForValidation: 0,
              maxValueForValidation: 999999,
              textForValidation: 'Ingrese un precio de costo de hasta 6 dígitos',
              acceptEmpty: false,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_lastSalePriceFocusNode),
            ),
            CreateTextFormField(
              label: 'Precio de venta',
              controller: _lastSalePriceController,
              focusNode: _lastSalePriceFocusNode,
              dataType: DataTypeEnum.number,
              minValueForValidation: 0,
              maxValueForValidation: 999999,
              textForValidation: 'Ingrese un precio de venta de hasta 6 dígitos',
              viewCharactersCount: false,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_currentStockFocusNode),
            ),
            CreateTextFormField(
              label: 'Stock',
              controller: _currentStockController,
              focusNode: _currentStockFocusNode,
              dataType: DataTypeEnum.number,
              acceptEmpty: false,
              minValueForValidation: -9999,
              maxValueForValidation: 99999,
              textForValidation: 'Ingrese un stock de hasta 5 dígitos incluído el signo',
              viewCharactersCount: false,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_controlledFocusNode),
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _isAdd == null ? null : () async {
              if (! _formKey.currentState!.validate()) return;
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

  Future<void> _submitForm() async {
    _changeStateLoading(true);
    await addOrUpdateMedicine(
        medicine: _buildMedicine(),
        isAdd: _isAdd!,
        context: context

    ).then((supplierId) {
      _changeStateLoading(false);
      String msg = 'Medicamento ${_isAdd! ? 'agregado' : 'actualizado'} con éxito';
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.info,
          context: context
      );
      _initialize(initNameAndPresentation: true);
      FocusScope.of(context).requestFocus(_nameFocusNode);
      if (kDebugMode) print('$msg (id: $supplierId)');

      // Se captura el error para evitar el error en consola. Este se manejó en
      // addOrUpdateCustomer
    }).onError((error, stackTrace) {
      _changeStateLoading(false);
    });
  }

  MedicineDTO1 _buildMedicine() {
    return MedicineDTO1(
      medicineId: _medicineId == 0 ? null : _medicineId,
      barCode: _barCodeController.text.trim(),
      name: _nameController.text.trim(),
      presentation: _buildPresentation(),
      lastCostPrice: double.parse(_lastCostPriceController.text.trim()),
      lastSalePrice: double.parse(_lastSalePriceController.text.trim()),
      currentStock: double.parse(_currentStockController.text.trim()),
      controlled: _controlled!,
    );
  }

  PresentationDTO _buildPresentation() {
    return PresentationDTO(
      presentationId: _presentationId == 0 ? null : _presentationId,
      name: _presentationNameController.text.trim(),
      quantity: int.parse(_presentationQuantityController.text.trim()),
      unitName: _presentationUnitNameController.text.trim(),
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
    //_nameListener();
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

  void _nameListener() {
    _nameFocusNode.addListener(() async {
      // Pierde foco
      if (!_nameFocusNode.hasFocus) {
        if (_nameController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(_nameFocusNode);
          return;
        }
        if (! _formNameKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(_nameFocusNode);
          return;
        }
        await _isRegisteredMedicine()
          .then((registered) {
            if (registered != null) {
              _isAdd = ! registered;
            }
            return null;
          });

        // Recibe foco
      } else if (_nameFocusNode.hasFocus) {
        _initialize(initNameAndPresentation: false);
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
        _updateFields(medicine);
        registered = true;
      }

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
      FocusScope.of(context).removeListener(() {_barCodeFocusNode;});
      FocusScope.of(context).requestFocus(_barCodeFocusNode);
      FocusScope.of(context).addListener(() {_barCodeFocusNode;});
    }
    return Future.value(registered);
  }

  /// true/false si el medicamento (nombre+presentacion) ya existe/no existe;
  /// null si se lanzó un error.
  Future<bool?> _isRegisteredMedicine() async {
    bool? registered = false;
    List<MedicineDTO1> medicineList = [];

    /*_changeStateLoading(true);
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
     */
    return Future.value(registered);
  }

  void _updateFields(MedicineDTO1 medicine) {
    _medicineId = medicine.medicineId!;
    _presentationId = medicine.presentation!.presentationId!;

    _barCodeController.value = TextEditingValue(text: medicine.barCode!);
    _nameController.value = TextEditingValue(text: medicine.name!);
    _presentationNameController.value = TextEditingValue(
        text: medicine.presentation!.name!);
    _presentationQuantityController.value = TextEditingValue(
        text: medicine.presentation!.quantity!.toString());
    _presentationUnitNameController.value = TextEditingValue(
        text: medicine.presentation!.unitName!);
    _lastCostPriceController.value = TextEditingValue(
        text: medicine.lastCostPrice!.toString());
    _lastSalePriceController.value = TextEditingValue(
        text: medicine.lastSalePrice!.toString());
    _currentStockController.value = TextEditingValue(
        text: medicine.currentStock!.toString());
    _controlled = medicine.controlled!;
  }

  void _initialize({required bool initNameAndPresentation}) {
    setState(() {
      if (initNameAndPresentation) {
        _nameController.value = TextEditingValue.empty;
        _presentationNameController.value = TextEditingValue.empty;
        _presentationQuantityController.value = TextEditingValue.empty;
        _presentationUnitNameController.value = TextEditingValue.empty;
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

}
