class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromData,
  ) {
    final dynamic rawData = json['data'];
    T? parsed;
    if (rawData != null && fromData != null) {
      parsed = fromData(rawData);
    }
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      data: parsed,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  bool get isError => !success;
}

class Paginated<T> {
  final List<T> items;
  final int page;
  final int perPage;
  final int total;
  final int lastPage;

  const Paginated({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = json['data'] as Map<String, dynamic>?;
    final itemsJson = (data?['items'] as List? ?? []);
    final meta = data?['meta'] as Map<String, dynamic>? ?? {};
    return Paginated<T>(
      items: itemsJson.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      page: meta['page'] as int? ?? 1,
      perPage: meta['perPage'] as int? ?? 15,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['lastPage'] as int? ?? 1,
    );
  }
}
