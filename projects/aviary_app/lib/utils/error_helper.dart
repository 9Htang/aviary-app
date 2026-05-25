import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// 错误信息：友好消息 + 原始详情（可复制）
class ErrorInfo {
  final String message;  // 用户看到的友好消息
  final String details;  // 原始错误详情（可复制发给我）

  const ErrorInfo(this.message, this.details);

  @override
  String toString() => message;
}

/// 将异常转换为用户友好的错误消息
ErrorInfo friendlyError(dynamic e) {
  final raw = e.toString();
  debugPrint('⚠️ $raw');

  final msg = raw.toLowerCase();

  String friendly;
  if (msg.contains('connection refused') || msg.contains('连接被拒绝')) {
    friendly = '无法连接到服务器，请确认电脑已启动鸟舍服务';
  } else if (msg.contains('socketexception') || msg.contains('socket')) {
    friendly = '网络连接异常，请检查手机和电脑是否在同一WiFi';
  } else if (msg.contains('timeout') || msg.contains('超时')) {
    friendly = '连接超时，请检查服务器状态';
  } else if (msg.contains('dns') || msg.contains('resolve')) {
    friendly = '无法解析服务器地址，请检查网络连接';
  } else if (msg.contains('handshake') || msg.contains('certificate')) {
    friendly = 'SSL 连接错误，请确认使用 HTTP 而非 HTTPS';
  } else if (msg.contains('401') || msg.contains('请先登录') || msg.contains('未登录')) {
    friendly = '登录已过期，请重新登录';
  } else if (msg.contains('403') || msg.contains('权限不足') || msg.contains('无权限')) {
    friendly = '权限不足，请联系管理员';
  } else if (msg.contains('404') || msg.contains('not found')) {
    friendly = '请求的资源不存在';
  } else if (msg.contains('500') || msg.contains('internal server')) {
    friendly = '服务器内部错误，请稍后重试';
  } else if (msg.contains('json') || msg.contains('format') || msg.contains('type')) {
    friendly = '数据解析错误，请检查服务器版本是否匹配';
  } else {
    final apiPattern = RegExp(r'API Error \d+: (.+)');
    final apiMatch = apiPattern.firstMatch(raw);
    friendly = apiMatch?.group(1) ?? '操作失败，请稍后重试';
  }

  return ErrorInfo(friendly, raw);
}

/// 显示一个可点击的 SnackBar：点击后弹出详情可复制
void showErrorSnackBar(BuildContext context, dynamic error) {
  final info = friendlyError(error);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(info.message),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: '详情',
        onPressed: () => _showErrorDetails(context, info),
      ),
    ),
  );
}

/// 显示错误详情弹窗（可复制）
void _showErrorDetails(BuildContext context, ErrorInfo info) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('错误详情'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('友好提示：', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(info.message, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('原始错误：', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              info.details,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: info.details));
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('已复制')),
            );
          },
          child: const Text('复制错误信息'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}
