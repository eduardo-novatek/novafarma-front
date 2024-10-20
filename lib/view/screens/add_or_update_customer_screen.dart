
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/customer_dto1.dart';
import 'package:novafarma_front/model/DTOs/dependent_nova_daily_dto.dart';
import 'package:novafarma_front/model/DTOs/partner_nova_daily_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart' show
  uriCustomerFindPaymentNumber;
import 'package:novafarma_front/model/globals/find_dependent_by_document_novadaily.dart';
import 'package:novafarma_front/model/globals/find_partner_by_document_novadaily.dart';
import 'package:novafarma_front/model/globals/handleError.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';
import 'package:novafarma_front/model/objects/error_object.dart';

import '../../model/DTOs/user_dto_1.dart';
import '../../model/globals/publics.dart';
import '../../model/globals/requests/add_or_update_customer.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/tools/build_circular_progress.dart';
import '../../model/globals/tools/date_time.dart';
import '../../model/globals/tools/floating_message.dart';

class AddOrUpdateCustomerScreen extends StatefulWidget {
  //VoidCallback es un tipo de función predefinido en Flutter que no acepta
  // parámetros y no devuelve ningún valor. En este caso, se utiliza para
  // definir el tipo del callback onCancel, que se llamará cuando el usuario
  // presione el botón de cancelar
  final ui.VoidCallback onCancel;
  final ValueChanged<bool>? onBlockedStateChange;

  const AddOrUpdateCustomerScreen({
    super.key,
    this.onBlockedStateChange,
    required this.onCancel,
  });

  @override
  State<AddOrUpdateCustomerScreen> createState() => _AddOrUpdateCustomerScreen();
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

  //_customerId: -1 => aun no se realizó la busqueda del cliente,
  // 0 => el cliente no esta registrado en NovaFarma,
  // > 0 => id del cliente registrado en NovaFarma
  int _customerId = -1, _dependentId = 0, _partnerId = 0;
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

