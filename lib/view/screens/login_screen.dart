import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/data_types_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/label_button_icon.dart';
import 'package:novafarma_front/model/globals/requests/do_login.dart';
import 'package:novafarma_front/model/globals/tools/create_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/view/screens/super_admin_screen.dart';
import 'package:pf_care_front/model/enums/data_types_enum.dart';
import 'package:pf_care_front/model/globals/constants.dart';
import 'package:pf_care_front/model/globals/tools/create_text_form_field.dart';
import 'package:pf_care_front/model/globals/tools/floating_message.dart';
import 'package:pf_care_front/model/globals/label_button_icon.dart';
import 'package:pf_care_front/model/globals/publics.dart' show userLogged;
import 'package:pf_care_front/model/globals/requests/do_login.dart';
import 'package:pf_care_front/view/screens.dart';
import '../../model/globals/build_title.dart';
import '../../model/globals/tools/open_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identificationDocumentController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _identificationDocumentController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final ColorScheme color = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Oculta la flecha de "Atrás"
        title: buildTitle(
            color: color,
            title: "Cuidarte",
            fontSizeTitle: 25.0,
            subtitle: "Durazno te cuida"
        ),
        backgroundColor: Colors.black12,
      ),

      // Scroll al girar la pantalla
      body: SingleChildScrollView(

        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Image.asset(
                'assets/images/lara.jpeg',
                //Reduce la iamgen de forma proporcional
                width: MediaQuery.of(context).size.width * (85 / 100),
                height: MediaQuery.of(context).size.height * (37 / 100),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
              child: CreateTextFormField(
                controller: _identificationDocumentController,
                label: "Documento (sólo números)",
                validate: false,
                dataType: DataTypesEnum.identificationDocument,

              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
              child: CreateTextFormField(
                  controller: _passController,
                  label: "Contraseña",
                  dataType: DataTypesEnum.password),
            ),

            Container(
              width: double.infinity, // Toma el ancho disponible
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    //Es super admin?
                    if (_identificationDocumentController.text.trim() ==
                        superAdminUser && _passController.text == superAdminPass) {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const SuperAdminScreen()));
                        _clearCredentials();
                    } else {
                        if (_identificationDocumentController.text
                            .trim().isEmpty || _passController.text.trim().isEmpty) {
                          floatingMessage(context,
                              "Ingrese documento de identidad y contraseña");
                          return;
                      }
                      var result = await login();
                      if (!context.mounted) return;
                      if (result.$1 != null) {
                          _updateUserLogged(result.$1!);
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => SelectRoleScreen()));
                          _clearCredentials();
                      } else {
                          floatingMessage(context, result.$2!);
                      }
                    }
                  } catch (e) {
                      floatingMessage(context, "Error en el servidor");
                  }
                },
                label: labelButtonIcon("Ingresar"),
                icon: const Icon(Icons.login),
              ),

            ),

            TextButton.icon(
              icon: const Icon(Icons.add_box_outlined),
              label: Text(
                'Registrarse', style: TextStyle(color: color.secondary),),
              onPressed: () async {
                bool accepted = await _disclaimAccept();
                if (accepted) _navigateToRegisterScreen();
              },
            ),

            /**TextButton(
                onPressed: () {},
                child: Text(
                'Olvidé la contraseña',
                style: TextStyle(
                color: color.secondary,
                ),
                ),
                ),*/

          ],
        ),
      ),
    );
  }

  void _clearCredentials() {
    _identificationDocumentController.clear();
    _passController.clear();
  }

  void _navigateToRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const RegisterScreen()),
    );
  }

  void _updateUserLogged(Map<String, dynamic> user) {
    userLogged = {
      'userId': user['userId'],
      'identificationDocument': user['identificationDocument'],
      'name': user['name'],
      'surname': user['surname'],
      'roles': user['roles'],
      'residenceZone': user['residenceZone']
    };
  }

  Future<(Map<String, dynamic>?, String?)> login() async {
      return await doLogin(
          identificationDocument: int.parse(_identificationDocumentController.text),
          pass: _passController.text);
  }

  Future<bool> _disclaimAccept() async {
    int response = await OpenDialog(
        context: context,
        title: "Términos y condiciones",
        content: _disclaim,
        smallFont: true,
        textButton1: "Acepto",
        textButton2: "No acepto"
    ).view();
    return response == 1;
  }

  final String _disclaim = "Descargo de responsabilidad de la aplicación Cuidarte.\n"
      "Bienvenido a la aplicación Cuidarte, una plataforma que facilita el contacto entre personas que "
      "necesitan servicios de cuidados paliativos y empresas voluntarias y "
      "personas dispuestas a ofrecerlos.\n"
      "Antes de utilizar nuestra aplicación, lea atentamente este descargo de responsabilidad.\n"
      "1. Propósito de la aplicación: La aplicación Cuidarte tiene como objetivo proporcionar"
      " un espacio donde las personas que necesitan servicios de cuidados paliativos "
      "pueden conectarse con cuidadores voluntarios, empresas y personas"
      " que desean brindar apoyo y asistencia."
      " La información y los servicios proporcionados en esta aplicación están"
      " destinados a facilitar la prestación de cuidados en situaciones de cuidados paliativos.\n"
      "2. Información y asesoramiento: La información proporcionada en la aplicación Cuidarte se ofrece "
      "con fines informativos y de apoyo. No somos responsables de"
      " la precisión o idoneidad de la información proporcionada por los usuarios, empresas voluntarias"
      " o cuidadores. Le recomendamos verificar y confirmar cualquier información crítica antes"
      " de tomar decisiones importantes relacionadas con los cuidados paliativos.\n"
      " 3. Cuidadores y empresas voluntarias: La aplicación Cuidarte permite a los usuarios"
      " buscar y conectarse con cuidadores voluntarios, empresas y personas que ofrecen"
      " servicios de cuidados paliativos. No somos responsables de la calidad de los servicios"
      " proporcionados por estas empresas, voluntarios o cuidadores. "
      "Le recomendamos realizar una revisión cuidadosa y comunicarse directamente con los proveedores"
      " antes de aceptar cualquier servicio.\n"
      "4. Privacidad y seguridad: Valoramos la privacidad"
      " y la seguridad de nuestros usuarios. Hacemos todo lo posible para garantizar"
      " la protección de los datos personales y la información confidencial. "
      "Sin embargo, no podemos garantizar la seguridad absoluta de la información compartida"
      " a través de la aplicación.\n"
      "5. Cambios en los términos: Nos reservamos el derecho de cambiar"
      " o actualizar estos términos y condiciones en cualquier momento. Los cambios entrarán"
      " en vigencia inmediatamente después de su publicación en nuestra aplicación.\n"
      "6. Aceptación de términos: El uso continuado de la aplicación Cuidarte implica la"
      " aceptación de estos términos y condiciones. La aplicación Cuidarte se compromete a facilitar la conexión "
      "entre personas que necesitan cuidados paliativos, empresas voluntarias y personas que"
      " desean brindar apoyo, pero no asume responsabilidad por la calidad de los servicios o la"
      " información proporcionada. Le instamos a utilizar la aplicación con precaución y a buscar"
      " asesoramiento profesional cuando sea necesario.\n"
      "Gracias por confiar en Cuidarte para sus necesidades de"
      " cuidados paliativos.";

}
