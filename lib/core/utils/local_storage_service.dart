import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageService {
  String? getToken();
  Future<void> setToken(String token);
  Future<void> clearToken();
}

class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageServiceImpl(this._prefs);

  @override
  String? getToken() => _prefs.getString('token');

  @override
  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove('token');
  }
}
