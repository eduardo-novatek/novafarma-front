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
  State<PaginationBar> createState() => _PaginationBarState();
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
  void didUpdateWidget(covariant PaginationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPage != oldWidget.initialPage) {
      setState(() {
        currentPage = widget.initialPage;
        _controller.text = currentPage.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canGoToStart = currentPage > 1;
    bool canGoBack = currentPage > 1;
    bool canGoForward = currentPage < widget.totalPages;
    bool canGoToEnd = currentPage < widget.totalPages;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.first_page,
              size: 30,
              color: canGoToStart ? Colors.blue : Colors.grey
            ),
            tooltip: 'Primera página',
            onPressed: canGoToStart ? _goToStart : null,
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 30,
              color: canGoBack ? Colors.blue : Colors.grey
            ),
            tooltip: 'Página anterior',
            onPressed: canGoBack ? _goBack : null,
          ),
          SizedBox(
            width: 65,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0.0,
                              horizontal: 4.0
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.0
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
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
                  ),
                  Text(
                    ' / ${widget.totalPages}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 30,
              color: canGoForward ? Colors.blue : Colors.grey
            ),
            tooltip: 'Página siguiente',
            onPressed: canGoForward ? _goForward : null,
          ),
          IconButton(
            icon: Icon(
              Icons.last_page,
              size: 30,
              color: canGoToEnd ? Colors.blue : Colors.grey
            ),
            tooltip: 'Última página',
            onPressed: canGoToEnd ? _goToEnd : null,
          ),
        ],
      ),
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

/*
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
  State<PaginationBar> createState() => _PaginationBarState();
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
    return Container(
      color: Colors.transparent,
      child: Row(
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none, // Elimina el borde
                      isDense: true, // Reduce el padding
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
            tooltip: 'Última página',
            onPressed: currentPage < widget.totalPages ? _goToEnd : null,
          ),
        ],
      ),
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

 */
