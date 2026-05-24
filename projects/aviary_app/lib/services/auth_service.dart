import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// 登录结果
class LoginResult {
  final bool success;
  final String? error;
  final bool isNetworkError;

  LoginResult._({required this.success, this.error, this.isNetworkError = false});

  factory LoginResult.ok() => LoginResult._(success: true);
  factory LoginResult.authError(String msg) => LoginResult._(success: false, error: msg);
  factory LoginResult.networkError(String msg) => LoginResult._(success: false, error: msg, isNetworkError: true);
}

class AuthService extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  bool _loggedIn = false;
  String _username = '';
  String _displayName = '';
  String _role = '';
  String? _sessionCookie;

  bool get isLoggedIn => _loggedIn;
  String get displayName => _displayName;
  String get username => _username;
  String get role => _role;
  String? get sessionCookie => _sessionCookie;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool('logged_in') ?? false;
    _username = prefs.getString('username') ?? '';
    _displayName = prefs.getString('display_name') ?? '';
    _role = prefs.getString('role') ?? '';
    _sessionCookie = prefs.getString('session_cookie');
    // 恢复 cookie 到 ApiClient
    if (_sessionCookie != null) {
      _api.restoreCookie(_sessionCookie!);
    }
    notifyListeners();
  }

  /// 登录
  /// 返回 [LoginResult]，区分网络错误和认证错误
  Future<LoginResult> login(String username, String password) async {
    try {
      final resp = await _api.post('/api/login', body: {
        'username': username,
        'password': password,
      });
      if (resp['code'] == 0) {
        final data = resp['data'] as Map<String, dynamic>;
        _loggedIn = true;
        _username = data['username'] as String? ?? '';
        _displayName = data['display_name'] as String? ?? '';
        _role = data['role'] as String? ?? '';
        _sessionCookie = _api.getCurrentCookie();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logged_in', true);
        await prefs.setString('username', _username);
        await prefs.setString('display_name', _displayName);
        await prefs.setString('role', _role);
        if (_sessionCookie != null) {
          await prefs.setString('session_cookie', _sessionCookie!);
        }

        notifyListeners();
        return LoginResult.ok();
      }
      // 服务器返回了但认证失败
      final msg = resp['error'] as String? ?? '用户名或密码错误';
      return LoginResult.authError(msg);
    } on http.ClientException catch (e) {
      debugPrint('Login network error: $e');
      return LoginResult.networkError('无法连接到服务器\n请确认手机和电脑在同一WiFi，且服务器已启动');
    } catch (e) {
      debugPrint('Login error: $e');
      return LoginResult.networkError('连接服务器失败: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/api/logout');
    } catch (_) {}
    _loggedIn = false;
    _username = '';
    _displayName = '';
    _role = '';
    _sessionCookie = null;
    _api.clearCookie();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
