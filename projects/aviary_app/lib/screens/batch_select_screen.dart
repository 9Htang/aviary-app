import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../utils/error_helper.dart';
import '../models/bird.dart';

class BatchSelectScreen extends StatefulWidget {
  final String taskDate;
  final int? existingTaskId;

  const BatchSelectScreen({
    super.key,
    required this.taskDate,
    this.existingTaskId,
  });

  @override
  State<BatchSelectScreen> createState() => _BatchSelectScreenState();
}

class _BatchSelectScreenState extends State<BatchSelectScreen> {
  final TaskService _taskService = TaskService();
  final Set<int> _selectedIds = {};
  List<Bird> _allBirds = [];
  Map<String, List<Bird>> _groupedBirds = {};
  List<Bird> _filteredBirds = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _selectedFilter; // null=全部, 其他=对应分类

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => _loading = true);
    try {
      final candidates = await _taskService.getCandidates();
      if (!mounted) return;
      _allBirds = candidates['all'] ?? [];
      _groupedBirds = _groupByReason(_allBirds);
      _filteredBirds = _allBirds;
      _selectedFilter = null;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e).message)),
      );
    }
  }

  Map<String, List<Bird>> _groupByReason(List<Bird> birds) {
    final groups = <String, List<Bird>>{};
    for (final bird in birds) {
      final reason = bird.reason ?? 'other';
      groups.putIfAbsent(reason, () => []).add(bird);
    }
    return groups;
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBirds = _allBirds;
      } else {
        _filteredBirds = _allBirds.where((b) =>
          b.name.toLowerCase().contains(query.toLowerCase()) ||
          (b.ringNumber?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }
    });
  }

  void _toggleAll(bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.addAll(_filteredBirds.map((b) => b.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  Future<void> _submitBatch() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择鸟只')),
      );
      return;
    }

    try {
      // 如果还没有任务，先创建
      int taskId;
      if (widget.existingTaskId != null) {
        taskId = widget.existingTaskId!;
      } else {
        final task = await _taskService.createTask(date: widget.taskDate, title: '手动任务');
        taskId = task.id;
      }

      // 批量添加
      final items = _selectedIds.map((birdId) => {
        'bird_id': birdId,
        'task_type': 'weigh',
        'is_fasting': 1,
        'notes': '手动选择',
      }).toList();

      await _taskService.batchAddItems(taskId, items);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已添加 ${items.length} 只鸟到任务计划'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e).message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('批量选鸟 (${_selectedIds.length})'),
        actions: [
          if (!_loading)
            Row(
              children: [
                Checkbox(
                  value: _selectedIds.length == _filteredBirds.length && _filteredBirds.isNotEmpty,
                  onChanged: (v) => _toggleAll(v ?? false),
                ),
                const Text('全选'),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _submitBatch,
                  tooltip: '添加到任务',
                ),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 搜索栏
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '搜索鸟名或环号...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _filter,
                  ),
                ),
                // 分类快速选择
                if (_searchQuery.isEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        _filterChip('全部', null, Icons.all_inclusive),
                        _filterChip('🪺 雏鸟', 'nestling', Icons.egg),
                        _filterChip('🤒 病鸟', 'sick', Icons.sick),
                        _filterChip('⚖️ 到期称重', 'due_weigh', Icons.monitor_weight),
                      ],
                    ),
                  ),
                // 列表
                Expanded(
                  child: _filteredBirds.isEmpty
                      ? const Center(child: Text('没有找到匹配的鸟只'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredBirds.length,
                          itemBuilder: (context, index) {
                            final bird = _filteredBirds[index];
                            final selected = _selectedIds.contains(bird.id);
                            return Card(
                              child: CheckboxListTile(
                                value: selected,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedIds.add(bird.id);
                                    } else {
                                      _selectedIds.remove(bird.id);
                                    }
                                  });
                                },
                                title: Text(bird.displayName),
                                subtitle: Row(
                                  children: [
                                    Text(bird.species ?? ''),
                                    if (bird.reason != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        _reasonLabel(bird.reason!),
                                        style: TextStyle(fontSize: 12, color: _reasonColor(bird.reason!)),
                                      ),
                                    ],
                                  ],
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: _reasonColor(bird.reason ?? ''),
                                  child: Text(bird.genderEmoji, style: const TextStyle(fontSize: 18)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _selectedIds.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: _submitBatch,
                  icon: const Icon(Icons.task_alt),
                  label: Text('添加 ${_selectedIds.length} 只到任务计划'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _filterChip(String label, String? reason, IconData icon) {
    final isSelected = _selectedFilter == reason;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        avatar: isSelected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Icon(icon, size: 16, color: Colors.grey[600]),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        selected: isSelected,
        selectedColor: Colors.green,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = reason;
            _searchQuery = '';
            if (reason == null) {
              _filteredBirds = _allBirds;
            } else {
              _filteredBirds = _groupedBirds[reason] ?? [];
            }
          });
        },
      ),
    );
  }

  String _reasonLabel(String reason) {
    switch (reason) {
      case 'nestling': return '🪺 雏鸟';
      case 'sick': return '🤒 病鸟';
      case 'due_weigh': return '⚖️ 待称重';
      case 'other': return '📋 其他';
      default: return reason;
    }
  }

  Color _reasonColor(String reason) {
    switch (reason) {
      case 'nestling': return Colors.orange;
      case 'sick': return Colors.red;
      case 'due_weigh': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
