class Metadata {
  final int totalCount;
  final int pageSize;
  final int currentPage;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  Metadata({
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      totalCount: json['totalCount'],
      pageSize: json['pageSize'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      hasPreviousPage: json['hasPreviousPage'],
      hasNextPage: json['hasNextPage'],
    );
  }
}
