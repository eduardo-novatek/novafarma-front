import 'package:flutter/material.dart';

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
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: const MyHomePage(title: 'NovaFarma'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => _openMenu(context),
          icon: Icon(Icons.menu),
          tooltip: 'Menu',
        ),
      ),
      body: Center(
        child: Text(
          'Bienvenido a NovaFarma',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'Comprobantes de venta',
          child: const Text('Comprobantes de venta'),
        ),
        PopupMenuItem<String>(
          value: 'Clientes',
          child: const Text('Clientes'),
        ),
        PopupMenuItem<String>(
          value: 'Proveedores',
          child: const Text('Proveedores'),
        ),
        PopupMenuItem<String>(
          value: 'Medicamentos',
          child: const Text('Medicamentos'),
        ),
        PopupMenuItem<String>(
          value: 'Usuarios',
          child: const Text('Usuarios'),
        ),
        PopupMenuItem<String>(
          value: 'Roles',
          child: const Text('Roles'),
        ),
      ],
      elevation: 8.0,
    ).then((String? result) {
      if (result != null) {
        // Implementa lo que deseas que haga cada opción del menú aquí
        if (result == 'Comprobantes de venta') {
          // Acción para "Comprobantes de venta"
        } else if (result == 'Clientes') {
          // Acción para "Clientes"
        } else if (result == 'Proveedores') {
          // Acción para "Proveedores"
        } else if (result == 'Medicamentos') {
          // Acción para "Medicamentos"
        } else if (result == 'Usuarios') {
          // Acción para "Usuarios"
        } else if (result == 'Roles') {
          // Acción para "Roles"
        }
      }
    });
  }
}
