class AppConstants {
  // App Info
  static const String appName = 'Guardian Grove';
  static const String appVersion = '1.0.0'; // API Configuration (Your backend)
  // Use production backend for all environments
  static const String baseUrl =
      'https://guardian-grove-backend.onrender.com'; // Production backend
  // Alternative for real device: 'https://guardian-grove-backend.onrender.com'
  // To find your IP: Run 'ipconfig' in cmd and look for IPv4 Address

  // INSTRUCTIONS FOR SETUP:
  // 1. For Android Emulator: Use 'https://guardian-grove-backend.onrender.com'
  // 2. For Real Device: Use 'https://guardian-grove-backend.onrender.com'
  // 3. Make sure your backend server is running and accessible

  // Fallback URLs for testing
  static const String fallbackBaseUrl =
      'https://guardian-grove-backend.onrender.com'; // Production backend
  static const String localBaseUrl =
      'https://guardian-grove-backend.onrender.com'; // Production backend

  static const String apiVersion = '';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forget-password';
  // Leaderboard Endpoints
  static const String leaderboardEndpoint =
      '/family/leaderboard'; // Main endpoint like React version
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
}
