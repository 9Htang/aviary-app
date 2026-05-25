import 'package:flutter/foundation.dart';

/// 将异常转换为用户友好的中文错误消息
String friendlyError(dynamic e) {
  debugPrint('⚠️ $e');

  final msg = e.toString().toLowerCase();

  // 网络类错误
  if (msg.contains('connection refused') || msg.contains('连接被拒绝')) {
    return '无法连接到服务器，请确认电脑已启动鸟舍服务';
  }
  if (msg.contains('socketexception') || msg.contains('socket')) {
    return '网络连接异常，请检查手机和电脑是否在同一WiFi';
  }
  if (msg.contains('timeout') || msg.contains('超时')) {
    return '连接超时，请检查服务器状态';
  }
  if (msg.contains('dns') || msg.contains('resolve')) {
    return '无法解析服务器地址，请检查网络连接';
  }
  if (msg.contains('handshake') || msg.contains('certificate')) {
    return 'SSL 连接错误，请确认使用 HTTP 而非 HTTPS';
  }

  // HTTP 错误码
  if (msg.contains('401') || msg.contains('请先登录') || msg.contains('未登录')) {
    return '登录已过期，请重新登录';
  }
  if (msg.contains('403') || msg.contains('权限不足') || msg.contains('无权限')) {
    return '权限不足，请联系管理员';
  }
  if (msg.contains('404') || msg.contains('not found')) {
    return '请求的资源不存在';
  }
  if (msg.contains('500') || msg.contains('internal server')) {
    return '服务器内部错误，请稍后重试';
  }

  // API 返回的业务错误消息（直接取服务端返回的错误文本）
  final apiPattern = RegExp(r'API Error \d+: (.+)');
  final apiMatch = apiPattern.firstMatch(e.toString());
  if (apiMatch != null) {
    return apiMatch.group(1)!;
  }

  // 其他 JSON 解析或未知错误
  if (msg.contains('json') || msg.contains('format') || msg.contains('type')) {
    return '数据解析错误，请检查服务器版本是否匹配';
  }

  return '操作失败，请稍后重试';
}

/// 带错误日志的便捷 SnackBar 文本创建
String friendlySnackMsg(String prefix, dynamic e) {
  return '$prefix: ${friendlyError(e)}';
}
