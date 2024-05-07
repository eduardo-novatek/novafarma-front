import 'package:flutter/material.dart';
//import 'package:novafarma_front/view/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaFarma',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlueAccent,
        ),
      ),
      home: const MyHomePage(title: 'NovaFarma'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _currentWidget = Container(); // Widget inicial

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => _openMenu(context),
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
        ),
      ),
      body: Center(
        child: _currentWidget, // Mostrar el widget actual
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, kToolbarHeight), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(0, kToolbarHeight)), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'Comprobantes de venta',
          child: Text('Comprobantes de venta'),
        ),
        const PopupMenuItem<String>(
          value: 'Clientes',
          child: Text('Clientes'),
        ),
        const PopupMenuItem<String>(
          value: 'Proveedores',
          child: Text('Proveedores'),
        ),
        const PopupMenuItem<String>(
          value: 'Medicamentos',
          child: Text('Medicamentos'),
        ),
        const PopupMenuItem<String>(
          value: 'Usuarios y Roles',
          child: Text('Usuarios y Roles'),
        ),
      ],
      elevation: 8.0,
    ).then((String? result) {
      if (result != null) {
        if (result == 'Usuarios y Roles') {
          setState(() {
            _currentWidget = _buildUsersAndRolesWidget(); // Actualizar el widget actual
          });
        } else {
          // manejar las otras opciones del menú
        }
      }
    });
  }

  Widget _buildUsersAndRolesWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const UsersAndRoles(),
    );
  }
}

class UsersAndRoles extends StatelessWidget {
  const UsersAndRoles({Key? key}) : super(key: key);

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
