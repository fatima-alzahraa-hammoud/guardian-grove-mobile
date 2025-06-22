class ApiConstants {
  // Base URL for your API - update this to match your backend
  // static const String baseUrl = 'https://your-api-domain.com/api';

  // Development/Local URL - aligned with AppConstants for consistency
  // Use 10.0.2.2 for Android emulator, or your computer's IP for real device
  static const String baseUrl = 'http://10.0.2.2:8000';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // Chat endpoints
  static const String chatsEndpoint = '/chats';
  static const String getChatsEndpoint = '/chats/getChats';
  static const String createChatEndpoint = '/chats/createChat';
  static const String sendMessageEndpoint = '/chats/sendMessage';
  static const String deleteChatEndpoint = '/chats/deleteChat';
  static const String renameChatEndpoint = '/chats/renameChat';

  // AI endpoints
  static const String aiEndpoint = '/ai';
  static const String generateGrowthPlansEndpoint = '/ai/generateGrowthPlans';
  static const String generateLearningZoneEndpoint = '/ai/generateLearningZone';
  static const String generateTrackDayEndpoint = '/ai/generateTrackDay';
  static const String generateStoryEndpoint = '/ai/generateStory';
  static const String generateViewTasksEndpoint = '/ai/generateViewTasks';
  static const String generateQuickTipsEndpoint = '/ai/generateQuickTips';
  static const String generateTaskCompletionQuestionEndpoint =
      '/ai/generateTaskCompletionQuestion';
  static const String checkQuestionCompletionEndpoint =
      '/ai/checkQuestionCompletion';
  static const String generateDailyAdventureEndpoint =
      '/ai/generateDailyAdventure';

  // User endpoints
  static const String userEndpoint = '/users';
  static const String profileEndpoint = '/users/profile';

  // Family/Child endpoints
  static const String familyEndpoint = '/family';
  static const String childrenEndpoint = '/family/children';

  // Task endpoints
  static const String tasksEndpoint = '/tasks';

  // Activity endpoints
  static const String activitiesEndpoint = '/activities';

  // Leaderboard endpoints
  static const String leaderboardEndpoint = '/leaderboard';

  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;

  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
}
