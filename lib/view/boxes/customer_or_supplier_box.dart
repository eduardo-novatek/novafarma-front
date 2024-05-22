import 'package:flutter/material.dart';
import 'package:novafarma_front/model/enums/movement_type_enum.dart';
import 'package:novafarma_front/model/globals/build_circular_progress.dart';

import '../../model/DTOs/customer_dto.dart';
import '../../model/DTOs/supplier_dto.dart';
import '../../model/enums/message_type_enum.dart';
import '../../model/globals/requests/fetch_customer_list.dart';
import '../../model/globals/requests/fetch_supplier_list.dart';
import '../../model/globals/tools/custom_dropdown.dart';
import '../../model/globals/constants.dart' show defaultTextFromDropdownMenu;
import '../../model/globals/tools/floating_message.dart';

class CustomerOrSupplierBox extends StatefulWidget {
  final MovementTypeEnum movementType;
  final int selectedId;
  final ValueChanged<int> onSelectedIdChanged;
  final ValueChanged<bool>? onRefreshButtonChange;

  const CustomerOrSupplierBox({
    super.key,
    this.onRefreshButtonChange,
    required this.movementType,
    required this.selectedId,
    required this.onSelectedIdChanged,
  });

  @override
  CustomerOrSupplierBoxState createState() => CustomerOrSupplierBoxState();
}

class CustomerOrSupplierBoxState extends State<CustomerOrSupplierBox> {

  final List<CustomerDTO> _customerList = [];
  final List<SupplierDTO> _supplierList = [];

  bool _isLoading = false;
  late final bool isCustomer;

  @override
  void initState() {
    super.initState();
    isCustomer = (widget.movementType == MovementTypeEnum.sale);
    isCustomer ? _updateCustomerList() : _updateSupplierList();
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRefreshButton(isCustomer),
                Text(isCustomer ? 'Cliente:' : 'Proveedor:',
                     style: const TextStyle(fontSize: 16.0)
                ),
              ],
            ),
            _isLoading
                ? buildCircularProgress()
                : isCustomer
                    ? _buildCustomDropdownCustomer()
                    : _buildCustomDropdownSupplier()
          ],
        ),
      ),
    );
  }

  IconButton _buildRefreshButton(bool isCustomer) {
    return IconButton(
      onPressed: () async {
        if (!_isLoading) {
          // llama al callback: esta haciendo el refresh...
          if (widget.onRefreshButtonChange != null) widget.onRefreshButtonChange!(true);
          if (isCustomer) {
            await _updateCustomerList();
          } else {
            await _updateSupplierList();
          }
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

  CustomDropdown<CustomerDTO> _buildCustomDropdownCustomer() {
    return CustomDropdown<CustomerDTO>(
      themeData: ThemeData(),
      modelList: _customerList,
      model: _customerList.isNotEmpty ? _customerList[0] : null,
      callback: (customer) {
        setState(() {
          widget.onSelectedIdChanged(customer!.customerId!);
        });
      },
    );
  }

  CustomDropdown<SupplierDTO> _buildCustomDropdownSupplier() {
    return CustomDropdown<SupplierDTO>(
      themeData: ThemeData(),
      modelList: _supplierList,
      model: _supplierList.isNotEmpty ? _supplierList[0] : null,
      callback: (supplier) {
        setState(() {
          widget.onSelectedIdChanged(supplier!.supplierId!);
        });
      },
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
        widget.onSelectedIdChanged(0);
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
        widget.onSelectedIdChanged(0);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCustomerList() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await fetchCustomerList(_customerList).then((value) {
        _customerList.insert(
          0,
          CustomerDTO(
            isFirst: true,
            name: defaultTextFromDropdownMenu,
            customerId: 0,
          ),
        );
        widget.onSelectedIdChanged(0);
      });
    } catch (error) {
      _showMessageConnectionError(context);
    } finally {
      if (_supplierList.isEmpty) {
        _customerList.insert(
          0,
          CustomerDTO(
            isFirst: true,
            name: defaultTextFromDropdownMenu,
            customerId: 0,
          ),
        );
        widget.onSelectedIdChanged(0);
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



