import 'package:flutter/material.dart';
import 'package:novafarma_front/view/screens.dart';

import 'add_or_update_supplier_screen.dart';

class HomePageScreen extends StatefulWidget {
  final String title;

  const HomePageScreen({super.key, required this.title});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  static const Widget msgHomeScreen = Text('Bienvenido a NovaFarma');

  final GlobalKey _menuButton = GlobalKey();
  bool _enableMenu = true;
  Widget _currentWidget = msgHomeScreen; // Widget inicial

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          key: _menuButton,
          onPressed: () => _enableMenu ? _openMenu(context) : null,
          icon: const Icon(Icons.menu),
          color: _enableMenu ? Colors.black : Colors.grey,
          tooltip: 'Menu',
        ),
      ),
      body: Center(
        child: _currentWidget, // Mostrar el widget actual
      ),
    );
  }

  void _openMenu(BuildContext context) {
    //final RenderBox button = _menuButton.currentContext!.findRenderObject() as RenderBox;
    //final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    const RelativeRect position = RelativeRect.fromLTRB(
      0, // Left
      kToolbarHeight, // Top
      0, // Right
      0, // Bottom
    );
    final RenderBox tileBox = context.findRenderObject() as RenderBox;
    final Offset tilePosition = tileBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: position,
      elevation: 8.0,
      items: [
        PopupMenuItem<String>(
          value: 'vouchers',
          child: ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Comprobantes', style: TextStyle(fontSize: 17.0)),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () {
              _openSubMenuVouchers(context, tilePosition);
            },
          ),
        ),

        PopupMenuItem<String>(
          value: 'customers',
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Clientes', style: TextStyle(fontSize: 17.0)),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () {
              _openSubMenuCustomers(context, tilePosition);
            },
          ),
        ),

        PopupMenuItem<String>(
          value: 'suppliers',
          child: ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Proveedores', style: TextStyle(fontSize: 17.0)),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () {
              _openSubMenuSuppliers(context, tilePosition);
            },
          ),
        ),

        const PopupMenuItem<String>(
          value: 'medicines',
          child: ListTile(
            leading: Icon(Icons.local_pharmacy),
            title: Text('Medicamentos', style: TextStyle(fontSize: 17.0)),
          ),
        ),

        const PopupMenuItem<String>(
          value: 'balances',
          child: ListTile(
            leading: Icon(Icons.note_alt_sharp),
            title: Text('Balances', style: TextStyle(fontSize: 17.0)),
          ),
        ),

        /*const PopupMenuItem<String>(
          value: 'users and roles',
          child: ListTile(
            leading: Icon(Icons.people),
            title: Text('Usuarios y roles', style: TextStyle(fontSize: 17.0)),
          ),
        ),*/
      ],
    ).then((String? result) {
      if (result != null) {
        if (result == 'medicines') {
          setState(() {
            _currentWidget = _buildMedicinesWidget();
          });
        } else if (result == 'balances') {
          setState(() {
            _currentWidget = _buildBalancesWidget();
          });
        } else if (result == 'users and roles') {
          setState(() {
            _currentWidget = _buildUsersAndRolesWidget();
          });
        }
      }
    });
  }

  void _openSubMenuVouchers(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 240, position.dy + 57, 0, 0),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        const PopupMenuItem<String>(
          value: 'vouchers_emit',
          child: ListTile(
            leading: Icon(Icons.assignment_outlined),
            title: Text('Emitir'),
          ),
        ),
      ],
    ).then((String? result) {
      if (result != null) {
        Navigator.pop(context);
        if (result == 'vouchers_emit') {
          setState(() {
            _currentWidget = _buildIssueVouchersWidget();
          });
        }
      }
    });
  }

  void _openSubMenuCustomers(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 240, position.dy + 103, 0, 0),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        const PopupMenuItem<String>(
          value: 'customers_add_update',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Agregar o actualizar clientes'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'customers_list',
          child: ListTile(
            leading: Icon(Icons.list),
            title: Text('Listar clientes'),
          ),
        ),
      ],
    ).then((String? result) async {
      if (result != null) {
        Navigator.pop(context);
        if (result == 'customers_add_update') {
          await _goAddOrUpdateCustomerScreen();
        } else  if (result == 'customers_list') {
          await _goListCustomerScreen();
        }
      }
    });
  }

  void _openSubMenuSuppliers(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 240, position.dy + 151, 0, 0),
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        const PopupMenuItem<String>(
          value: 'suppliers_add_update',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Agregar o actualizar proveedores'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'supplier_list',
          child: ListTile(
            leading: Icon(Icons.list),
            title: Text('Listar proveedores'),
          ),
        ),
      ],
    ).then((String? result) async {
      if (result != null) {
        Navigator.pop(context);
        if (result == 'suppliers_add_update') {
          await _goAddOrUpdateSupplierScreen();
        } else  if (result == 'supplier_list') {
          await _goListSupplierScreen();
        }
      }
    });
  }

  Future<void> _goAddOrUpdateCustomerScreen() async {
    setState(() {
      _currentWidget = AddOrUpdateCustomerScreen(
        onBlockedStateChange: (block) {
          setState(() {
            _enableMenu = !block;
          });
        },
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Future<void> _goListCustomerScreen() async {
    setState(() {
      _currentWidget = ListCustomerScreen(
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Future<void> _goAddOrUpdateSupplierScreen() async {
    setState(() {
      _currentWidget = AddOrUpdateSupplierScreen(
        onBlockedStateChange: (block) {
          setState(() {
            _enableMenu = !block;
          });
        },
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Future<void> _goListSupplierScreen() async {
    setState(() {
      _currentWidget = ListSupplierScreen(
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Widget _buildIssueVouchersWidget() {
    return IssueVoucherScreen(
      onBlockedStateChange: (block) {
        setState(() {
          _enableMenu = !block;
        });
      },
    );
  }

  Widget _buildMedicinesWidget() {
    return const MedicineScreen();
  }

  Widget _buildBalancesWidget() {
    return const BalanceScreen();
  }

  Widget _buildUsersAndRolesWidget() {
    return const UserRoleTaskScreen();
  }
}
