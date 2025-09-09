class ApiUrls {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://202.10.48.12:8080/api/v1');
  static const String websocketUrl = String.fromEnvironment('WEBSOCKET_URL', defaultValue: 'ws://202.10.48.12:8080/api/v1');
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
  // Actuator base (append /{id}/control or /{id}/mode in services)
  static const actuator = '$baseUrl/actuators';
  
  // Plant prediction endpoints
  static const plantPredict = '$baseUrl/irrigation/predict';
  static String savePlant(int deviceId) => '$baseUrl/irrigation/devices/$deviceId/plant';
  
  // WebSocket endpoints
  static String deviceLive(int deviceId) => '$websocketUrl/devices/$deviceId/live';
}
