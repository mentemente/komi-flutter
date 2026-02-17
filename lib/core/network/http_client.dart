import 'dart:convert';
import 'package:http/http.dart' as http;
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
