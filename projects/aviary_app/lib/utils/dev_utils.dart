/// 开发环境工具 — 发行版中所有代码被 tree-shaking 消除
///
/// 用法: if (Dev.enabled) { ... }
/// 发行版构建时，整个分支会被编译器移除，零体积影响。
import 'package:flutter/foundation.dart';

class Dev {
  /// 是否处于开发/调试模式
  static bool get enabled => kDebugMode;

  /// 是否显示 API 请求日志
  static bool get apiLogging => enabled;

  /// 开发菜单：长按 logo/标题触发的调试面板
  static bool get debugMenu => enabled;

  /// 可切换服务器地址（开发用）
  static bool get serverSwitcher => enabled;

  /// 开发模式下打印 API 日志
  static void log(String tag, dynamic data) {
    if (!enabled) return;
    // ignore: avoid_print
    print('[Dev::$tag] $data');
  }
}

/// 开发环境专属的 API 日志记录器（发行版零开销）
class DevApiLogger {
  static final List<Map<String, dynamic>> _logs = [];
  static const int _maxLogs = 200;

  static void record(String method, String path, int statusCode, dynamic body) {
    if (!Dev.enabled) return;
    _logs.add({
      'time': DateTime.now().toString().substring(11, 19),
      'method': method,
      'path': path,
      'status': statusCode,
      'body': body is String ? body.substring(0, body.length.clamp(0, 500)) : body,
    });
    if (_logs.length > _maxLogs) _logs.removeAt(0);
  }

  static List<Map<String, dynamic>> get logs =>
      Dev.enabled ? List.unmodifiable(_logs) : const [];

  static void clear() {
    if (Dev.enabled) _logs.clear();
  }
}
