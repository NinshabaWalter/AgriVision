import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../app_config.dart';

class StorageService {
  static late Box _generalBox;
  static late Box _offlineBox;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> init() async {
    // Initialize Hive boxes
    _generalBox = await Hive.openBox('general');
    _offlineBox = await Hive.openBox('offline');
  }

  static Future<void> migrate() async {
    // Handle any data migrations between app versions
    final currentVersion = await getString('app_version');
    if (currentVersion != AppConfig.appVersion) {
      // Perform migration logic here
      await setString('app_version', AppConfig.appVersion);
    }
  }

  // General storage methods
  static Future<void> setString(String key, String value) async {
    await _generalBox.put(key, value);
  }

  static String? getString(String key) {
    return _generalBox.get(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _generalBox.put(key, value);
  }

  static int? getInt(String key) {
    return _generalBox.get(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _generalBox.put(key, value);
  }

  static bool? getBool(String key) {
    return _generalBox.get(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _generalBox.put(key, value);
  }

  static double? getDouble(String key) {
    return _generalBox.get(key);
  }

  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _generalBox.put(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getObject(String key) {
    final value = _generalBox.get(key);
    if (value != null) {
      try {
        return jsonDecode(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> remove(String key) async {
    await _generalBox.delete(key);
  }

  static Future<void> clear() async {
    await _generalBox.clear();
  }

  // Secure storage methods (for sensitive data like tokens)
  static Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // Offline data storage methods
  static Future<void> setOfflineData(String key, Map<String, dynamic> data) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final offlineData = {
      'data': data,
      'timestamp': timestamp,
    };
    await _offlineBox.put(key, jsonEncode(offlineData));
  }

  static Map<String, dynamic>? getOfflineData(String key) {
    final value = _offlineBox.get(key);
    if (value != null) {
      try {
        final offlineData = jsonDecode(value);
        final timestamp = offlineData['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        final ageInDays = (now - timestamp) / (1000 * 60 * 60 * 24);
        
        // Check if data is still valid
        if (ageInDays <= AppConfig.maxOfflineDataAge) {
          return offlineData['data'];
        } else {
          // Data is too old, remove it
          _offlineBox.delete(key);
          return null;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> removeOfflineData(String key) async {
    await _offlineBox.delete(key);
  }

  static Future<void> clearOfflineData() async {
    await _offlineBox.clear();
  }

  static List<String> getOfflineDataKeys() {
    return _offlineBox.keys.cast<String>().toList();
  }

  // User-specific storage methods
  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await setObject(AppConfig.userDataKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    return getObject(AppConfig.userDataKey);
  }

  static Future<void> clearUserData() async {
    await remove(AppConfig.userDataKey);
    await removeSecure(AppConfig.authTokenKey);
  }

  // Auth token methods
  static Future<void> setAuthToken(String token) async {
    await setSecureString(AppConfig.authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    return await getSecureString(AppConfig.authTokenKey);
  }

  static Future<void> clearAuthToken() async {
    await removeSecure(AppConfig.authTokenKey);
  }

  // App settings methods
  static Future<void> setSettings(Map<String, dynamic> settings) async {
    await setObject(AppConfig.settingsKey, settings);
  }

  static Map<String, dynamic> getSettings() {
    return getObject(AppConfig.settingsKey) ?? {
      'language': 'en',
      'notifications_enabled': true,
      'offline_mode': true,
      'theme_mode': 'system',
    };
  }

  // Cache management
  static Future<void> cleanupOldData() async {
    final keys = getOfflineDataKeys();
    for (final key in keys) {
      getOfflineData(key); // This will automatically remove old data
    }
  }

  static Future<int> getCacheSize() async {
    // Calculate approximate cache size
    int size = 0;
    
    // General box size
    for (final key in _generalBox.keys) {
      final value = _generalBox.get(key);
      if (value is String) {
        size += value.length;
      }
    }
    
    // Offline box size
    for (final key in _offlineBox.keys) {
      final value = _offlineBox.get(key);
      if (value is String) {
        size += value.length;
      }
    }
    
    return size;
  }
}