class PageObject<T> {
  List<T> content;
  int pageNumber;  //number
  int pageSize;    //size
  int totalPages;
  int totalElements;
  bool first;
  bool last;

  PageObject.empty()
      : content = [],
        pageNumber = 0,
        pageSize = 0,
        totalPages = 0,
        totalElements = 0,
        first = false,
        last = false;

  PageObject({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last
});

  @override
  String toString() {
    return 'PageObject('
        'pageNumber: $pageNumber, '
        'pageSize: $pageSize, '
        'totalPages: $totalPages, '
        'totalElements: $totalElements, '
        'first: $first, '
        'last: $last'
        ')';
  }
}