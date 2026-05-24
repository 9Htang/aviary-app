import '../config/api.dart';
import '../models/task.dart';
import '../models/task_item.dart';
import '../models/bird.dart';
import 'api_client.dart';

class TaskService {
  final ApiClient _api = ApiClient();

  /// 获取某天的任务列表
  Future<List<Task>> getTasks({String? date}) async {
    final resp = await _api.get(ApiConfig.tasks, query: date != null ? {'date': date} : null);
    final data = resp['data'];
    if (data == null) return [];
    return (data as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 获取任务详情
  Future<Task?> getTask(int id) async {
    final resp = await _api.get('${ApiConfig.tasks}/$id');
    final data = resp['data'];
    if (data == null) return null;
    return Task.fromJson(data as Map<String, dynamic>);
  }

  /// 创建任务
  Future<Task> createTask({String? date, String? title, List<Map<String, dynamic>>? items}) async {
    final resp = await _api.post(ApiConfig.tasks, body: {
      'task_date': date,
      'title': title,
      'items': items,
    });
    return Task.fromJson(resp['data'] as Map<String, dynamic>);
  }

  /// 更新任务状态
  Future<Task?> updateTask(int id, {String? status}) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    final resp = await _api.patch('${ApiConfig.tasks}/$id', body: body);
    final data = resp['data'];
    if (data == null) return null;
    return Task.fromJson(data as Map<String, dynamic>);
  }

  /// 更新任务项
  /// [status] - done / pending / skipped
  /// [isFasting] - 1 空腹 / 0 未空腹
  /// [completedAt] - 完成时间
  Future<TaskItem?> updateTaskItem(int itemId, {String? status, int? isFasting, String? completedAt}) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (isFasting != null) body['is_fasting'] = isFasting;
    if (completedAt != null) body['completed_at'] = completedAt;
    final resp = await _api.patch('${ApiConfig.tasks}/items/$itemId', body: body);
    final data = resp['data'];
    if (data == null) return null;
    return TaskItem.fromJson(data as Map<String, dynamic>);
  }

  /// 批量添加任务项
  Future<void> batchAddItems(int taskId, List<Map<String, dynamic>> items) async {
    await _api.post('${ApiConfig.tasks}/$taskId/items/batch', body: {'items': items});
  }

  /// 获取自动选鸟候选人
  Future<Map<String, List<Bird>>> getCandidates() async {
    final resp = await _api.get(ApiConfig.taskCandidates);
    final data = resp['data'] as Map<String, dynamic>;
    return {
      'nestlings': (data['nestlings'] as List?)?.map((e) => Bird.fromJson(e)).toList() ?? [],
      'sick_birds': (data['sick_birds'] as List?)?.map((e) => Bird.fromJson(e)).toList() ?? [],
      'due_weigh': (data['due_weigh'] as List?)?.map((e) => Bird.fromJson(e)).toList() ?? [],
      'all': (data['all'] as List?)?.map((e) => Bird.fromJson(e)).toList() ?? [],
    };
  }

  /// 自动生成今日任务
  Future<Task> autoGenerate() async {
    final resp = await _api.post(ApiConfig.taskGenerate);
    final data = resp['task'] as Map<String, dynamic>;
    return Task.fromJson(data);
  }
}
