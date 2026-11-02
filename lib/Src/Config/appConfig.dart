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
}
