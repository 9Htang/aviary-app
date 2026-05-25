import 'dart:convert';
import 'dart:io';
import '../config/api.dart';
import '../utils/dev_utils.dart';

/// HTTP API 客户端（使用 dart:io HttpClient，手动管理 session cookie）
class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._() {
    _client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  }

  late final HttpClient _client;
  final String baseUrl = ApiConfig.baseUrl;
  String? _sessionCookie;

  /// 从响应头提取 session cookie
  void _saveCookies(HttpHeaders headers) {
    final setCookie = headers.value('set-cookie');
    if (setCookie != null && setCookie.isNotEmpty) {
      final match = RegExp(r'(connect\.sid=[^;]+)').firstMatch(setCookie);
      if (match != null) {
        _sessionCookie = match.group(1);
      }
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final request = await _client.getUrl(uri);
    _addHeaders(request);
    final response = await request.close();
    _saveCookies(response.headers);
    DevApiLogger.record('GET', path, response.statusCode, '');
    return _handle(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.postUrl(uri);
    _addHeaders(request);
    if (_sessionCookie != null) {
      request.headers.set('cookie', _sessionCookie!);
    }
    request.write(jsonEncode(body ?? {}));
    final response = await request.close();
    _saveCookies(response.headers);
    DevApiLogger.record('POST', path, response.statusCode, '');
    return _handle(response);
  }

  Future<Map<String, dynamic>> patch(String path,{Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.patchUrl(uri);
    _addHeaders(request);
    if (_sessionCookie != null) {
      request.headers.set('cookie', _sessionCookie!);
    }
    request.write(jsonEncode(body ?? {}));
    final response = await request.close();
    _saveCookies(response.headers);
    DevApiLogger.record('PATCH', path, response.statusCode, '');
    return _handle(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _client.deleteUrl(uri);
    _addHeaders(request);
    if (_sessionCookie != null) {
      request.headers.set('cookie', _sessionCookie!);
    }
    final response = await request.close();
    _saveCookies(response.headers);
    DevApiLogger.record('DELETE', path, response.statusCode, '');
    return _handle(response);
  }

  void _addHeaders(HttpClientRequest request) {
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
  }

  Future<Map<String, dynamic>> _handle(HttpClientResponse response) async {
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(body) as Map<String, dynamic>;
    }
    // 尝试解析 JSON 错误
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final errMsg = json['error'] as String? ?? body;
      throw ApiException(response.statusCode, errMsg, body);
    } catch (_) {
      throw ApiException(response.statusCode, body, body);
    }
  }

  void clearCookie() {
    _sessionCookie = null;
  }

  /// 从持久化存储恢复 cookie
  void restoreCookie(String cookie) {
    _sessionCookie = cookie;
  }

  /// 获取当前 cookie
  String? getCurrentCookie() => _sessionCookie;
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String rawBody;
  ApiException(this.statusCode, this.message, this.rawBody);

  @override
  String toString() => 'API Error $statusCode: $message';
}
