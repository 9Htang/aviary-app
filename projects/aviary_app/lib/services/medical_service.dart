import '../config/api.dart';
import 'api_client.dart';

class MedicalService {
  final ApiClient _api = ApiClient();

  /// 获取某只鸟的最新未痊愈病历
  Future<Map<String, dynamic>?> getLatestActiveRecord(int birdId) async {
    final resp = await _api.get('${ApiConfig.medicalRecords}/birds/$birdId/records');
    final records = (resp['data'] as List?) ?? [];
    // 找到最后一条未痊愈的病历（outcome != '痊愈'）
    for (final r in records.reversed) {
      if (r['outcome'] != '痊愈') return r as Map<String, dynamic>;
    }
    return null;
  }

  /// 创建新病历
  Future<Map<String, dynamic>> createRecord(int birdId, {String? diagnosis, String? notes}) async {
    final resp = await _api.post('${ApiConfig.medicalRecords}/birds/$birdId/records', body: {
      'onset_date': DateTime.now().toString().substring(0, 10),
      'diagnosis': diagnosis,
      'notes': notes,
    });
    return resp['data'] as Map<String, dynamic>;
  }

  /// 获取所有症状列表
  Future<List<Map<String, dynamic>>> getSymptoms() async {
    final resp = await _api.get('${ApiConfig.medicalRecords}/symptoms');
    return (resp['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  /// 添加症状到病历
  Future<void> addSymptom(int recordId, int symptomId, {String? notes, String? locationType, int? locationId}) async {
    await _api.post('${ApiConfig.medicalRecords}/records/$recordId/symptoms', body: {
      'symptom_id': symptomId,
      'notes': notes,
      'location_type': locationType,
      'location_id': locationId,
    });
  }
}
