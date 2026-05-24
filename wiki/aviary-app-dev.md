# Flutter 手机端开发指南

## 本地开发环境
- Flutter SDK: `C:\tools\flutter`
- 项目路径: `projects/aviary_app/`
- 构建: `flutter build apk --release`

## 关键依赖
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:  # 中文本地化
    sdk: flutter
  http: ^1.2.0
  intl: ^0.19.0
  fl_chart: ^0.69.0
  shared_preferences: ^2.3.0
```

## Android 配置要点

### 明文 HTTP 支持（Android 9+）
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application
    android:usesCleartextTraffic="true"
    ...>
```

### Session Cookie 管理
使用 `dart:io` 的 `HttpClient` 手动管理 cookie，避免 `http` 包的 `CookieManager` 冲突：
```dart
late final HttpClient _client;
String? _sessionCookie;

// 从 Set-Cookie 提取
void _saveCookies(HttpHeaders headers) {
  final setCookie = headers.value('set-cookie');
  final match = RegExp(r'(connect\.sid=[^;]+)').firstMatch(setCookie);
  // ...
}

// 请求时手动带上
request.headers.set('cookie', _sessionCookie!);
```

## 代码规范
- 所有用户可见文本使用中文
- 日期选择器通过 `flutter_localizations` 实现中文
- 错误提示需明确区分网络错误和业务错误

## 构建流程
1. 修改代码
2. `flutter build apk --release`
3. 复制到 `projects/aviary/public/aviary.apk`
4. 更新版本号 `pubspec.yaml` 中 `version: x.x.x+x`

## 版本追踪
版本号保存在 `VERSION_TRACKER.md`，每次构建+1。
