/// lib/services/pref/shared_pref_service.dart
///
/// a service for operating the shared preferences within the users' local device
import 'package:shared_preferences/shared_preferences.dart';

// Service class for SharedPreferences
class SharedPreferencesService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // String List operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  Future<bool> appendStringList(String key, List<String> value) async {
    final List<String>? current = getStringList(key);

    if (current == null) {
      return false;
    } else {
      current.addAll(value);
      final List<String> updated = current;
      await removeKey(key);
      if (await setStringList(key, updated) == true) {
        return true;
      }
      return false;
    }
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Remove and clear operations
  Future<bool> removeKey(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clearAll() async {
    return await _prefs.clear();
  }

  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code (without using the plugin) while the app is running.
  Future<void> reload() async {
    return await _prefs.reload();
  }
}