    _documentFocusNode.removeListener(() {_documentListener;});
    _dateFocusNode.removeListener(() {_dateListener;});
    super.dispose();
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
            Row(
              children: [
                Expanded(
                  child: Form(
                    key: _formDocumentKey,
                    child: CustomTextFormField(
                      label: 'Documento',
                      controller: _documentController,
                      focusNode: _documentFocusNode,
                      dataType: DataTypeEnum.identificationDocument,
                      textForValidation: 'Ingrese un documento válido',
                      acceptEmpty: false,
                      initialFocus: true,
                      onEditingComplete: () async {
                        await _handleDocumentValidation();
                      }
                    ),
                  ),
                ),
                _labelCustomer()
              ],
            ),
            CustomTextFormField(
              label: 'Fecha de ingreso',
              controller: _dateController,
              focusNode: _dateFocusNode,
              dataType: DataTypeEnum.date,
              textForValidation: 'Ingrese una fecha válida',
              acceptEmpty: false,
              onEditingComplete: () =>
                FocusScope.of(context).requestFocus(_lastnameFocusNode),
            ),
            CustomTextFormField(
              label: 'Apellido',
              controller: _lastnameController,
              focusNode: _lastnameFocusNode,
              dataType: DataTypeEnum.text,
              maxValueForValidation: 25,
              viewCharactersCount: false,
              textForValidation: 'Ingrese un apellido de hasta 25 caracteres',
              acceptEmpty: false,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_nameFocusNode),
            ),
            CustomTextFormField(
              label: 'Nombre',
              controller: _nameController,
              focusNode: _nameFocusNode,
              dataType: DataTypeEnum.text,
              maxValueForValidation: 25,
              viewCharactersCount: false,
              textForValidation: 'Ingrese un nombre de hasta 25 caracteres',
              acceptEmpty: false,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_paymentNumberFocusNode),
            ),
            CustomTextFormField(
              label: 'Numero de cobro',
              controller: _paymentNumberController,
              focusNode: _paymentNumberFocusNode,
              dataType: DataTypeEnum.number,
              maxValueForValidation: 9999999,
              acceptEmpty: true,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_telephoneFocusNode),
            ),
            CustomTextFormField(
              label: 'Teléfono',
              controller: _telephoneController,
              focusNode: _telephoneFocusNode,
              dataType: DataTypeEnum.telephone,
              maxValueForValidation: 50,
              textForValidation: 'Ingrese un teléfono de hasta 50 dígitos',
              acceptEmpty: true,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_notesFocusNode),
            ),
            CustomTextFormField(
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
    _changeStateLoading(true);
    await addOrUpdateCustomer(
        customer: _buildCustomer(),
        isAdd: _isAdd!,
        context: context

    ).then((customerId) {
      _changeStateLoading(false);
      String msg = 'Cliente ${_isAdd! ? 'agregado' : 'actualizado'} con éxito';
      FloatingMessage.show(
          text: msg,
          messageTypeEnum: MessageTypeEnum.info,
          context: mounted ? context : context
      );
      _initialize(initDocument: true);
      FocusScope.of(context).requestFocus(_documentFocusNode);
      if (kDebugMode) print('$msg (id: $customerId)');

      // Se captura el error para evitar el error en consola. Este se manejó en
      // addOrUpdateCustomer
    }).onError((error, stackTrace) {
      _changeStateLoading(false);
    });
  }

  Future<bool> _validate() async {
    if (! await _validatePaymentNumber()) return Future.value(false);
    return Future.value(true);
  }

  Future<bool> _validatePaymentNumber() async {
    bool valid = true;
    bool warning = false;
    String msgError = 'Error indeterminado';

    await fetchDataObject(
        uri: '$uriCustomerFindPaymentNumber/${_buildPaymentNumber()}',
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
      customerId: _customerId <= 0 ? null : _customerId,
      user: UserDTO1(userId: userLogged!.userId),
      document: int.parse(_documentController.text.trim()),
      addDate: strToDate(_dateController.text),
      lastname: _lastnameController.text.trim(),
      name: _nameController.text.trim(),
      paymentNumber: _buildPaymentNumber(),
      telephone: _telephoneController.text.trim(),
      notes: _notesController.text.trim(),
      partner: _partnerId != 0 && _dependentId == 0,
      partnerId: _partnerId,
      dependentId: _dependentId,
      deleted: false,
    );
  }

  void _cancelForm() {
    widget.onCancel(); // Llamar al callback de cancelación
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
    _documentFocusNode.addListener(_documentListener);
    _dateFocusNode.addListener(_dateListener);
  }

  Future<void> _documentListener() async {
    // Pierde foco
    if (!_documentFocusNode.hasFocus) {
      await _handleDocumentValidation();
      // Recibe foco
    } else if (_documentFocusNode.hasFocus) {
      _initialize(initDocument: true);
    }
  }

  Future<void> _handleDocumentValidation() async {
    // Eliminar el listener y quita el foco temporalmente para evitar llamadas duplicadas
    _documentFocusNode.removeListener(_documentListener);
    _documentFocusNode.unfocus();
    bool isValid = await _validateDocument();
    _documentFocusNode.addListener(_documentListener);
    if (mounted) {
      if (isValid) {
        FocusScope.of(context).requestFocus(_dateFocusNode);
      } else {
        FocusScope.of(context).requestFocus(_documentFocusNode);
      }
    }
  }

  Future<bool> _validateDocument() async {
    bool? registered;
    PartnerNovaDailyDTO? partner;
    DependentNovaDailyDTO? dependent;

    if (_documentController.text.trim().isEmpty) {
      return Future.value(false);
    }
    if (! _formDocumentKey.currentState!.validate()) {
      return Future.value(false);
    }

    registered = await _registeredDocumentNovaFarma();
    if (registered != null) {
      _isAdd = ! registered;
      if (! registered && mounted){
        //No esta registrado en NovaFarma. Se pregunta si desea buscar en NovaDaily
        if (await _findInNovaDaily() && mounted) {
          _changeStateLoading(true);
          //Busca en Socios
          try {
            partner = await findPartnerByDocumentNovaDaily(
                document: _documentController.text.trim(),
                context: context
            );
            if (partner != null) {
              _updateFields(partner);
            } else if (mounted) {
              //busca en dependientes
              dependent = await findDependentByDocumentNovaDaily(
                  document: _documentController.text.trim(),
                  context: context
              );
              if (dependent != null) {
                _updateFields(dependent);
              } else {
                // Es un cliente nuevo de NovaFarma (no esta en NovaDaily)
                setState(() {
                  _customerId = 0;
                });
              }
            }
            _changeStateLoading(false);

          } catch (e) {
            _changeStateLoading(false);
            return Future.value(false);
          }

        } else {
          return Future.value(false);
        }
      }
    } else {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<bool> _findInNovaDaily() async {
    return await OpenDialog(
      title: 'No encontrado',
      content: 'Cliente no registado en NovaFarma.\n'
          '¿Desea buscarlo en NovaDaily?',
      textButton1: 'Si',
      textButton2: 'No',
      context: context,
     ).view() == 1;
  }

  void _dateListener() {
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
  }

  /// true si el documento ya existe en la bbdd de novafarma, false si no existe.
  /// null si se lanzó un error.
  Future<bool?> _registeredDocumentNovaFarma() async {
    bool? registered;
    List<CustomerDTO1> customerList = [];
    _changeStateLoading(true);
    try {
      await fetchCustomerList(
          customerList: customerList,
          searchByDocument: true,
          value: _documentController.text,
      );
      _updateFields(customerList[0]);
      registered = true;

    } catch (error) {
      if (error is ErrorObject && error.statusCode == HttpStatus.notFound) {
          registered = false;
      } else {
        if (mounted) handleError(error: error, context: context);
      }
    } finally {
      _changeStateLoading(false);
    }
    return Future.value(registered);
  }

  /// customer: puede ser un CustomerDTO1 o un PartnerNovaDailyDTO
  void _updateFields(Object customer) {
    if (customer is CustomerDTO1) {
      _dateController.value = TextEditingValue(
          text: dateToStr(customer.addDate)!);
      _lastnameController.value = TextEditingValue(text: customer.lastname!);
      _nameController.value = TextEditingValue(text: customer.name);
      _paymentNumberController.value = TextEditingValue(
          text: customer.paymentNumber.toString());
      _telephoneController.value = TextEditingValue(
          text: _buildTelephone(customer.telephone));
      _notesController.value = TextEditingValue(
          text: _buildNotes(customer.notes));

      setState(() {
        _customerId = customer.customerId!;
        _partnerId = customer.partnerId!;
        _dependentId = customer.dependentId!;
      });

    } else if (customer is PartnerNovaDailyDTO) {
      _dateController.value = TextEditingValue(text:
        customer.addDate != null
          ? customer.addDate!
          : dateNow()
      );
      _lastnameController.value = TextEditingValue(text: customer.lastname!);
      _nameController.value = TextEditingValue(text: customer.name!);
      _paymentNumberController.value = TextEditingValue(
          text: customer.paymentNumber.toString());
      _telephoneController.value = TextEditingValue(text: customer.telephone!);
      _notesController.value = TextEditingValue(text: _buildNotes(customer.notes));

      setState(() {
        _customerId = 0; // indica que no se encontro el cliente en NovaFarma
        _partnerId = customer.partnerId!;
        _dependentId = 0;
      });

    } else if (customer is DependentNovaDailyDTO) {
      _dateController.value = TextEditingValue(text: dateNow()); // El json del dependiente viene sin fecha de alta
      _lastnameController.value = TextEditingValue(text: customer.lastname!);
      _nameController.value = TextEditingValue(text: customer.name!);
      _paymentNumberController.value = const TextEditingValue(text: '0');
      _telephoneController.value = const TextEditingValue(text: '');
      _notesController.value = const TextEditingValue(text: '');

      setState(() {
        _customerId = 0; // indica que no se encontro el cliente en NovaFarma
        _partnerId = customer.partnerNovaDaily!.partnerId!;
        _dependentId = customer.dependentId!;
      });
    }
  }

  String _buildTelephone(String? telephone) {
    return telephone ?? '';
  }

  String _buildNotes(String? notes) {
    return notes ?? '';
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
    setState(() {
      _customerId = -1;
      _dependentId = 0;
      _partnerId = 0;
    });
  }

  void _changeStateLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
    widget.onBlockedStateChange!(isLoading);
  }

  Widget _labelCustomer(){
    //print('$_customerId - $_partnerId - $_dependentId');
    if (_customerId == -1) return const SizedBox.shrink();
    String lbl = '';
    if (_partnerId == 0) {
      lbl = 'NovaFarma';
    } else {
      lbl = _dependentId != 0 ? 'Dependiente' : 'Socio';
    }

    return lbl.isNotEmpty
      ? Row(
          children: [
            Text(lbl == 'NovaFarma' ? ' Cliente ' : 'Tomado de NovaDaily: ',
              style: const TextStyle(fontStyle: FontStyle.italic)
            ),
            Text(lbl, style: const TextStyle(fontWeight: ui.FontWeight.bold),)
          ]
        )
      : const SizedBox.shrink();

    /*if (_partnerId == 0 && _dependentId == 0) return const SizedBox.shrink();
    String lbl = 'Socio';
    if (_partnerId != 0 && _dependentId != 0) lbl =  'Dependiente';
    return Row(
      children: [
        const Text('Tomado de NovaDaily: ',
            style: TextStyle(fontStyle: FontStyle.italic)
        ),
        Text(lbl, style: const TextStyle(fontWeight: ui.FontWeight.bold),)
      ],
    );*/
  }

  int _buildPaymentNumber() {
    return int.parse(
        _paymentNumberController.text.trim().isNotEmpty
            ? _paymentNumberController.text.trim()
            : '0'
    );
  }

}
