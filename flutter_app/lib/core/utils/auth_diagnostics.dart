import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

/// Authentication diagnostic utility to help identify and fix auth issues
class AuthDiagnostics {
  static final ApiClient _apiClient = ApiClient();

  /// Run comprehensive authentication diagnostics
  static Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};

    debugPrint('🔍 Starting Authentication Diagnostics...');

    // 1. Check storage service initialization
    results['storage_initialized'] = await _checkStorageService();

    // 2. Check API client initialization
    results['api_client_initialized'] = _checkApiClient();

    // 3. Test backend connectivity
    results['backend_connectivity'] = await _testBackendConnectivity();

    // 4. Check stored auth data
    results['stored_auth_data'] = _checkStoredAuthData();

    // 5. Test different backend URLs
    results['url_tests'] = await _testBackendUrls();

    debugPrint('✅ Authentication Diagnostics Complete');
    _printDiagnosticReport(results);

    return results;
  }

  static Future<bool> _checkStorageService() async {
    try {
      await StorageService.init();
      debugPrint('✅ Storage Service: Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Storage Service: Failed to initialize - $e');
      return false;
    }
  }

  static bool _checkApiClient() {
    try {
      _apiClient.init();
      debugPrint('✅ API Client: Initialized successfully');
      debugPrint('📍 Base URL: ${AppConstants.baseUrl}');
      return true;
    } catch (e) {
      debugPrint('❌ API Client: Failed to initialize - $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> _testBackendConnectivity() async {
    final connectivity = <String, dynamic>{};

    try {
      // Test basic connection
      final isConnected = await _apiClient.testConnection();
      connectivity['basic_connection'] = isConnected;

      if (isConnected) {
        debugPrint('✅ Backend Connectivity: SUCCESS');
      } else {
        debugPrint('❌ Backend Connectivity: FAILED');

        // Try to find working URL
        final workingUrl = await _apiClient.findWorkingBaseUrl();
        connectivity['working_url'] = workingUrl;

        if (workingUrl != null) {
          debugPrint('💡 Found working URL: $workingUrl');
        } else {
          debugPrint('❌ No working backend URL found');
        }
      }
    } catch (e) {
      debugPrint('❌ Backend Connectivity Error: $e');
      connectivity['error'] = e.toString();
    }

    return connectivity;
  }

  static Map<String, dynamic> _checkStoredAuthData() {
    final authData = <String, dynamic>{};

    try {
      final token = StorageService.getToken();
      final user = StorageService.getUser();
      final isLoggedIn = StorageService.isLoggedIn();

      authData['has_token'] = token != null && token.isNotEmpty;
      authData['has_user'] = user != null;
      authData['is_logged_in'] = isLoggedIn;
      authData['token_length'] = token?.length ?? 0;
      authData['user_id'] = user?.id ?? 'none';
      authData['user_email'] = user?.email ?? 'none';

      if (isLoggedIn) {
        debugPrint('✅ Stored Auth Data: User is logged in');
        debugPrint('👤 User: ${user?.name} (${user?.email})');
      } else {
        debugPrint('ℹ️ Stored Auth Data: No user logged in');
      }
    } catch (e) {
      debugPrint('❌ Stored Auth Data Error: $e');
      authData['error'] = e.toString();
    }

    return authData;
  }

  static Future<Map<String, List<String>>> _testBackendUrls() async {
    final urlTests = <String, List<String>>{};

    final testUrls = [
      AppConstants.baseUrl,
      AppConstants.fallbackBaseUrl,
      AppConstants.localBaseUrl,
      'http://localhost:8000',
      'http://127.0.0.1:8000',
      'http://10.0.2.2:8000',
    ];

    for (final url in testUrls) {
      final results = <String>[];
      try {
        debugPrint('🔍 Testing URL: $url');
        // TODO: Implement URL testing in future version
        results.add('URL testing not yet implemented');
      } catch (e) {
        results.add('Failed: $e');
      }

      urlTests[url] = results;
    }

    return urlTests;
  }

  static void _printDiagnosticReport(Map<String, dynamic> results) {
    debugPrint('\n📊 === AUTHENTICATION DIAGNOSTIC REPORT ===');
    debugPrint('Storage Initialized: ${results['storage_initialized']}');
    debugPrint('API Client Initialized: ${results['api_client_initialized']}');
    debugPrint(
      'Backend Connected: ${results['backend_connectivity']['basic_connection'] ?? false}',
    );
    debugPrint(
      'User Logged In: ${results['stored_auth_data']['is_logged_in'] ?? false}',
    );
    debugPrint(
      'Has Token: ${results['stored_auth_data']['has_token'] ?? false}',
    );
    debugPrint(
      'Has User Data: ${results['stored_auth_data']['has_user'] ?? false}',
    );
    debugPrint('===========================================\n');
  }

  /// Quick fix suggestions based on common issues
  static List<String> getQuickFixSuggestions(Map<String, dynamic> diagnostics) {
    final suggestions = <String>[];

    if (!(diagnostics['storage_initialized'] ?? false)) {
      suggestions.add('Initialize StorageService in main.dart');
    }

    if (!(diagnostics['backend_connectivity']['basic_connection'] ?? false)) {
      suggestions.add('Check if backend server is running on port 8000');
      suggestions.add('Verify network connectivity');
      suggestions.add('Try different IP address in app_constants.dart');
    }

    final authData =
        diagnostics['stored_auth_data'] as Map<String, dynamic>? ?? {};
    if (authData['has_token'] == false && authData['is_logged_in'] == true) {
      suggestions.add('Clear corrupted auth data: StorageService.clearAll()');
    }

    return suggestions;
  }
}
