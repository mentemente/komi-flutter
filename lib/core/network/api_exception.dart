class ApiException implements Exception {
  final String code;
  final int status;
  final String message;
  final dynamic details;

  const ApiException({
    required this.code,
    required this.status,
    required this.message,
    this.details,
  });

  /// Extracts the validation messages from [details] if it is a list.
  List<String> get validationErrors {
    if (details is! List) return [];
    return (details as List)
        .map((e) => e['message'] as String? ?? '')
        .where((m) => m.isNotEmpty)
        .toList();
  }

  /// Returns the first validation error or the general [message].
  String get displayMessage {
    final errors = validationErrors;
    return errors.isNotEmpty ? errors.first : message;
  }

  @override
  String toString() => displayMessage;
}
