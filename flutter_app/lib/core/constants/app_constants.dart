class AppConstants {
  // App Info
  static const String appName = 'Guardian Grove';
  static const String appVersion = '1.0.0';

  // API Configuration - FIXED TO USE YOUR PRODUCTION BACKEND
  static const String baseUrl = 'https://guardian-grove-backend.onrender.com';

  // Development/Testing URLs (commented out for production)
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String baseUrl = 'http://192.168.1.100:8000'; // Real device with your IP

  // Fallback URLs for testing
  static const String fallbackBaseUrl =
      'https://guardian-grove-backend.onrender.com';
  static const String localBaseUrl =
      'http://localhost:8000'; // For local development only

  static const String apiVersion = '';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forget-password';

  // Store Endpoints
  static const String storeEndpoint = '/store';
  static const String storeItemsEndpoint = '/store/';
  static const String storePurchaseEndpoint = '/store/buy';
  static const String userCoinsEndpoint = '/users/coins';
  static const String purchasedItemsEndpoint = '/users/purchasedItems';

  // Leaderboard Endpoints
  static const String leaderboardEndpoint = '/family/leaderboard';
  static const String familyLeaderboardEndpoint = '/family/familyLeaderboard';
  static const String familiesEndpoint = '/families';
  static const String currentFamilyRankEndpoint = '/leaderboard/my-family';
  static const String familyProgressStatsEndpoint =
      '/family/familyProgressStats';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Environment configuration
  static const bool isProduction = true; // Set to false for development

  // Get the appropriate base URL based on environment
  static String get apiBaseUrl {
    if (isProduction) {
      return baseUrl;
    } else {
      // For development, you can switch between these:
      return 'http://10.0.2.2:8000'; // Android emulator
      // return 'http://192.168.1.100:8000'; // Real device (replace with your IP)
      // return localBaseUrl; // Localhost
    }
  }

  // Debug information
  static void printDebugInfo() {
    // ignore: avoid_print
    print('🏗️ App: $appName v$appVersion');
    // ignore: avoid_print
    print('🌐 Base URL: $apiBaseUrl');
    // ignore: avoid_print
    print('🔧 Environment: [33m${isProduction ? 'Production' : 'Development'}[0m');
    // ignore: avoid_print
    print('⏱️ Timeouts: $connectionTimeout ms / $receiveTimeout ms');
  }
}
