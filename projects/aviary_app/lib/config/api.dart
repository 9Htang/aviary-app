/// API 服务器配置
class ApiConfig {
  // 电脑端的 aviary 服务器地址，手机连接时改为局域网 IP
  static const String baseUrl = 'http://192.168.10.9:3456';

  // API 路径
  static const String tasks = '/api/tasks';
  static const String taskCandidates = '/api/tasks/candidates';
  static const String taskGenerate = '/api/tasks/generate';
  static const String medicalRecords = '/api/medical';
  static const String weights = '/bird/api';
}
