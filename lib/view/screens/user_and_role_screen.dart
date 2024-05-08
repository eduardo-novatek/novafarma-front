import 'package:flutter/cupertino.dart';

class UserAndRoleScreen extends StatefulWidget {
  const UserAndRoleScreen({super.key});

  @override
  State<UserAndRoleScreen> createState() => _UserAndRoleScreenState();
}

class _UserAndRoleScreenState extends State<UserAndRoleScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Contenido de Usuarios y Roles',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
