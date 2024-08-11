
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/customer_dto1.dart';
import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show uriCustomerFindPaymentNumber, uriSupplierFindName;
import 'package:novafarma_front/model/globals/requests/fetch_partner_nova_daily_list.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/supplier_dto.dart';
import '../../model/DTOs/user_dto_1.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/requests/add_or_update_customer.dart';
import '../../model/globals/requests/add_or_update_supplier.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/requests/fetch_supplier_list.dart';
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/date_time.dart';
import '../../model/globals/tools/floating_message.dart';
import '../dialogs/supplier_selection_dialog.dart';

class AddOrUpdateSupplierScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;
  final ValueChanged<bool>? onBlockedStateChange;

  const AddOrUpdateSupplierScreen({
    super.key,
    this.onBlockedStateChange,
    required this.onCancel,
  });

  @override
  State<AddOrUpdateSupplierScreen> createState() => _AddOrUpdateCustomerScreen();
}

class _AddOrUpdateCustomerScreen extends State<AddOrUpdateSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formNameKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _telephone1Controller = TextEditingController();
  final _telephone2Controller = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _telephone1FocusNode = FocusNode();
  final _telephone2FocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

  int _supplierId = 0;
  bool? _isAdd; // true: add, false: update, null: hubo error
  bool _isLoading = false;
  //bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _createListeners();
    _initialize(initName: true);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _telephone1Controller.dispose();
    _telephone2Controller.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _notesController.dispose();

    _nameFocusNode.dispose();
    _telephone1FocusNode.dispose();
    _telephone2FocusNode.dispose();
    _addressFocusNode.dispose();
    _emailFocusNode.dispose();
    _notesFocusNode.dispose();
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
        'Agregar o actualizar proveedores',
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
              key: _formNameKey,
              child:  CreateTextFormField(
                label: 'Nombre',
                controller: _nameController,
                focusNode: _nameFocusNode,
                dataType: DataTypeEnum.text,
                maxValueForValidation: 30,
                viewCharactersCount: false,
                textForValidation: 'Ingrese un nombre de hasta 30 caracteres',
                acceptEmpty: false,
                onEditingComplete: (p0) =>
                    FocusScope.of(context).requestFocus(_telephone1FocusNode),
              ),
            ),
            CreateTextFormField(
              label: 'Teléfono 1',
              controller: _telephone1Controller,
              focusNode: _telephone1FocusNode,
              dataType: DataTypeEnum.telephone,
              minValueForValidation: 8,
              maxValueForValidation: 10,
              textForValidation: 'El teléfono debe contener entre 8 y 10 dígitos',
              acceptEmpty: false,
              onEditingComplete: (p0) =>
                  FocusScope.of(context).requestFocus(_telephone2FocusNode),
            ),
            CreateTextFormField(
              label: 'Teléfono 2',
              controller: _telephone2Controller,
              focusNode: _telephone2FocusNode,
              dataType: DataTypeEnum.telephone,
              maxValueForValidation: 10,
              textForValidation: 'Ingrese un teléfono de hasta 10 dígitos',
              acceptEmpty: true,
              onEditingComplete: (p0) =>
                  FocusScope.of(context).requestFocus(_addressFocusNode),
            ),
            CreateTextFormField(
              label: 'Dirección',
              controller: _addressController,
              focusNode: _addressFocusNode,
              dataType: DataTypeEnum.text,
              acceptEmpty: true,
              maxValueForValidation: 70,
              textForValidation: 'Ingrese una dirección de hasta 70 caracteres',
              viewCharactersCount: false,
              onEditingComplete: (p0) =>
                  FocusScope.of(context).requestFocus(_emailFocusNode),
            ),
            CreateTextFormField(
              label: 'email',
              controller: _emailController,
              focusNode: _emailFocusNode,
              dataType: DataTypeEnum.email,
              acceptEmpty: true,
              maxValueForValidation: 60,
              textForValidation: 'Ingrese un email de hasta 60 caracteres',
              viewCharactersCount: false,
              onEditingComplete: (p0) =>
                  FocusScope.of(context).requestFocus(_notesFocusNode),
            ),
            CreateTextFormField(
              label: 'Notas',
              controller: _notesController,
              focusNode: _notesFocusNode,
              dataType: DataTypeEnum.text,
              acceptEmpty: true,
              maxValueForValidation: 100,
              viewCharactersCount: false,
            ),
            const SizedBox(height: 20.0),
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
    await addOrUpdateSupplier(
        supplier: _buildSupplier(),
        isAdd: _isAdd!,
        context: context

    ).then((supplierId) {
      _changeStateLoading(false);
      String msg = 'Proveedor ${_isAdd! ? 'agregado' : 'actualizado'} con éxito';
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.info,
          context: context
      );
      _initialize(initName: true);
      FocusScope.of(context).requestFocus(_nameFocusNode);
      if (kDebugMode) print('$msg (id: $supplierId)');

      // Se captura el error para evitar el error en consola. Este se manejó en
      // addOrUpdateCustomer
    }).onError((error, stackTrace) {
      _changeStateLoading(false);
    });
  }

  SupplierDTO _buildSupplier() {
    return SupplierDTO(
      supplierId: _supplierId == 0 ? null : _supplierId,
      name: _nameController.text.trim(),
      telephone1: _telephone1Controller.text.trim(),
      telephone2: _telephone2Controller.text.trim(),
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      notes: _notesController.text.trim()
    );
  }

  void _cancelForm() {
    widget.onCancel(); // Llamar al callback de cancelación
  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: _isAdd! ? '¿Agregar el proveedor?' : '¿Actualizar el proveedor?',
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
    _nameListener();
  }

  void _nameListener() {
    _nameFocusNode.addListener(() async {
      //if (_isInitializing) return;

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
        //_isCheckingName = true; // Iniciar verificación de nombre
        await _registeredName().then((registered) {
            //_isCheckingName = false; // Finalizar verificación de nombre
            if (registered != null) {
              _isAdd = ! registered;
            }
            return null;
          });

        // Recibe foco
      } else if (_nameFocusNode.hasFocus) {
        _initialize(initName: false);
      }
    });
  }

  /// true/false si el nombre del proveedor ya existe/no existe; null si se lanzó un error.
  Future<bool?> _registeredName() async {
    bool? registered = false;
    List<SupplierDTO> supplierList = [];
    _changeStateLoading(true);

    try {
      await fetchSupplierList(
          supplierList: supplierList,
          uri: '$uriSupplierFindName/${_nameController.text.trim()}'
      );
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SupplierSelectionDialog(
            suppliers: supplierList,
            onSelect: (index) {
              //Si no canceló
              if (index != -1) {
                _updateFields(supplierList[index]);
                registered = true;
                //Canceló...Si encontró solo uno y es el mismo nombre...
              } else if (supplierList.length == 1
                  && _nameController.text.trim().toUpperCase()
                      == supplierList[0].name) {
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

  void _updateFields(SupplierDTO supplier) {
    _supplierId = supplier.supplierId!;
    _nameController.value = TextEditingValue(text: supplier.name);
    _telephone1Controller.value = TextEditingValue(text: supplier.telephone1!);
    _telephone2Controller.value = TextEditingValue(text: supplier.telephone2!);
    _addressController.value = TextEditingValue(text: supplier.address!);
    _emailController.value = TextEditingValue(text: supplier.email!);
    _notesController.value = TextEditingValue(text: supplier.notes!);
  }

  void _initialize({required bool initName}) {
    setState(() {
      //_isInitializing = true;
      if (initName) _nameController.value = TextEditingValue.empty;
      _telephone1Controller.value = TextEditingValue.empty;
      _telephone2Controller.value = TextEditingValue.empty;
      _addressController.value = TextEditingValue.empty;
      _emailController.value = TextEditingValue.empty;
      _notesController.value = TextEditingValue.empty;
      //_isInitializing = false;
    });
    _isAdd = null;
    _supplierId = 0;
  }

  void _changeStateLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
    widget.onBlockedStateChange!(isLoading);
  }

}
