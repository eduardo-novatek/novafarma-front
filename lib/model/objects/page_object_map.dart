class PageObjectMap<K, T> {
  Map<K, T> content;
  int pageNumber;  //number
  int pageSize;    //size
  int totalPages;
  int totalElements;
  bool first;
  bool last;

  PageObjectMap.empty()
      : content = {},
        pageNumber = 0,
        pageSize = 0,
        totalPages = 0,
        totalElements = 0,
        first = false,
        last = false;

  PageObjectMap({
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