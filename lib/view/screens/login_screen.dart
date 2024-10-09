import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novafarma_front/model/DTOs/role_dto4.dart';
import 'package:novafarma_front/model/DTOs/user_dto.dart';
import 'package:novafarma_front/model/DTOs/user_jwt_dto.dart';
import 'package:novafarma_front/model/enums/data_type_enum.dart';
import 'package:novafarma_front/model/enums/message_type_enum.dart';
import 'package:novafarma_front/model/enums/request_type_enum.dart';
import 'package:novafarma_front/model/globals/constants.dart';
import 'package:novafarma_front/model/globals/generic_error.dart';
import 'package:novafarma_front/model/globals/publics.dart';
import 'package:novafarma_front/model/globals/requests/logout.dart';
import 'package:novafarma_front/model/globals/tools/build_circular_progress.dart';
import 'package:novafarma_front/model/globals/tools/custom_text_form_field.dart';
import 'package:novafarma_front/model/globals/tools/fetch_data_object.dart';
import 'package:novafarma_front/model/globals/tools/floating_message.dart';
import 'package:novafarma_front/model/objects/error_object.dart';
import 'package:novafarma_front/view/dialogs/update_pass_dialog.dart';
import '../../model/DTOs/user_dto_4.dart';
import 'home_page_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de sesión en NovaFarma'),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: _buildBoxLogin(context),
          ),
          if (_isLoading)
          Positioned.fill(
            child: Container(
                child: buildCircularProgress(size: 30.0)
            ),
          ),
        ]
      ),
    );
  }

  Center _buildBoxLogin(BuildContext context) {
    return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Inicio de sesión',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _userNameController,
                      focusNode: _usernameFocusNode,
                      label: 'Usuario',
                      initialFocus: true,
                      textForValidation: 'Por favor, ingrese su usuario',
                      viewCharactersCount: false,
                      isUnderline: false,
                      acceptEmpty: false,
                      dataType: DataTypeEnum.text,
                      onEditingComplete:  () =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    ),
                    const SizedBox(height: 20.0),
                    CustomTextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Contraseña',
                      textForValidation: 'Por favor, ingrese su contraseña',
                      viewCharactersCount: false,
                      isUnderline: false,
                      acceptEmpty: false,
                      dataType: DataTypeEnum.password,
                      onEditingComplete: _login,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Iniciar Sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  Future<void> _login() async {
    if (! _formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    await fetchDataObject<UserJwtDTO>(
      uri: uriUserLogin,
      classObject: UserJwtDTO.empty(),
      body: UserDTO4(
        userName: _userNameController.text,
        password: _passwordController.text
      ),
      requestType: RequestTypeEnum.post,
      includeToken: false,

    ).then((userDb) async {
      setState(() {
        _isLoading = false;
      });
      UserJwtDTO userJwt = userDb[0] as UserJwtDTO;
      if (_userNameController.text.trim() == superAdminUser &&
        _passwordController.text.trim() == superAdminPass) {
        _loginSuperAdmin(userJwt.jwt!);
        return;
      }
      _updateUserLogged(userJwt); // Actualiza el usuario logueado
      if (!userJwt.active! && mounted) {
        FloatingMessage.show(
          context: context,
          text: 'Usuario inactivo',
          messageTypeEnum: MessageTypeEnum.warning
        );
        logout(context);
        return;
      }
      if (userJwt.changeCredentials!) {
        await showDialog<String>(
          context: mounted ? context : context,
          builder: (BuildContext context) {
            return UpdatePassDialog(userId: userJwt.userId!);
          },
        );
        _passwordController.value = TextEditingValue.empty;
        logout(mounted ? context : context);
        return;
      }
      if (userJwt.role?.taskList == null || userJwt.role!.taskList!.isEmpty) {
        FloatingMessage.show(
          context: mounted ? context : context,
          text: 'Su rol \'${userJwt.role?.name}\' no tiene tareas asignadas. '
              'Comuníquese con el administrador del software.',
          messageTypeEnum: MessageTypeEnum.warning
        );
        _passwordController.value = TextEditingValue.empty;
        logout(mounted ? context : context);
        return;
      }
      Navigator.pushReplacement(
        mounted ? context : context,
        MaterialPageRoute(builder: (context) =>
          const HomePageScreen(title: 'NovaFarma')),
      );

    }).onError((error, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      if (error is ErrorObject) {
        if (error.statusCode == HttpStatus.notFound) {
          FloatingMessage.show(
              context: mounted ? context : context,
              text: 'Usuario o contraseña incorrecta',
              messageTypeEnum: MessageTypeEnum.warning
          );
        } else {
          FloatingMessage.show(
              context: mounted ? context : context,
              text: error.message ?? 'Error ${error.statusCode}',
              messageTypeEnum: MessageTypeEnum.warning
          );
        }
      } else if (mounted) {
        genericError(error!, isFloatingMessage: true, context);
      }
    });
  }

  // Actualiza el usuario logueado
  void _updateUserLogged(UserJwtDTO userJwt) {
     userLogged!.userId = userJwt.userId;
    userLogged!.name = userJwt.name;
    userLogged!.lastname = userJwt.lastname;
    userLogged!.userName = _userNameController.text;
    userLogged!.role = RoleDTO4(
      roleId: userJwt.role!.roleId,
      name: userJwt.role!.name,
      taskList: userJwt.role?.taskList!
    );
    userLogged!.token = userJwt.jwt!;
  }

  void _loginSuperAdmin(String token) {
    userLogged!.userId = 0;
    userLogged!.name = 'Super';
    userLogged!.lastname = 'Administrador';
    userLogged!.userName = _userNameController.text;
    userLogged!.role = RoleDTO4(
      name: 'Super Administrador',
      roleId: 0,
      taskList: []
    );
    userLogged!.token = token;

    Navigator.pushReplacement(
      mounted ? context : context,
      MaterialPageRoute(builder: (context) =>
      const HomePageScreen(title: 'NovaFarma - administración')),
    );
  }

}
