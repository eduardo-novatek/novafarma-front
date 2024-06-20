import 'package:flutter/material.dart';
import 'package:novafarma_front/model/globals/build_circular_progress.dart';
import '../../model/DTOs/supplier_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/fetch_supplier_list.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/constants.dart' show defaultTextFromDropdownMenu;
import '../../model/globals/tools/floating_message.dart';

class SupplierBox extends StatefulWidget {
  //final int selectedId;
  final ValueChanged<SupplierDTO?> onSelectedChanged;
  final ValueChanged<bool>? onRefreshButtonChange;

  const SupplierBox({
    super.key,
    this.onRefreshButtonChange,
    //required this.selectedId,
    required this.onSelectedChanged,
  });

  @override
  SupplierBoxState createState() => SupplierBoxState();
}

class SupplierBoxState extends State<SupplierBox> {

  final List<SupplierDTO> _supplierList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateSupplierList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildRefreshButton(),
              const Text('Proveedor:',
                   style: TextStyle(fontSize: 16.0)
              ),
              _isLoading
                  ? buildCircularProgress()
                  : _buildCustomDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  IconButton _buildRefreshButton() {
    return IconButton(
      onPressed: () async {
        if (!_isLoading) {
          // llama al callback: esta haciendo el refresh...
          if (widget.onRefreshButtonChange != null) {
            widget.onRefreshButtonChange!(true);
          }
          await _updateSupplierList();
          // llama al callback: no está haciendo el refresh...
          if (widget.onRefreshButtonChange != null) widget.onRefreshButtonChange!(false);
        }
      },
      icon: const Icon(
        Icons.refresh_rounded,
        color: Colors.blue,
        size: 16.0,
      ),
    );
  }

  Widget _buildCustomDropdown() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: CustomDropdown<SupplierDTO>(
          themeData: ThemeData(),
          modelList: _supplierList,
          model: _supplierList.isNotEmpty ? _supplierList[0] : null,
          callback: (supplier) {
            setState(() {
              widget.onSelectedChanged(
                SupplierDTO(
                  supplierId: supplier!.supplierId,
                  name: supplier.name,
                  telephone1: supplier.telephone1,
                  telephone2: supplier.telephone2,
                  email: supplier.email,
                  address: supplier.address,
                  notes: supplier.notes,
                )
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> _updateSupplierList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await fetchSupplierList(_supplierList).then((value) {
        _supplierList.insert(
          0,
          SupplierDTO(
            isFirst: true,
            name: defaultTextFromDropdownMenu,
            supplierId: 0,
          ),
        );
        widget.onSelectedChanged(null);
      });
    } catch (error) {
      _showMessageConnectionError(context);
    } finally {
      if (_supplierList.isEmpty) {
        _supplierList.add(
          SupplierDTO(
            isFirst: true,
            name: defaultTextFromDropdownMenu,
            supplierId: 0,
          ),
        );
        widget.onSelectedChanged(null);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessageConnectionError(BuildContext context) {
    floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
    );
  }
}

/*class SupplierBox extends StatefulWidget {
  //late final List<SupplierDTO> supplierList;
  int selectedSupplierId;

  SupplierBox({
    super.key,
    //required this.supplierList,
    required this.selectedSupplierId,
  });

  @override
  SupplierBoxState createState() => SupplierBoxState();
}

class SupplierBoxState extends State<SupplierBox> {
  List<SupplierDTO> _supplierList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateSupplierList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (!_isLoading) {
                      _updateSupplierList();
                    }
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.blue,
                    size: 16.0,
                  ),
                ),
                const Text('Proveedor:', style: TextStyle(fontSize: 16.0)),
              ],
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomDropdown<SupplierDTO>(
                    themeData: ThemeData(),
                    modelList: _supplierList,
                    model: _supplierList.isNotEmpty ? _supplierList[0] : null,
                    callback: (supplier) {
                      setState(() {
                        widget.selectedSupplierId = supplier!.supplierId!;
                      });
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSupplierList() async {
    setState(() {
      _isLoading = true;
    });

    try {
       await fetchSupplierList(_supplierList).then((value) {
         _supplierList.insert(
             0,
             SupplierDTO(
               isFirst: true,
               name: defaultTextFromDropdownMenu,
               supplierId: 0,
         ));
         widget.selectedSupplierId = 0;
       });

    } catch (error) {
        _showMessageConnectionError(context);

    } finally {
      if (_supplierList.isEmpty) {
        _supplierList.add(
            SupplierDTO(
              isFirst: true,
              name: defaultTextFromDropdownMenu,
              supplierId: 0,
            ));
        widget.selectedSupplierId = 0;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessageConnectionError(BuildContext context) {
    floatingMessage(
      context: context,
      text: "Error de conexión",
      messageTypeEnum: MessageTypeEnum.error,
    );
  }
}
*/



