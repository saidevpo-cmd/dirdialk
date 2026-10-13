class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;

  bool get hasNext => (page * limit) < total;
  bool get hasPrev => page > 1;
  int get totalPages => (total / limit).ceil();
}

class ListFilter {
  const ListFilter({
    this.search,
    this.page = 1,
    this.limit = 20,
    this.sortField,
    this.sortAsc = false,
  });

  final String? search;
  final int page;
  final int limit;
  final String? sortField;
  final bool sortAsc;

  ListFilter copyWith({
    String? search,
    int? page,
    int? limit,
    String? sortField,
    bool? sortAsc,
  }) =>
      ListFilter(
        search: search ?? this.search,
        page: page ?? this.page,
        limit: limit ?? this.limit,
        sortField: sortField ?? this.sortField,
        sortAsc: sortAsc ?? this.sortAsc,
      );
}
