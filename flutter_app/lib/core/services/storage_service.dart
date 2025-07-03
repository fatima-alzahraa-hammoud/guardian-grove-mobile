import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============= AUTHENTICATION METHODS =============
  static String? getToken() {
    return _prefs?.getString('auth_token');
  }

  static Future<void> setToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  // FIX: Add the missing saveToken method (alias for setToken)
  static Future<void> saveToken(String token) async {
    await setToken(token);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove('auth_token');
  }

  // ============= USER DATA METHODS =============
  static UserModel? getUser() {
    final userJson = _prefs?.getString('user_data');
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  static Future<void> setUser(UserModel user) async {
    await _prefs?.setString('user_data', jsonEncode(user.toJson()));
  }

  // FIX: Add the missing saveUser method (alias for setUser)
  static Future<void> saveUser(UserModel user) async {
    await setUser(user);
  }

  static Future<void> clearUser() async {
    await _prefs?.remove('user_data');
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // ============= GOALS & ADVENTURES CACHE =============

  // Cache goals for offline access
  static Future<void> cacheGoals(List<dynamic> goals) async {
    final goalsJson = jsonEncode(goals);
    await _prefs?.setString('cached_goals', goalsJson);
    await _prefs?.setInt(
      'goals_cache_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<dynamic>? getCachedGoals() {
    final goalsJson = _prefs?.getString('cached_goals');
    final cacheTime = _prefs?.getInt('goals_cache_time') ?? 0;

    // Check if cache is still valid (24 hours)
    final isValid =
        DateTime.now().millisecondsSinceEpoch - cacheTime < 24 * 60 * 60 * 1000;

    if (goalsJson != null && isValid) {
      return jsonDecode(goalsJson);
    }
    return null;
  }

  // Cache adventures for offline access
  static Future<void> cacheAdventures(List<dynamic> adventures) async {
    final adventuresJson = jsonEncode(adventures);
    await _prefs?.setString('cached_adventures', adventuresJson);
    await _prefs?.setInt(
      'adventures_cache_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<dynamic>? getCachedAdventures() {
    final adventuresJson = _prefs?.getString('cached_adventures');
    final cacheTime = _prefs?.getInt('adventures_cache_time') ?? 0;

    // Check if cache is still valid (24 hours)
    final isValid =
        DateTime.now().millisecondsSinceEpoch - cacheTime < 24 * 60 * 60 * 1000;

    if (adventuresJson != null && isValid) {
      return jsonDecode(adventuresJson);
    }
    return null;
  }

  // ============= APP PREFERENCES =============
  static bool getFirstTime() {
    return _prefs?.getBool('is_first_time') ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    await _prefs?.setBool('is_first_time', value);
  }

  // Theme and UI preferences
  static bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('dark_mode', value);
  }

  // Notifications settings
  static bool getNotificationsEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool('notifications_enabled', value);
  }

  // Last sync time for data freshness
  static DateTime? getLastSyncTime() {
    final timestamp = _prefs?.getInt('last_sync_time');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  static Future<void> setLastSyncTime(DateTime time) async {
    await _prefs?.setInt('last_sync_time', time.millisecondsSinceEpoch);
  }

  // ============= GENERIC CACHE METHODS =============
  static Future<void> cacheData(String key, dynamic data) async {
    final jsonString = jsonEncode(data);
    await _prefs?.setString('cache_$key', jsonString);
    await _prefs?.setInt(
      'cache_${key}_time',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static T? getCachedData<T>(
    String key,
    T Function(dynamic) fromJson, {
    int maxAgeHours = 24,
  }) {
    final jsonString = _prefs?.getString('cache_$key');
    final cacheTime = _prefs?.getInt('cache_${key}_time') ?? 0;

    // Check if cache is still valid
    final isValid =
        DateTime.now().millisecondsSinceEpoch - cacheTime <
        maxAgeHours * 60 * 60 * 1000;

    if (jsonString != null && isValid) {
      try {
        final jsonData = jsonDecode(jsonString);
        return fromJson(jsonData);
      } catch (e) {
        // If parsing fails, remove corrupted cache
        _prefs?.remove('cache_$key');
        _prefs?.remove('cache_${key}_time');
        return null;
      }
    }
    return null;
  }

  // Clear specific cache
  static Future<void> clearCache(String key) async {
    await _prefs?.remove('cache_$key');
    await _prefs?.remove('cache_${key}_time');
  }

  // Clear all cached data but keep user data and settings
  static Future<void> clearAllCache() async {
    final keys =
        _prefs?.getKeys().where((key) => key.startsWith('cache_')).toList() ??
        [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  // ============= DEBUGGING METHODS =============
  static Map<String, dynamic> getAllStoredData() {
    final keys = _prefs?.getKeys() ?? <String>{};
    final data = <String, dynamic>{};

    for (final key in keys) {
      final value = _prefs?.get(key);
      data[key] = value;
    }

    return data;
  }

  static void printStorageDebug() {
    final data = getAllStoredData();
    debugPrint('=== STORAGE DEBUG ===');
    data.forEach((key, value) {
      debugPrint(
        '$key: ${value.toString().length > 100 ? '${value.toString().substring(0, 100)}...' : value}',
      );
    });
    debugPrint('====================');
  }

  // ============= UTILITY METHODS FOR PROFILE =============

  // Update specific user field without affecting other data
  static Future<void> updateUserField(String field, dynamic value) async {
    final currentUser = getUser();
    if (currentUser == null) return;

    Map<String, dynamic> userJson = currentUser.toJson();
    userJson[field] = value;

    final updatedUser = UserModel.fromJson(userJson);
    await saveUser(updatedUser);
  }

  // Update multiple user fields at once
  static Future<void> updateUserFields(Map<String, dynamic> updates) async {
    final currentUser = getUser();
    if (currentUser == null) return;

    Map<String, dynamic> userJson = currentUser.toJson();
    userJson.addAll(updates);

    final updatedUser = UserModel.fromJson(userJson);
    await saveUser(updatedUser);
  }

  // Check if user data exists and is valid
  static bool hasValidUserData() {
    final user = getUser();
    final token = getToken();
    return user != null &&
        token != null &&
        token.isNotEmpty &&
        user.id.isNotEmpty;
  }

  // FIX: Add the missing isLoggedIn method
  static bool isLoggedIn() {
    return hasValidUserData();
  }

  // Get user-specific cache key
  static String getUserCacheKey(String key) {
    final user = getUser();
    return user != null ? '${user.id}_$key' : key;
  }
}
