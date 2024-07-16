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
  final _paymentNumberController = TextEditingController();
  final _userIdController = TextEditingController();
  final _dependentIdController = TextEditingController();
  final _partnerIdController = TextEditingController();
  final _deletedController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  controller: _deletedController,
                  decoration: InputDecoration(labelText: 'Deleted'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, ingresa el estado de eliminación';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dependentIdController,
                  decoration: InputDecoration(labelText: 'ID Dependiente'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, ingresa el ID del dependiente';
                    }
                    return null;
                  },
                ),
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
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notas'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, ingresa las notas';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _partnerIdController,
                  decoration: InputDecoration(labelText: 'ID del Partner'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, ingresa el ID del partner';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _paymentNumberController,
                  decoration: InputDecoration(labelText: 'Número de Pago'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, ingresa el número de pago';
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
                  controller: _userIdController,
                  decoration: InputDecoration(labelText: 'ID de Usuario'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, ingresa el ID de usuario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (await _confirm() == 1) {
                          _submitForm();
                        }
                      },
                      child: const Text('Aceptar'),
                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
