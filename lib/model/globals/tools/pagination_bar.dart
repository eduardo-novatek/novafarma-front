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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.first_page,
            size: 30,
          ),
          tooltip: 'Primera página',
          onPressed: currentPage > 1 ? _goToStart : null,
        ),
        IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 30,
          ),
          tooltip: 'Página anterior',
          onPressed: currentPage > 1 ? _goBack : null,
        ),
        SizedBox(
          width: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, ),
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
              Baseline(
                baseline: 0,
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  ' /  ${widget.totalPages}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(
            Icons.chevron_right,
            size: 30,
          ),
          tooltip: 'Página siguiente',
          onPressed: currentPage < widget.totalPages ? _goForward : null,
        ),
        IconButton(
          icon: const Icon(
            Icons.last_page,
            size: 30,
          ),
          tooltip: 'Últina págna',
          onPressed: currentPage < widget.totalPages ? _goToEnd : null,
        ),
      ],
    );
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
}