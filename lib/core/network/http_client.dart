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

  /// POST request. Returns `data` parsed with [fromJson].
  /// [headers] is merged with the default headers (e.g. `store-id`).
  Future<T> post<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {..._headers, ...?headers};
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, fromJson);
  }

  /// POST when `data` in the response is a **list** (e.g. `POST /v1/food`).
  Future<List<Map<String, dynamic>>> postList(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {..._headers, ...?headers};
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleListDataResponse(response);
  }

  /// GET request. Returns `data` parsed with [fromJson].
  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);
    final mergedHeaders = {..._headers, ...?headers};
    final response = await http.get(uri, headers: mergedHeaders);
    return _handleResponse(response, fromJson);
  }

  /// GET when `data` is a **list** (e.g. `GET /v1/food`).
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);
    final mergedHeaders = {..._headers, ...?headers};
    final response = await http.get(uri, headers: mergedHeaders);
    return _handleListDataResponse(response);
  }

  /// PUT request. Returns `data` parsed with [fromJson].
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

  /// PATCH request. Returns `data` parsed with [fromJson].
  Future<T> patch<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = {..._headers, ...?headers};
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, fromJson);
  }

  /// DELETE request. Returns `data` parsed with [fromJson].
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

  /// POST `multipart/form-data` (e.g. images). Includes `Authorization: Bearer` if there is a token.
  /// Uses bytes (e.g. [XFile.readAsBytes]) to work with `content://` on Android.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileFieldName,
    required List<int> fileBytes,
    String filename = 'image.jpg',
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({...?headers});
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

  List<Map<String, dynamic>> _handleListDataResponse(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['success'] == true) {
      final data = json['data'];
      if (data is List) {
        return [
          for (final e in data)
            Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
        ];
      }
      return [];
    }

    throw ApiException(
      code: json['code'] as String? ?? 'ERROR',
      status: json['status'] as int? ?? response.statusCode,
      message: json['message'] as String? ?? 'Error',
      details: json['details'],
    );
  }
}

/// MIME of the multipart file part (avoids `application/octet-stream`).
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
