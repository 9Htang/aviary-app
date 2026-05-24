import '../config/api.dart';
import '../models/bird.dart';
import '../models/weight_record.dart';
import 'api_client.dart';

class BirdService {
  final ApiClient _api = ApiClient();

  /// 获取体重记录
  Future<List<WeightRecord>> getWeights(int birdId) async {
    final resp = await _api.get('${ApiConfig.weights}/$birdId/weights');
    final data = resp['data'];
    if (data == null) return [];
    return (data as List).map((e) => WeightRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 记录体重
  Future<void> addWeight(int birdId, double weight, {String? notes, bool isFasting = true}) async {
    await _api.post('${ApiConfig.weights}/$birdId/weight', body: {
      'weight': weight,
      'notes': notes,
      'is_fasting': isFasting ? 1 : 0,
    });
  }

  /// 所有鸟只列表（从任务候选人 API 中提取）
  Future<List<Bird>> getAllBirds({String? query}) async {
    try {
      final resp = await _api.get('/api/tasks/candidates');
      final data = resp['data'] as Map<String, dynamic>;
      final all = (data['all'] as List?)?.map((e) => Bird.fromJson(e)).toList() ?? [];
      if (query != null && query.isNotEmpty) {
        return all.where((b) =>
          b.name.contains(query) ||
          (b.ringNumber?.contains(query) ?? false)
        ).toList();
      }
      return all;
    } catch (_) {
      // Fallback to static list if API fails
      return [];
    }
  }
}
