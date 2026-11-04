abstract final class AppConfig {
  static const parseServerUrl = String.fromEnvironment(
    'PARSE_SERVER_URL',
    defaultValue: 'https://parseapi.back4app.com',
  );

  static const parseApplicationId = String.fromEnvironment(
    'PARSE_APPLICATION_ID',
  );

  static const parseJavaScriptKey = String.fromEnvironment(
    'PARSE_JAVASCRIPT_KEY',
  );

  static const localAdminEmail = String.fromEnvironment(
    'LOCAL_ADMIN_EMAIL',
    defaultValue: 'admin@genesis.local',
  );

  static const localAdminPassword = String.fromEnvironment(
    'LOCAL_ADMIN_PASSWORD',
    defaultValue: 'Genesis@2026',
  );

  static bool get isBack4AppConfigured =>
      parseApplicationId.trim().isNotEmpty &&
      parseJavaScriptKey.trim().isNotEmpty;
}
