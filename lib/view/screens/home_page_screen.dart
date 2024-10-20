import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/task_enum.dart';
import 'package:novafarma_front/model/globals/publics.dart';
import 'package:novafarma_front/model/globals/requests/logout.dart';
import 'package:novafarma_front/model/globals/taskEnabled.dart';
import 'package:novafarma_front/view/screens.dart';

class HomePageScreen extends StatefulWidget {
  final String title;

  const HomePageScreen({super.key, required this.title});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  static const Widget msgHomeScreen = Text('Bienvenido a NovaFarma');

  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _userIconKey = GlobalKey(); // GlobalKey para el icono de usuario

  bool _enableMenu = true;
  Widget _currentWidget = msgHomeScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          key: _menuButtonKey,
          onPressed: () => _enableMenu ? _openMenu(context) : null,
          icon: const Icon(Icons.menu),
          color: _enableMenu ? Colors.black : Colors.grey,
          tooltip: 'Menu',
        ),
        actions: [
          // Icono de usuario que abre el modal al hacer clic
          IconButton(
            key: _userIconKey, // Asigna la GlobalKey aquí
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              _showUserMenu(context); // Mostrar menú al presionar el icono
            },
          ),
        ],
      ),
      body: Center(
        child: _currentWidget,
      ),
    );
  }
  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          key: _menuButtonKey,
          onPressed: () => _enableMenu ? _openMenu(context) : null,
          icon: const Icon(Icons.menu),
          color: _enableMenu ? Colors.black : Colors.grey,
          tooltip: 'Menu',
        ),
      ),
      body: Center(
        child: _currentWidget,
      ),
    );
  }

   */

  void _openMenu(BuildContext context) {
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
      items: _buildItems(context, tilePosition),
    ).then((String? result) {
      if (result != null) {
        if (result == 'users and roles') {
          setState(() {
            _currentWidget = _buildUsersAndRolesWidget();
          });
        }
      }
    });
  }

  List<PopupMenuEntry<String>> _buildItems(BuildContext context, Offset tilePosition) {
    return [
      if (! _isSuperAdmin())
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

      if (! _isSuperAdmin())
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

      if (! _isSuperAdmin())
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

      if (! _isSuperAdmin())
        PopupMenuItem<String>(
          value: 'articles',
          child: ListTile(
            leading: const Icon(Icons.local_pharmacy),
            title: const Text('Artículos', style: TextStyle(fontSize: 17.0)),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () {
              _openSubMenuArticles(context, tilePosition);
            },
          ),
        ),

      if (_isSuperAdmin())
        const PopupMenuItem<String>(
          value: 'users and roles',
          child: ListTile(
            leading: Icon(Icons.people),
            title: Text('Usuarios y roles', style: TextStyle(fontSize: 17.0)),
          ),
        ),
    ];
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
        if (taskEnabled(TaskEnum.voucherEmit))
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
        if (taskEnabled(TaskEnum.customerAddUpdate))
          const PopupMenuItem<String>(
            value: 'customers_add_update',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Agregar o actualizar clientes'),
            ),
          ),
        if (taskEnabled(TaskEnum.customerList))
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
        if (taskEnabled(TaskEnum.supplierAddUpdate))
          const PopupMenuItem<String>(
            value: 'suppliers_add_update',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Agregar o actualizar proveedores'),
            ),
          ),
        if (taskEnabled(TaskEnum.supplierList))
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

  void _openSubMenuArticles(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 240, position.dy + 200, 0, 0), // Coordenadas originales
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        PopupMenuItem<String>(
          value: 'medicines',
          child: ListTile(
            leading: const Icon(Icons.medical_information),
            title: const Text('Medicamentos'),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () => _openSubMenuMedicines(context, position),
          ),
        ),
        PopupMenuItem<String>(
          value: 'presentations',
          child: ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Presentaciones'),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () => _openSubMenuPresentations(context, position),
          ),
        ),
        PopupMenuItem<String>(
          value: 'units',
          child: ListTile(
            leading: const Icon(Icons.ac_unit_sharp),
            title: const Text('Unidades de medida'),
            trailing: const Icon(Icons.arrow_right),
            hoverColor: Colors.transparent,
            onTap: () => _openSubMenuUnits(context, position),
          ),
        ),
      ],
    );
  }

  void _openSubMenuMedicines(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 473, position.dy + 200, 0, 0), // Coordenadas originales
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        if (taskEnabled(TaskEnum.medicineAddUpdate))
          const PopupMenuItem<String>(
            value: 'medicines_add_update',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Agregar o actualizar medicamentos'),
              hoverColor: Colors.transparent,
            ),
          ),
        if (taskEnabled(TaskEnum.medicineList))
          const PopupMenuItem<String>(
          value: 'medicine_list',
          child: ListTile(
            leading: Icon(Icons.list),
            title: Text('Listar medicamentos'),
          ),
        ),
        if (taskEnabled(TaskEnum.nursingReport))
          const PopupMenuItem<String>(
            value: 'medicine_nursing_report',
            child: ListTile(
              leading: Icon(Icons.table_rows),
              title: Text('Informe de enfermería'),
            ),
          ),
      ],
    ).then((String? result) async {
      if (result != null) {
        //Navigator.popUntil(mounted ? context : context, (route) => route.isFirst); // Cierra todos los menús
        if (result == 'medicines_add_update') {
          await _goAddOrUpdateMedicineScreen();
        } else if (result == 'medicine_list') {
          await _goListMedicineScreen();
        } else if (result == 'medicine_nursing_report') {
          await _goNursingReport();
        }
        Navigator.popUntil(mounted ? context : context, (route) => route.isFirst); // Cierra todos los menús
      }
    });
  }

  void _openSubMenuPresentations(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 473, position.dy + 243, 0, 0), // Coordenadas originales
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        if (taskEnabled(TaskEnum.presentationAddUpdate))
          const PopupMenuItem<String>(
            value: 'presentations_add_update',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Agregar o actualizar presentaciones'),
              hoverColor: Colors.transparent,
            ),
          ),
        if (taskEnabled(TaskEnum.presentationList))
          const PopupMenuItem<String>(
            value: 'presentation_list',
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text('Listar presentaciones'),
            ),
          ),
      ],
    ).then((String? result) async {
      if (result != null) {
        //Navigator.popUntil(mounted ? context : context, (route) => route.isFirst); // Cierra todos los menús
        if (result == 'presentations_add_update') {
          await _goAddOrUpdatePresentationScreen();
        } else if (result == 'presentation_list') {
          await _goListPresentationScreen();
        }
        Navigator.popUntil(mounted ? context : context, (route) => route.isFirst); // Cierra todos los menús
      }
    });
  }

  void _openSubMenuUnits(BuildContext context, Offset position) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect subMenuPosition = RelativeRect.fromRect(
      Rect.fromLTWH(position.dx + 473, position.dy + 297, 0, 0), // Coordenadas originales
      Offset.zero & overlay.size,
    );
    showMenu<String>(
      context: context,
      position: subMenuPosition,
      elevation: 8.0,
      items: [
        if (taskEnabled(TaskEnum.unitAddUpdate))
          const PopupMenuItem<String>(
            value: 'units_add_update',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Agregar o actualizar unidades de medida'),
              hoverColor: Colors.transparent,
            ),
          ),
        if (taskEnabled(TaskEnum.unitList))
          const PopupMenuItem<String>(
            value: 'units_list',
            child: ListTile(
              leading: Icon(Icons.list),
              title: Text('Listar unidades de medida'),
            ),
          ),
      ],
    ).then((String? result) async {
      if (result != null) {
        //Navigator.popUntil(mounted ? context : context, (route) => route.isFirst); // Cierra todos los menús
        if (result == 'units_add_update') {
          await _goAddOrUpdateUnitsScreen();
        } else if (result == 'units_list') {
          await _goListUnitScreen();
        }
        Navigator.popUntil(mounted ? context : context, (route) => route.isFirst); // Cierra todos los menús
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

  Future<void> _goAddOrUpdateMedicineScreen() async {
    setState(() {
      _currentWidget = AddOrUpdateMedicineScreen(
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

  Future<void> _goAddOrUpdatePresentationScreen() async {
    setState(() {
      _currentWidget = AddOrUpdatePresentationScreen(
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

  Future<void> _goAddOrUpdateUnitsScreen() async {
    setState(() {
      _currentWidget = AddOrUpdateUnitScreen(
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

  Future<void> _goListMedicineScreen() async {
    setState(() {
      _currentWidget = ListMedicineScreen(
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Future<void> _goNursingReport() async {
    setState(() {
      _currentWidget = NursingReportScreen(
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Future<void> _goListPresentationScreen() async {
    setState(() {
      _currentWidget = ListPresentationScreen(
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

  Future<void> _goListUnitScreen() async {
    setState(() {
      _currentWidget = ListUnitScreen(
        onCancel: () {
          setState(() {
            _currentWidget = msgHomeScreen;
          });
        },
      );
    });
  }

  Widget _buildUsersAndRolesWidget() {
    return const UserRoleTaskScreen();
  }

  bool _isSuperAdmin() =>
      userLogged?.userId == 0 && userLogged?.role!.name! == 'Super Administrador';

  void _showUserMenu(BuildContext context) {
    // Asegurarse de que el widget esté completamente construido antes de obtener la posición
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtener el RenderBox del icono de usuario utilizando la GlobalKey
      final RenderBox button =
        _userIconKey.currentContext!.findRenderObject() as RenderBox;
      final Offset buttonPosition = button.localToGlobal(Offset.zero); // Obtener la posición global del icono de usuario
      final RelativeRect position = RelativeRect.fromLTRB(
        buttonPosition.dx,  // Posición X (alineado al ícono)
        kToolbarHeight,
        buttonPosition.dx + button.size.width,
        0,
      );

      showMenu(
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            enabled: false, // No seleccionable, solo para mostrar el contenido personalizado
            child: Container(
              padding: const EdgeInsets.all(16.0),
              width: 250, // Ancho del menú
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 80,),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            '${userLogged!.name} ${userLogged!.lastname}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      /*IconButton(
                        icon: Icon(Icons.edit, size: 18),
                        onPressed: () {
                          Navigator.pop(context); // Cerrar el menú
                          _updateProfile();
                        },
                      ),*/
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${userLogged!.role!.name}',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // Botón que ocupe tod@ el ancho
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (await logout(context)) {
                          Navigator.pushReplacement(
                            mounted ? context : context,
                            MaterialPageRoute(builder: (context) =>
                              const LoginScreen())
                          );
                        }
                      },
                      icon: Icon(Icons.logout),
                      label: Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }


}
