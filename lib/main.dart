import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => _openMenu(context),
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
        ),
      ),
      body: const Center(
        child: Text(
          'Bienvenido a NovaFarma',
          style: TextStyle(fontSize: 24, color: Colors.black12),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
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
        // Implementa lo que deseas que haga cada opción del menú aquí
        if (result == 'Comprobantes de venta') {
          // Acción para "Comprobantes de venta"
        } else if (result == 'Clientes') {
          // Acción para "Clientes"
        } else if (result == 'Proveedores') {
          // Acción para "Proveedores"
        } else if (result == 'Medicamentos') {
          // Acción para "Medicamentos"
        } else if (result == 'Usuarios y Roles') {
          // Acción para "Usuarios"
        }
      }
    });
  }
}
