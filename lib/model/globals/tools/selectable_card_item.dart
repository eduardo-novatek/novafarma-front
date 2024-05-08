import 'package:flutter/material.dart';

class SelectableCardItem extends StatefulWidget {
  final ThemeData themeData;
  final String title;
  final String subtitle;
  final String? image;
  final IconData? icon;
  final Function()? onTapCallback; // Función de devolución de llamada

  const SelectableCardItem({
    Key? key,
    required this.themeData,
    required this.title,
    required this.subtitle,
    this.image,
    this.icon,
    this.onTapCallback,
  }) : super(key: key);

  @override
  State<SelectableCardItem> createState() => _SelectableCardItemState();
}

class _SelectableCardItemState extends State<SelectableCardItem> {
  late Color _cardColor;

  @override
  void initState() {
    super.initState();
    _cardColor = widget.themeData.colorScheme.secondaryContainer;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _cardColor = widget.themeData.colorScheme.secondaryContainer.withOpacity(0.5);
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _cardColor = widget.themeData.colorScheme.secondaryContainer;
          });
        });
        if (widget.onTapCallback != null) {
          widget.onTapCallback!();
        }
      },
      child: Card(
        shadowColor: Colors.grey,
        elevation: 5          ,
        color: _cardColor,
        child: ListTile(
          leading: _leading(),
          title: Text(widget.title),
          subtitle: Text(widget.subtitle),
        ),
      ),
    );
  }

  Widget _leading() {
    if (widget.image != null) return Image.asset(widget.image!);
    if (widget.icon != null) return Icon(widget.icon);
    return const SizedBox.shrink();
  }
}
