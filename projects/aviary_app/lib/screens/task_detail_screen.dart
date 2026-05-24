import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import '../widgets/task_item_card.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  Task? _task;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final task = await _taskService.getTask(widget.taskId);
      if (!mounted) return;
      setState(() { _task = task; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_task?.title ?? '任务详情'),
        actions: [
          if (_task != null && _task!.status != 'completed')
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () async {
                await _taskService.updateTask(_task!.id, status: 'completed');
                _load();
              },
              tooltip: '标记完成',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _task == null
              ? const Center(child: Text('任务不存在'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // 概要
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Chip(label: Text('${_task!.doneCount}/${_task!.totalCount}')),
              const SizedBox(width: 8),
              Chip(label: Text('等待: ${_task!.pendingCount}')),
              const Spacer(),
              Text(_task!.taskDate, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        // 任务项列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _task!.items.length,
            itemBuilder: (context, index) => TaskItemCard(
              item: _task!.items[index],
              onTap: () async {
                final newStatus = _task!.items[index].status == 'done' ? 'pending' : 'done';
                await _taskService.updateTaskItem(_task!.items[index].id, status: newStatus);
                _load();
              },
            ),
          ),
        ),
      ],
    );
  }
}
