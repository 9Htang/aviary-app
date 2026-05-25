import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../utils/error_helper.dart';
import 'package:image_picker/image_picker.dart';
import '../services/task_service.dart';
import '../services/medical_service.dart';
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
  final MedicalService _medicalService = MedicalService();
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
      setState(() { _error = friendlyError(e).message; _loading = false; });
    }
  }

  Future<void> _autoGenerate() async {
    try {
      final task = await _taskService.autoGenerate();
      if (!mounted) return;
      setState(() { _tasks = [task]; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = friendlyError(e).message; _loading = false; });
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
        SnackBar(content: Text(friendlyError(e).message)),
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
          SnackBar(content: Text('✅ 所有称重已完成！'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<String> _showWeighDialog(TaskItem item) async {
    final weightCtrl = TextEditingController(text: '');
    bool isFasting = item.isFasting == 1;
    final now = DateTime.now();
    // 从服务端加载症状列表
    final serverSymptoms = await _medicalService.getSymptoms();
    final _allSymptoms = serverSymptoms.map((s) => s['name'] as String).toList();
    final _selectedSymptoms = <String>{};
    final notesCtrl = TextEditingController(text: isFasting ? '' : '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} 未空腹');
    final _photoPaths = <String>[];
    final pending = _pendingWeighItems;
    final remaining = pending.length;
    final curIdx = pending.indexOf(item);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final hasSymptom = _selectedSymptoms.isNotEmpty;
          return Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏
                    Row(
                      children: [
                        const Text('\u{1F99C}', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${item.birdName ?? "鸟#" + item.birdId.toString()}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                        if (curIdx >= 0)
                          Text('${remaining - curIdx} 只', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(ctx, 'exit'),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    // 可滚动内容
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: weightCtrl,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: '体重 (g)',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('空腹状态: ', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('空腹', style: TextStyle(fontSize: 13)),
                                  selected: isFasting,
                                  onSelected: (v) => setDialogState(() => isFasting = true),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: const Text('未空腹', style: TextStyle(fontSize: 13)),
                                  selected: !isFasting,
                                  onSelected: (v) => setDialogState(() => isFasting = false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 症状多选（弹窗）
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: ctx,
                                  builder: (dCtx) => StatefulBuilder(
                                    builder: (dCtx, dSetState) => AlertDialog(
                                      title: const Text('选择症状（可多选）'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: _allSymptoms.map((name) {
                                            final sel = _selectedSymptoms.contains(name);
                                            return CheckboxListTile(
                                              title: Text(name),
                                              value: sel,
                                              dense: true,
                                              onChanged: (v) {
                                                dSetState(() {
                                                  if (v == true) {
                                                    _selectedSymptoms.add(name);
                                                  } else {
                                                    _selectedSymptoms.remove(name);
                                                  }
                                                });
                                                setDialogState(() {});
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _selectedSymptoms.clear();
                                            dSetState(() {});
                                            setDialogState(() {});
                                          },
                                          child: const Text('清除全部'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(dCtx),
                                          child: const Text('确认'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.health_and_safety, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedSymptoms.isEmpty
                                            ? '点此选择症状（可多选）'
                                            : _selectedSymptoms.length == 1
                                                ? '${_selectedSymptoms.first}'
                                                : '已选 ${_selectedSymptoms.length} 种症状',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedSymptoms.isEmpty ? Colors.grey[600] : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                            // 备注 + 相机
                            Row(children: [
                              Expanded(child: TextField(
                                controller: notesCtrl,
                                decoration: const InputDecoration(
                                  labelText: '备注',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              )),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: Icon(_photoPaths.isNotEmpty ? Icons.camera_alt : Icons.camera_alt_outlined,
                                  color: _photoPaths.isNotEmpty ? Colors.green : Colors.grey),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final photo = await picker.pickImage(source: ImageSource.camera);
                                  if (photo != null) setDialogState(() => _photoPaths.add(photo.path));
                                },
                              ),
                            ]),
                            // 照片预览（多张，可分别删除）
                            if (_photoPaths.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (var i = 0; i < _photoPaths.length; i++)
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Image.file(File(_photoPaths[i]), height: 52, width: 52, fit: BoxFit.cover),
                                          ),
                                          Positioned(
                                            top: -4, right: -4,
                                            child: GestureDetector(
                                              onTap: () => setDialogState(() => _photoPaths.removeAt(i)),
                                              child: Container(
                                                width: 18, height: 18,
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 底部按钮行（上传病历与记录并继续同风格）
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, 'skip'),
                          child: const Text('跳过', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: Size.zero,
                          ),
                        ),
                        const Spacer(),
                        // 上传病历（有症状时可点，风格与记录并继续统一）
                        if (hasSymptom)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.medical_services, size: 14),
                              label: const Text('上传病历', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () async {
                                try {
                                  var record = await _medicalService.getLatestActiveRecord(item.birdId);
                                  if (record == null) {
                                    record = await _medicalService.createRecord(item.birdId,
                                      notes: '称重时记录' + (notesCtrl.text.isNotEmpty ? ': ' + notesCtrl.text : ''));
                                  }
                                  final allSymptoms = await _medicalService.getSymptoms();
                                  for (final symName in _selectedSymptoms) {
                                    final matched = allSymptoms.cast<Map<String, dynamic>>().firstWhere(
                                      (s) => s['name'] == symName,
                                      orElse: () => <String, dynamic>{},
                                    );
                                    if (matched.isNotEmpty) {
                                      await _medicalService.addSymptom(
                                        record!['id'] as int, matched['id'] as int,
                                        notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                                      );
                                    }
                                  }
                                  if (!ctx.mounted) return;
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text('\u2705 已上传 ${_selectedSymptoms.length} 种症状到病历'),
                                        backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                                  );
                                  setDialogState(() => _selectedSymptoms.clear());
                                } catch (e) {
                                  if (!ctx.mounted) return;
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(content: Text(friendlyError(e).message)),
                                  );
                                }
                              },
                            ),
                          ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () async {
                            final w = double.tryParse(weightCtrl.text);
                            if (w == null || w <= 0) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('请输入有效体重')),
                              );
                              return;
                            }
                            try {
                              await _birdService.addWeight(item.birdId, w,
                                  isFasting: isFasting, notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null);
                              await _taskService.updateTaskItem(item.id, status: 'done', isFasting: isFasting ? 1 : 0);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx, 'record');
                            } catch (e) {
                              if (!ctx.mounted) return;
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(friendlyError(e).message)),
                              );
                            }
                          },
                          child: const Text('记录并继续'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return result ?? 'exit';
  }

  Future<void> _confirmMedicate(TaskItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('喂药 — ${item.birdName ?? "鸟#" + item.birdId.toString()}${item.birdRing != null && item.birdRing!.isNotEmpty ? ' (' + item.birdRing! + ')' : ''}'),
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
      firstDate: now.subtract(Duration(days: 30)),
      lastDate: now.add(Duration(days: 7)),
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
        SnackBar(content: Text('全部完成！'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyError(e).message)));
    }
  }

  void _navigateToBatchSelect({int? taskId}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BatchSelectScreen(
      taskDate: _selectedDate,
      existingTaskId: taskId ?? (_tasks.isNotEmpty ? _tasks.first.id : null),
    ))).then((_) => _loadTasks());
  }
}
