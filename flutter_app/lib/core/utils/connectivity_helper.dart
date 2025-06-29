import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class ConnectivityHelper {
  static Future<bool> testBackendConnectivity() async {
    final dio = Dio();

    // List of URLs to test
    final urlsToTest = [
      AppConstants.baseUrl,
      AppConstants.fallbackBaseUrl,
      AppConstants.localBaseUrl,
    ];
    for (String baseUrl in urlsToTest) {
      try {
        debugPrint('Testing connectivity to: $baseUrl');

        // Test the actual auth endpoint instead of /health
        final response = await dio.get(
          '$baseUrl/auth/register',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            validateStatus:
                (status) =>
                    status != null &&
                    status < 500, // Accept 4xx as connection success
          ),
        );

        debugPrint('✅ Connected to $baseUrl - Status: ${response.statusCode}');
        if (response.statusCode == 405) {
          debugPrint(
            '📝 Note: Got 405 Method Not Allowed - this is expected for GET on auth endpoint',
          );
        } else if (response.statusCode == 404) {
          debugPrint('⚠️  Got 404 - auth endpoint might not exist');
        }
        return true;
      } catch (e) {
        debugPrint('❌ Failed to connect to $baseUrl - Error: $e');
        continue;
      }
    }

    // If all URLs fail, try a simple network test
    try {
      debugPrint('Testing basic internet connectivity...');
      await dio.get(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      debugPrint('✅ Internet connection is working');
      debugPrint('❌ But backend server is not accessible');
    } catch (e) {
      debugPrint('❌ No internet connection available');
    }

    return false;
  }

  static Future<void> debugNetworkSettings() async {
    debugPrint('=== NETWORK DEBUG INFO ===');
    debugPrint('Current baseUrl: ${AppConstants.baseUrl}');
    debugPrint('Fallback baseUrl: ${AppConstants.fallbackBaseUrl}');
    debugPrint('Local baseUrl: ${AppConstants.localBaseUrl}');
    debugPrint('Connection timeout: ${AppConstants.connectionTimeout}ms');
    debugPrint('Receive timeout: ${AppConstants.receiveTimeout}ms');
    debugPrint('==========================');
    await testBackendConnectivity();
  }
}
