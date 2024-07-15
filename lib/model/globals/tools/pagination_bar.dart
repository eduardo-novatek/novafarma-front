import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaginationBar extends StatefulWidget {
  final int totalPages;
  final int initialPage;
  final Function(int) onPageChanged;

  const PaginationBar({
    super.key,
    required this.totalPages,
    required this.initialPage,
    required this.onPageChanged,
  });

  @override
  _PaginationBarState createState() => _PaginationBarState();
}

class _PaginationBarState extends State<PaginationBar> {
  late int currentPage;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _controller.text = currentPage.toString();
  }

  void _goToPage(int page) {
    if (page < 1) {
      page = 1;
    } else if (page > widget.totalPages) {
      page = widget.totalPages;
    }

    setState(() {
      currentPage = page;
      _controller.text = currentPage.toString();
    });

    widget.onPageChanged(currentPage);
  }

  void _goToStart() => _goToPage(1);

  void _goBack() => _goToPage(currentPage - 1);

  void _goForward() => _goToPage(currentPage + 1);

  void _goToEnd() => _goToPage(widget.totalPages);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage > 1 ? _goToStart : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? _goBack : null,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onSubmitted: (value) {
              int? page = int.tryParse(value);
              if (page != null) {
                _goToPage(page);
              } else {
                _controller.text = currentPage.toString();
              }
            },
          ),
        ),
        Text('/${widget.totalPages}'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < widget.totalPages ? _goForward : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage < widget.totalPages ? _goToEnd : null,
        ),
      ],
    );
  }
}
