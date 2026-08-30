class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final int from;
  final int to;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.from,
    required this.to,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final currentPage = json['current_page'] as int? ?? 1;
    final lastPage = json['last_page'] as int? ?? 1;
    return PaginationMeta(
      currentPage: currentPage,
      lastPage: lastPage,
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 15,
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? 0,
      hasNext: currentPage < lastPage,
      hasPrevious: currentPage > 1,
    );
  }
}

class PaginatedResult<T> {
  final T items;
  final PaginationMeta meta;

  const PaginatedResult({
    required this.items,
    required this.meta,
  });
}
