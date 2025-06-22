import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.tokenKey);
  }

  // User data management
  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(AppConstants.userKey, userJson);
  }

  static UserModel? getUser() {
    final userJson = _prefs?.getString(AppConstants.userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  static Future<void> removeUser() async {
    await _prefs?.remove(AppConstants.userKey);
  }

  // App state management
  static Future<void> setFirstTime(bool isFirstTime) async {
    await _prefs?.setBool(AppConstants.isFirstTimeKey, isFirstTime);
  }

  static bool isFirstTime() {
    return _prefs?.getBool(AppConstants.isFirstTimeKey) ?? true;
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user's family ID
  static String? getFamilyId() {
    final user = getUser();
    return user?.familyId;
  }
}
