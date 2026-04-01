import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:komi_fe/core/network/api_exception.dart';

class HttpClient {
  final String baseUrl;
  String? _token;

  HttpClient({required this.baseUrl});

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// POST request. Retorna `data` parseado con [fromJson].
  Future<T> post<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, fromJson);
  }

  /// GET request. Retorna `data` parseado con [fromJson].
  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response, fromJson);
  }

  /// PUT request. Retorna `data` parseado con [fromJson].
  Future<T> put<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, fromJson);
  }

  /// DELETE request. Retorna `data` parseado con [fromJson].
  Future<T> delete<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleResponse(response, fromJson);
  }

  /// POST `multipart/form-data` (p. ej. imágenes). Incluye `Authorization: Bearer` si hay token.
  /// Usa bytes (p. ej. [XFile.readAsBytes]) para que funcione con `content://` en Android.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileFieldName,
    required List<int> fileBytes,
    String filename = 'image.jpg',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null && _token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    for (final e in fields.entries) {
      request.fields[e.key] = e.value;
    }

    final safeName = filename.trim().isEmpty ? 'image.jpg' : filename.trim();
    final contentType = _imageMediaTypeForFilename(safeName);

    if (fileBytes.isEmpty) {
      throw ApiException(
        code: 'EMPTY_FILE',
        status: 0,
        message: 'El archivo está vacío',
        details: null,
      );
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        fileFieldName,
        fileBytes,
        filename: safeName,
        contentType: contentType,
      ),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      _throwFromMultipartFailure(streamed.statusCode, body);
    }

    late final Map<String, dynamic> json;
    try {
      json = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        status: streamed.statusCode,
        message: body.isNotEmpty ? body : 'Respuesta inválida del servidor',
        details: null,
      );
    }

    final successRaw = json['success'];
    final success =
        successRaw == true || successRaw == 'true' || successRaw == 1;
    if (!success) {
      throw ApiException(
        code: json['code'] as String? ?? 'UPLOAD_ERROR',
        status: json['status'] as int? ?? streamed.statusCode,
        message: json['message'] as String? ?? 'Error al subir',
        details: json['details'],
      );
    }

    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }
    if (rawData is String && rawData.isNotEmpty) {
      return {'url': rawData};
    }
    return <String, dynamic>{};
  }

  Never _throwFromMultipartFailure(int statusCode, String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      if (json['success'] == false) {
        throw ApiException(
          code: json['code'] as String? ?? 'UPLOAD_ERROR',
          status: json['status'] as int? ?? statusCode,
          message: json['message'] as String? ?? 'Error al subir',
          details: json['details'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
    }
    throw ApiException(
      code: 'UPLOAD_FAILED',
      status: statusCode,
      message: body.isNotEmpty ? body : 'Error al subir la imagen',
      details: null,
    );
  }

  T _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final success = json['success'] as bool;

    if (success) {
      final data = json['data'] as Map<String, dynamic>;
      return fromJson(data);
    }

    throw ApiException(
      code: json['code'] as String,
      status: json['status'] as int,
      message: json['message'] as String,
      details: json['details'],
    );
  }
}

/// MIME de la parte del archivo multipart (evita `application/octet-stream`).
MediaType _imageMediaTypeForFilename(String filename) {
  final dot = filename.lastIndexOf('.');
  final ext = dot >= 0 && dot < filename.length - 1
      ? filename.substring(dot + 1).toLowerCase()
      : '';
  switch (ext) {
    case 'png':
      return MediaType('image', 'png');
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'gif':
      return MediaType('image', 'gif');
    case 'webp':
      return MediaType('image', 'webp');
    case 'bmp':
      return MediaType('image', 'bmp');
    case 'tif':
    case 'tiff':
      return MediaType('image', 'tiff');
    case 'svg':
      return MediaType('image', 'svg+xml');
    default:
      return MediaType('image', 'jpeg');
  }
}
