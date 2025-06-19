class AppConstants {
  // App Info
  static const String appName = 'Guardian Grove';
  static const String appVersion = '1.0.0';
  
  // API Configuration (Your backend)
  static const String baseUrl = 'http://localhost:8000'; // Change this for production
  static const String apiVersion = '';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forget-password';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}