import 'package:flutter/material.dart';
import '../utils/dev_utils.dart';
import '../utils/error_helper.dart';

/// 开发调试面板 — 仅 kDebugMode 模式下可用，发行版中 tree-shaken 消除
class DevOverlay extends StatelessWidget {
  final Widget child;

  const DevOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Dev.enabled) return child;

    return Stack(
      children: [
        child,
        // 右下角小圆点，长按打开调试面板
        Positioned(
          right: 8,
          bottom: 80,
          child: GestureDetector(
            onLongPress: () => _showDebugPanel(context),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(80),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDebugPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => const _DebugPanelBody(),
    );
  }
}

class _DebugPanelBody extends StatefulWidget {
  const _DebugPanelBody();

  @override
  State<_DebugPanelBody> createState() => _DebugPanelBodyState();
}

class _DebugPanelBodyState extends State<_DebugPanelBody> {
  @override
  Widget build(BuildContext context) {
    final logs = DevApiLogger.logs;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // 拖拽条
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('🔧 开发调试', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('清空'),
                  onPressed: () {
                    DevApiLogger.clear();
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // API 日志列表
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('暂无 API 日志'))
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final ok = log['status'] >= 200 && log['status'] < 300;
                      return ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ok ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${log['status']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: ok ? Colors.green[700] : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${log['method']} ${log['path']}',
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${log['time']}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
