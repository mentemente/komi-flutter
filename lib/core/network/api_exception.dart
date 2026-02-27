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

  /// Extrae los mensajes de validación de [details] si es una lista.
  List<String> get validationErrors {
    if (details is! List) return [];
    return (details as List)
        .map((e) => e['message'] as String? ?? '')
        .where((m) => m.isNotEmpty)
        .toList();
  }

  /// Retorna el primer error de validación o el [message] general.
  String get displayMessage {
    final errors = validationErrors;
    return errors.isNotEmpty ? errors.first : message;
  }

  @override
  String toString() => displayMessage;
}
