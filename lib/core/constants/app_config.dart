class AppConfig {
  static const String version = "v${String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  )}";
}
