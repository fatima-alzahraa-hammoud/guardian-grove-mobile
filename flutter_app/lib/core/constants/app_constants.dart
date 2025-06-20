class AppConstants {
  // App Info
  static const String appName = 'Guardian Grove';
  static const String appVersion = '1.0.0'; // API Configuration (Your backend)
  // Use 10.0.2.2 for Android emulator, or your computer's IP for real device
  static const String baseUrl =
      'http://10.0.2.2:8000'; // Android emulator maps to host localhost
  // Alternative for real device: 'http://192.168.1.100:8000'
  // To find your IP: Run 'ipconfig' in cmd and look for IPv4 Address

  // INSTRUCTIONS FOR SETUP:
  // 1. For Android Emulator: Use 'http://10.0.2.2:8000'
  // 2. For Real Device: Find your computer's IP address:
  //    - Windows: Run 'ipconfig' in cmd, look for IPv4 Address
  //    - Mac/Linux: Run 'ifconfig' in terminal
  //    - Example: 'http://192.168.1.100:8000'
  // 3. Make sure your backend server is running and accessible

  // Fallback URLs for testing
  static const String fallbackBaseUrl =
      'http://192.168.1.100:8000'; // Your actual IP
  static const String localBaseUrl = 'http://localhost:8000'; // For testing

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
