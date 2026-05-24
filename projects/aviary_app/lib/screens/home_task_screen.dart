import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../services/bird_service.dart';
import '../services/auth_service.dart';
import '../models/task.dart';
import '../models/task_item.dart';
import '../widgets/task_item_card.dart';
import 'task_detail_screen.dart';
import 'batch_select_screen.dart';
import 'weight_chart_screen.dart';

class HomeTaskScreen extends StatefulWidget {
  const HomeTaskScreen({super.key});

  @override
  State<HomeTaskScreen> createState() => _HomeTaskScreenState();
}

class _HomeTaskScreenState extends State<HomeTaskScreen> {
  final TaskService _taskService = TaskService();
  final BirdService _birdService = BirdService();
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tasks = await _taskService.getTasks(date: _selectedDate);
      if (!mounted) return;
      setState(() { _tasks = tasks; _loading = false; });
      if (tasks.isEmpty) {
        await _autoGenerate();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = '加载失败: $e'; _loading = false; });
    }
  }

  Future<void> _autoGenerate() async {
    try {
      final task = await _taskService.autoGenerate();
      if (!mounted) return;
      setState(() { _tasks = [task]; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = '自动生成失败: $e'; _loading = false; });
    }
  }

  List<TaskItem> get _pendingWeighItems {
    final items = <TaskItem>[];
    for (final task in _tasks) {
      for (final item in task.items) {
        if (item.taskType == 'weigh' && item.status != 'done') {
          items.add(item);
        }
      }
    }
    return items;
  }

  Future<void> _onItemTap(TaskItem item) async {
    if (item.status == 'done') {
      await _toggleItemStatus(item, 'pending');
      return;
    }
    switch (item.taskType) {
      case 'weigh':
        await _startWeighFlow(item);
        break;
      case 'medicate':
        await _confirmMedicate(item);
        break;
      default:
        await _toggleItemStatus(item, 'done');
    }
  }

  Future<void> _toggleItemStatus(TaskItem item, String newStatus) async {
    try {
      await _taskService.updateTaskItem(item.id, status: newStatus);
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  Future<void> _startWeighFlow(TaskItem startItem) async {
    final pendingIds = _pendingWeighItems.map((i) => i.id).toList();
    int idx = pendingIds.indexOf(startItem.id);
    if (idx < 0) idx = 0;

    while (idx < pendingIds.length && mounted) {
      final itemId = pendingIds[idx];
      final allItems = _pendingWeighItems;
      final item = allItems.where((i) => i.id == itemId).firstOrNull;
      if (item == null) { idx++; continue; }

      final action = await _showWeighDialog(item);
      if (!mounted) return;

      if (action == 'record') {
        idx++;
      } else if (action == 'skip') {
        idx++;
      } else {
        break;
      }
    }

    await _loadTasks();

    if (mounted) {
      final left = _pendingWeighItems.length;
      if (left == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 所有称重已完成！'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<String> _showWeighDialog(TaskItem item) async {
    final weightCtrl = TextEditingController(text: '');
    bool isFasting = item.isFasting == 1;
    final pending = _pendingWeighItems;
    final remaining = pending.length;
    final curIdx = pending.indexOf(item);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          child: Stack(
            children: [
              // 主内容
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 72),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\u{1F99C} ${item.birdName ?? "鸟#" + item.birdId.toString()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (curIdx >= 0)
                      Text('剩余 ${remaining - curIdx} 只待称重',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 20),
                    TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: '体重 (g)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('空腹状态: '),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('空腹'),
                          selected: isFasting,
                          onSelected: (v) => setDialogState(() => isFasting = true),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('未空腹'),
                          selected: !isFasting,
                          onSelected: (v) => setDialogState(() => isFasting = false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 右上角 ❌ 退出
              Positioned(
                top: 8, right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(ctx, 'exit'),
                ),
              ),
              // 底部按钮行
              Positioned(
                bottom: 16, left: 16, right: 16,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, 'skip'),
                      child: const Text('跳过', style: TextStyle(color: Colors.grey)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final w = double.tryParse(weightCtrl.text);
                        if (w == null || w <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('请输入有效体重')),
                          );
                          return;
                        }
                        try {
                          await _birdService.addWeight(item.birdId, w, isFasting: isFasting);
                          await _taskService.updateTaskItem(item.id, status: 'done', isFasting: isFasting ? 1 : 0);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx, 'record');
                        } catch (e) {
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('记录失败: $e')),
                          );
                        }
                      },
                      child: const Text('记录并继续'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? 'exit';
  }

  Future<void> _confirmMedicate(TaskItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('喂药 — ${item.birdName ?? "鸟#" + item.birdId.toString()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.medication != null)
              Text('药物: ${item.medication}', style: const TextStyle(fontSize: 16)),
            if (item.dosage != null)
              Text('剂量: ${item.dosage}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text('确认已喂药并标记完成？'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认完成')),
        ],
      ),
    );
    if (confirmed == true) {
      await _toggleItemStatus(item, 'done');
    }
  }

  void _openDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() { _selectedDate = DateFormat('yyyy-MM-dd').format(picked); });
      _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日任务'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _openDatePicker,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'logout') {
                final auth = AuthService();
                await auth.logout();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'logout', child: Text('退出登录')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToBatchSelect(),
        icon: const Icon(Icons.add),
        label: const Text('批量选鸟'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(_error!, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loadTasks, child: const Text('重试')),
      ],
    ));
    if (_tasks.isEmpty) return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        Text('$_selectedDate 暂无任务', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _autoGenerate, child: const Text('自动生成任务')),
      ],
    ));
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _tasks.length,
        itemBuilder: (context, index) => _buildTaskCard(_tasks[index]),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final dateLabel = task.taskDate == _selectedDate ? '今日' : task.taskDate;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(task.status == 'completed' ? Icons.check_circle : Icons.list_alt,
                  color: task.status == 'completed' ? Colors.green : Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(task.title ?? '$dateLabel 任务',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                Chip(label: Text(task.statusLabel, style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact),
              ],
            ),
          ),
          if (task.autoGenerated)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('🤖 自动生成', style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
          const Divider(height: 1),
          ...task.items.map((item) => TaskItemCard(
            item: item, onTap: () => _onItemTap(item), onLongPress: () => _showItemOptions(item))),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(icon: const Icon(Icons.add, size: 18), label: const Text('添加任务'),
                onPressed: () => _navigateToBatchSelect(taskId: task.id)),
              if (task.status != 'completed')
                TextButton.icon(icon: const Icon(Icons.check, size: 18), label: const Text('全部完成'),
                  onPressed: () => _completeAll(task)),
            ]),
          ),
        ],
      ),
    );
  }

  void _showItemOptions(TaskItem item) {
    showModalBottomSheet(context: context, builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.show_chart), title: const Text('查看体重曲线'), onTap: () {
        Navigator.pop(ctx);
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => WeightChartScreen(birdId: item.birdId, birdName: item.birdName ?? '')));
      }),
      ListTile(leading: const Icon(Icons.edit), title: const Text('编辑任务'), onTap: () {
        Navigator.pop(ctx);
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: item.taskId))).then((_) => _loadTasks());
      }),
    ]));
  }

  Future<void> _completeAll(Task task) async {
    try {
      for (final item in task.items.where((i) => i.status != 'done')) {
        await _taskService.updateTaskItem(item.id, status: 'done');
      }
      await _taskService.updateTask(task.id, status: 'completed');
      await _loadTasks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('全部完成！'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }

  void _navigateToBatchSelect({int? taskId}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BatchSelectScreen(
      taskDate: _selectedDate,
      existingTaskId: taskId ?? (_tasks.isNotEmpty ? _tasks.first.id : null),
    ))).then((_) => _loadTasks());
  }
}
