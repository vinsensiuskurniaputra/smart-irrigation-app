class ApiUrls {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://platform.staging.tekna.id/api/v2');
  static const String websocketUrl = String.fromEnvironment('WEBSOCKET_URL', defaultValue: 'wss://websocket-chart.staging.tekna.id/ws');
  // static const baseUrl = 'https://platform.staging.tekna.id/api/v2';

  static const login = '$baseUrl/auth/login';
  static const device = '$baseUrl/devices';
  static const brandList = '$baseUrl/brands';
  static const deviceList = '$baseUrl/brands';
  static const deviceParams = '$baseUrl/devices';
  static const getDeviceReport = '$baseUrl/devices';
  static const getReportParameter = '$baseUrl/devices';
  static const createReport = '$baseUrl/devices';
  static const getParamsConfig = '$baseUrl/devices';
  static const getNotification = '$baseUrl/user/alerts';


  static const updateProfile = '$baseUrl/user/profile';
  static const changePassword = '$baseUrl/user/password';
  static const logout = '$baseUrl/user/logout';
  
  static const resetDevice = '$baseUrl/devices';
  static const restartDevice = '$baseUrl/devices';
}
