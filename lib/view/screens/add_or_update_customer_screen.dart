
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/customer_dto.dart';
import 'package:novafarma_front/model/DTOs/customer_dto1.dart';
import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
  uriCustomerFindPaymentNumber;
import 'package:novafarma_front/model/globals/requests/fetch_partner_nova_daily_list.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/user_dto.dart';
import '../../model/DTOs/user_dto_1.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/requests/add_or_update_customer.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/date_time.dart';
import '../../model/globals/tools/floating_message.dart';

class AddOrUpdateCustomerScreen extends StatefulWidget {
  final ValueChanged<bool>? onBlockedStateChange;

  const AddOrUpdateCustomerScreen({super.key, this.onBlockedStateChange});

  @override
  _AddOrUpdateCustomerScreen createState() => _AddOrUpdateCustomerScreen();
}

class _AddOrUpdateCustomerScreen extends State<AddOrUpdateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formDocumentKey = GlobalKey<FormState>();

  final _documentController = TextEditingController();
  final _dateController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _paymentNumberController = TextEditingController();

  final _documentFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();
  final _lastnameFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();
  final _telephoneFocusNode = FocusNode();
  final _paymentNumberFocusNode = FocusNode();

  int _customerId = 0, _dependentId = 0, _partnerId = 0;
  bool? _isAdd; // true: add, false: update, null: hubo error
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _createListeners();
    _initialize(initDocument: true);
  }

  @override
  void dispose() {
    super.dispose();
    _documentController.dispose();
    _dateController.dispose();
    _lastnameController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _telephoneController.dispose();
    _paymentNumberController.dispose();

    _documentFocusNode.dispose();
    _dateFocusNode.dispose();
    _lastnameFocusNode.dispose();
    _nameFocusNode.dispose();
    _notesFocusNode.dispose();
    _telephoneFocusNode.dispose();
    _paymentNumberFocusNode.dispose();
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
        'Agregar o actualizar clientes',
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
              key: _formDocumentKey,
              child: CreateTextFormField(
                label: 'Documento',
                controller: _documentController,
                focusNode: _documentFocusNode,
                dataType: DataTypeEnum.identificationDocument,
                textForValidation: 'Ingrese un documento válido',
                acceptEmpty: false,
                initialFocus: true,
                onFieldSubmitted: (p0) =>
                    FocusScope.of(context).requestFocus(_dateFocusNode),
              ),
            ),
            CreateTextFormField(
              label: 'Fecha de ingreso',
              controller: _dateController,
              focusNode: _dateFocusNode,
              dataType: DataTypeEnum.date,
              textForValidation: 'Ingrese una fecha válida',
              acceptEmpty: false,
              onFieldSubmitted: (p0) =>
                FocusScope.of(context).requestFocus(_lastnameFocusNode),
            ),
            CreateTextFormField(
              label: 'Apellido',
              controller: _lastnameController,
              focusNode: _lastnameFocusNode,
              dataType: DataTypeEnum.text,
              maxValueForValidation: 25,
              viewCharactersCount: false,
              textForValidation: 'Ingrese un apellido de hasta 25 caracteres',
              acceptEmpty: false,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_nameFocusNode),
            ),
            CreateTextFormField(
              label: 'Nombre',
              controller: _nameController,
              focusNode: _nameFocusNode,
              dataType: DataTypeEnum.text,
              maxValueForValidation: 25,
              viewCharactersCount: false,
              textForValidation: 'Ingrese un nombre de hasta 25 caracteres',
              acceptEmpty: false,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_paymentNumberFocusNode),
            ),
            CreateTextFormField(
              label: 'Numero de cobro',
              controller: _paymentNumberController,
              focusNode: _paymentNumberFocusNode,
              dataType: DataTypeEnum.number,
              maxValueForValidation: 9999999,
              acceptEmpty: false,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_telephoneFocusNode),
            ),
            CreateTextFormField(
              label: 'Teléfono',
              controller: _telephoneController,
              focusNode: _telephoneFocusNode,
              dataType: DataTypeEnum.telephone,
              maxValueForValidation: 50,
              textForValidation: 'Ingrese un teléfono de hasta 50 dígitos',
              acceptEmpty: true,
              onFieldSubmitted: (p0) =>
                  FocusScope.of(context).requestFocus(_notesFocusNode),
            ),
            CreateTextFormField(
              label: 'Notas',
              controller: _notesController,
              focusNode: _notesFocusNode,
              dataType: DataTypeEnum.text,
              acceptEmpty: true,
              maxValueForValidation: 100,
              maxLines: 3,
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
              if (! await _validate()) return;
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
    await addOrUpdateCustomer(
        customer: _buildCustomer(),
        isAdd: _isAdd!,
        context: context

    ).then((customerId) {
      String msg = 'Cliente ${_isAdd! ? 'agregado' : 'actualizado'} con éxito';
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.info,
          context: context
      );
      _initialize(initDocument: true);
      FocusScope.of(context).requestFocus(_documentFocusNode);
      if (kDebugMode) print('$msg (id: $customerId)');

      // Se captura el error para evitar el error en consola. Este se manejó en
      // addOrUpdateCustomer
    }).onError((error, stackTrace) => null);
  }

  Future<bool> _validate() async {
    if (! await _validatePaymentNumber()) return Future.value(false);
    return Future.value(true);
  }

  Future<bool> _validatePaymentNumber() async {
    bool valid = true;
    bool warning = false;
    String msgError = 'Error indeterminado';

    await fetchData(
        uri: '$uriCustomerFindPaymentNumber/'
            '${int.parse(_paymentNumberController.text.trim())}',
        classObject: CustomerDTO1.empty()
    ).then((customer) {
      if (customer[0] is CustomerDTO1){
        CustomerDTO1 c = customer[0] as CustomerDTO1;
        if (c.document != int.parse(_documentController.text.trim())) {
          msgError = 'Número de cobro ya registrado para ${c.lastname}, ${c.name}';
          warning = true;
          valid = false;
        }
      }
    }).onError((error, stackTrace) {
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.internalServerError) {
          msgError = error.message ?? 'Error: internalServerError';
          valid = false;
        }
      } else {
        if (error.toString().contains('XMLHttpRequest error')) {
          msgError = 'Error de conexión';
        } else {
          msgError = error.toString();
        }
        valid = false;
      }
    });

    if (! valid) {
      FloatingMessage.show(
        context: context,
        text: msgError,
        secondsDelay: 5,
        messageTypeEnum: warning ? MessageTypeEnum.warning : MessageTypeEnum.error
      );
      if (kDebugMode) print(msgError);
    }
    return Future.value(valid);
  }

  CustomerDTO1 _buildCustomer() {
    return CustomerDTO1(
      customerId: _customerId == 0 ? null : _customerId,
      user: UserDTO1(userId: userLogged['userId']),
      document: int.parse(_documentController.text.trim()),
      addDate: strToDate(_dateController.text),
      lastname: _lastnameController.text.trim(),
      name: _nameController.text.trim(),
      paymentNumber: int.parse(_paymentNumberController.text.trim()),
      telephone: _telephoneController.text.trim(),
      notes: _notesController.text.trim(),
      partner: _partnerId != 0,
      partnerId: _partnerId,
      dependentId: _dependentId,
      deleted: false,
    );
  }

  void _cancelForm() {
    Navigator.of(context).pop();
  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: _isAdd! ? '¿Agregar el cliente?' : '¿Actualizar el cliente?',
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
    _documentListener();
    _dateListener();
  }

  void _documentListener() {
    bool? registered;
    _documentFocusNode.addListener(() async {
      // Pierde foco
      if (!_documentFocusNode.hasFocus) {
        if (_documentController.text.trim().isEmpty) {
          FocusScope.of(context).requestFocus(_documentFocusNode);
          return;
        }
        if (! _formDocumentKey.currentState!.validate()) {
          FocusScope.of(context).requestFocus(_documentFocusNode);
          return;
        }
        registered = await _registeredDocument();
        if (registered != null) {
          _isAdd = ! registered!;
          if (registered!){
            //No esta registrado en NovaFarma. Se busca en NovaDaily y
            // actualiza campos.
            // **
            // ** SI DESHABILITA HASTA SOLUCIONAR CORS
            // **
            //await _registeredDocumentNovaDaily();
          }
        }

        // Recibe foco
      } else if (_documentFocusNode.hasFocus) {
        _initialize(initDocument: false);
      }
    });
  }

  void _dateListener() {
    _dateFocusNode.addListener(() {
      //Recibe foco
      if (_dateFocusNode.hasFocus) {
        _dateController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _dateController.text.length,
        );
        // Pierde foco
      } else if (! _dateFocusNode.hasFocus) {
        if (strToDate(_dateController.text) == null) {
          _dateController.value = TextEditingValue(text: dateNow());
        }
      }
    });
  }

  /// true si el documento ya existe en la bbdd de novafarma, false si no existe.
  /// null si se lanzó un error.
  Future<bool?> _registeredDocument() async {
    bool? registered;
    List<CustomerDTO1> _customerList = [];
    _changeStateLoading(true);

    try {
      await fetchCustomerList(
          customerList: _customerList,
          searchByDocument: true,
          value: _documentController.text,
      );
      _updateFields(_customerList[0]);
      registered = true;

    } catch (error) {
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {
          registered = false;
        } else {
          await OpenDialog(
              context: context,
              title: 'Error',
              content: error.message != null
                  ? error.message!
                  : 'Error ${error.statusCode}'
          ).view();
        }
      } else {
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

    if (registered == null) FocusScope.of(context).requestFocus(_documentFocusNode);
    return Future.value(registered);

  }

  Future<void> _registeredDocumentNovaDaily() async {
    List<PartnerNovaDailyDTO> _partnerNovaDailyList = [];
    _changeStateLoading(true);

    try {
      await fetchPartnerNovaDailyList(
        partnerNovaDailyList: _partnerNovaDailyList,
        searchByDocument: true,
        value: _documentController.text,
      );
      _updateFields(_partnerNovaDailyList[0]);

    } catch (error) {
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {

        } else {
          await OpenDialog(
              context: context,
              title: 'Error',
              content: error.message != null
                  ? error.message!
                  : 'Error ${error.statusCode}'
          ).view();
        }
      } else {
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

    //if (registered == null) FocusScope.of(context).requestFocus(_documentFocusNode);
    //return Future.value(registered);

  }

  /// customer: puede ser un CustomerDTO1 o un PartnerNovaDailyDTO
  void _updateFields(Object customer) {
    if (customer is CustomerDTO1) {
      _dateController.value =
          TextEditingValue(text: dateToStr(customer.addDate)!);
      _lastnameController.value = TextEditingValue(text: customer.lastname!);
      _nameController.value = TextEditingValue(text: customer.name);
      _paymentNumberController.value = TextEditingValue(
          text: customer.paymentNumber.toString());
      _telephoneController.value = TextEditingValue(text: customer.telephone!);
      _notesController.value = TextEditingValue(text: customer.notes!);

      _customerId = customer.customerId!;
      _partnerId = customer.partnerId!;
      _dependentId = customer.dependentId!;

    } else if (customer is PartnerNovaDailyDTO) {
      _dateController.value =
          TextEditingValue(text: dateToStr(customer.addDate)!);
      _lastnameController.value = TextEditingValue(text: customer.lastname!);
      _nameController.value = TextEditingValue(text: customer.name!);
      _paymentNumberController.value = TextEditingValue(
          text: customer.paymentNumber.toString());
      _telephoneController.value = TextEditingValue(text: customer.telephone!);
      _notesController.value = TextEditingValue(text: customer.notes!);

      //_customerId = customer.partnerId!; //Tomo el id de socio de NovaDaily
      //_partnerId = customer.partnerId!;
      //_dependentId = customer.;
    }

  }

  void _initialize({required bool initDocument}) {
    setState(() {
      if (initDocument) _documentController.value = TextEditingValue.empty;
      _dateController.value = TextEditingValue(text: dateNow());
      _lastnameController.value = TextEditingValue.empty;
      _nameController.value = TextEditingValue.empty;
      _paymentNumberController.value = TextEditingValue.empty;
      _telephoneController.value = TextEditingValue.empty;
      _notesController.value = TextEditingValue.empty;
    });
    _isAdd = null;
    _customerId = 0;
    _dependentId = 0;
    _partnerId = 0;
  }

  void _changeStateLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
    widget.onBlockedStateChange!(isLoading);
  }

}
