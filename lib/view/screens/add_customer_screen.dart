import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  final _dateController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _telephoneController = TextEditingController();
  //final _paymentNumberController = TextEditingController();

  final _documentFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();
  final _lastnameFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();
  final _telephoneFocusNode = FocusNode();

  int _paymentNumbe = 0, _dependentId = 0, _partnerId = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño vertical al contenido
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleBar(),
              _buildBody(),
            ],
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
        'Agregar clientes',
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
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño vertical al contenido
          children: [
            CreateTextFormField(
              label: 'Documento',
              controller: _documentController,
              focusNode: _documentFocusNode,
              dataType: DataTypeEnum.identificationDocument,
              textForValidation: 'Ingrese un documento válido',
              acceptEmpty: false,
              initialFocus: true,
            ),
            CreateTextFormField(
              label: 'Fecha de ingreso',
              controller: _dateController,
              focusNode: _dateFocusNode,
              dataType: DataTypeEnum.date,
              textForValidation: 'Ingrese una fecha válida',
              acceptEmpty: false,
            ),
            CreateTextFormField(
              label: 'Apellido',
              controller: _lastnameController,
              focusNode: _lastnameFocusNode,
              dataType: DataTypeEnum.text,
              textForValidation: 'Ingrese un apellido',
              acceptEmpty: false,
            ),
            CreateTextFormField(
              label: 'Nombre',
              controller: _nameController,
              focusNode: _nameFocusNode,
              dataType: DataTypeEnum.text,
              textForValidation: 'Ingrese un nombre',
              acceptEmpty: false,
            ),
            CreateTextFormField(
              label: 'Teléfono',
              controller: _telephoneController,
              focusNode: _telephoneFocusNode,
              dataType: DataTypeEnum.telephone,
              acceptEmpty: true,
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
            _footerBody(),
          ],
        ),
      ),
    );
  }

  Widget _footerBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () async {
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Llamar a la API REST para guardar el paciente
      // Aquí puedes implementar tu lógica de solicitud REST
      print('Paciente guardado');
    }
  }

  void _cancelForm() {
    Navigator.of(context).pop();
  }

  Future<int> _confirm() async {
    return await OpenDialog(
        title: 'Confirmar',
        content: '¿Agregar el cliente?',
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

}
