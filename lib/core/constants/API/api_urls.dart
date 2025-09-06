class ApiUrls {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.8:8080/api/v1');
  static const String websocketUrl = String.fromEnvironment('WEBSOCKET_URL', defaultValue: 'wss://192.168.1.8/ws');
  // static const baseUrl = 'https://192.168.1.8/api/v2';

  static const login = '$baseUrl/login';
  static const register = '$baseUrl/register';
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
