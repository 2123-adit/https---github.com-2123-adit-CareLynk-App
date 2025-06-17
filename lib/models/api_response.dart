class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }

  factory ApiResponse.success(T data, [String message = 'Success']) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error(String message, [List<String>? errors]) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }
}