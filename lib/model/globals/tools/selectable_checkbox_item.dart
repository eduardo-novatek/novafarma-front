import 'package:flutter/material.dart';

class SelectableCheckBoxItem extends StatefulWidget {
  final String text;
  final bool initiallySelected;
  final Function(bool) onChanged;

  const SelectableCheckBoxItem({
    super.key,
    required this.text,
    this.initiallySelected = false,
    required this.onChanged,
  });

  @override
  _SelectableCheckBoxItemState createState() => _SelectableCheckBoxItemState();
}
class _SelectableCheckBoxItemState extends State<SelectableCheckBoxItem> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.initiallySelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.onChanged(isSelected);
        });
      },
      child: Row(
        children: <Widget>[
          Checkbox(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                isSelected = value!;
                widget.onChanged(isSelected);
              });
            },
          ),
          Text(widget.text),
        ],
      ),
    );
  }
}