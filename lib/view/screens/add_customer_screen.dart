import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/tools/open_dialog.dart';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _documentController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _telephoneController = TextEditingController();
  //final _paymentNumberController = TextEditingController();

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
            TextFormField(
              controller: _documentController,
              decoration: InputDecoration(labelText: 'Documento'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingresa el documento';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Fecha de ingreso'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingresa la fecha de ingreso';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _lastnameController,
              decoration: InputDecoration(labelText: 'Apellido'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingresa el apellido';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingresa el nombre';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _telephoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingresa el teléfono';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notas'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingresa las notas';
                }
                return null;
              },
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
