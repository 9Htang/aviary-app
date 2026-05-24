import 'package:flutter/material.dart';
import '../models/task_item.dart';

class TaskItemCard extends StatelessWidget {
  final TaskItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TaskItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = item.status == 'done';
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 状态图标
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? Colors.green[50] : Colors.grey[100],
              ),
              child: Icon(
                isDone ? Icons.check_circle : _taskTypeIcon,
                size: 20,
                color: isDone ? Colors.green : (_taskTypeColor),
              ),
            ),
            const SizedBox(width: 12),
            // 鸟信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : null,
                        ),
                      ),
                      if (item.displayRing.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(item.displayRing, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                      if (item.gender != null) ...[
                        const SizedBox(width: 4),
                        Text(item.gender!, style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _taskTypeBadge(context),
                      if (item.taskType == 'weigh' && item.isFasting != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: item.isFasting == 1 ? Colors.green[50] : Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.fastingLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: item.isFasting == 1 ? Colors.green[700] : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                      if (item.medication != null) ...[
                        const SizedBox(width: 6),
                        Text('💊 ${item.medication}', style: const TextStyle(fontSize: 11, color: Colors.purple)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // 优先级
            if (item.priority > 0)
              Icon(Icons.star, size: 16, color: item.priority > 1 ? Colors.red : Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _taskTypeBadge(BuildContext context) {
    return Text(
      item.taskTypeLabel,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _taskTypeColor,
      ),
    );
  }

  Color get _taskTypeColor {
    switch (item.taskType) {
      case 'weigh': return Colors.blue;
      case 'medicate': return Colors.red;
      case 'feed': return Colors.green;
      case 'check': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData get _taskTypeIcon {
    switch (item.taskType) {
      case 'weigh': return Icons.monitor_weight;
      case 'medicate': return Icons.medication;
      case 'feed': return Icons.restaurant;
      case 'check': return Icons.visibility;
      default: return Icons.task;
    }
  }
}
