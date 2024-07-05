class PageObject<T> {
  late final List<T> content;
  late final int pageNumber;  //number
  late final int pageSize;    //size
  late final int totalPages;
  late final int totalElements;
  late final bool first;
  late final bool last;

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