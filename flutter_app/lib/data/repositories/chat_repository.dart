import '../models/chat_models.dart';
import '../../core/network/api_client.dart';
import '../../core/services/storage_service.dart';

class ChatRepository {
  final ApiClient _apiClient;

  // 🔧 EASY SWITCH: Change this to false when your backend chat history endpoints are ready
  static const bool _useMockChatHistory = true;

  ChatRepository(this._apiClient);

  String? _getAuthToken() {
    final token = StorageService.getToken();
    if (token == null) throw Exception('No authentication token found');
    return token;
  }

  Future<List<Chat>> getChats() async {
    try {
      // For now, return mock data instead of API call
      // TODO: Uncomment below when backend is ready
      // _getAuthToken(); // Verify token exists
      // final response = await _apiClient.get('/chats/getChats');
      // if (response.data['chats'] != null) {
      //   return (response.data['chats'] as List)
      //       .map((chat) => Chat.fromJson(chat))
      //       .toList();
      // }

      // Mock data for testing
      return [
        Chat(
          id: '1',
          userId: 'user123',
          title: 'Family Helper Chat',
          messages: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Error loading chats: ${e.toString()}');
    }
  }

  Future<Chat> createChat({required String title}) async {
    try {
      // Mock chat creation for testing
      // TODO: Uncomment below when backend is ready
      _getAuthToken(); // Verify token exists
      final response = await _apiClient.post(
        '/chats/createChat',
        data: {'title': title},
      );
      return Chat.fromJson(response.data['chat']);

      // Mock response - create a new chat
      // return Chat(
      //   id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      //   userId: 'user123',
      //   title: title,
      //   messages: [],
      //   createdAt: DateTime.now(),
      //   updatedAt: DateTime.now(),
      // );
    } catch (e) {
      throw Exception('Error creating chat: ${e.toString()}');
    }
  }

  Future<String> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      //Mock response for testing (since AI API key is paused)
      //TODO: Uncomment below when backend is ready and AI key is active
      _getAuthToken(); // Verify token exists
      final response = await _apiClient.post(
        '/chats/sendMessage',
        data: {'chatId': chatId, 'message': message},
      );
      return response.data['response'] ?? 'Sorry, I couldn\'t process that request.';

      // Mock response for testing
      // await Future.delayed(const Duration(seconds: 1)); // Simulate API delay
      // if (message.toLowerCase().contains('hello')) {
      //   return 'Hello! 👋 I\'m your family helper. How can I assist you today?';
      // } else if (message.toLowerCase().contains('help')) {
      //   return 'I\'m here to help! I can assist with homework, creative activities, recipes, and much more. What would you like to explore?';
      // } else {
      //   return 'That\'s interesting! I\'d love to help you with that. Currently, my AI features are being updated, but I\'ll be back with full capabilities soon! 🚀';
      // }
    } catch (e) {
      throw Exception('Error sending message: ${e.toString()}');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      _getAuthToken(); // Verify token exists

      await _apiClient.delete('/chats/deleteChat/$chatId');
    } catch (e) {
      throw Exception('Error deleting chat: ${e.toString()}');
    }
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    try {
      _getAuthToken(); // Verify token exists

      await _apiClient.put(
        '/chats/renameChat',
        data: {'chatId': chatId, 'title': newTitle},
      );
    } catch (e) {
      throw Exception('Error renaming chat: ${e.toString()}');
    }
  }

  // AI Helper Methods matching your backend
  Future<String> generateGrowthPlans() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateGrowthPlans');
      return response.data['plan'] ?? '';
    } catch (e) {
      throw Exception('Error generating growth plans: ${e.toString()}');
    }
  }

  Future<String> generateLearningZone() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateLearningZone');
      return response.data['learningZone'] ?? '';
    } catch (e) {
      throw Exception('Error generating learning zone: ${e.toString()}');
    }
  }

  Future<String> generateTrackDay() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateTrackDay');
      return response.data['dailySummary'] ?? '';
    } catch (e) {
      throw Exception('Error generating track day: ${e.toString()}');
    }
  }

  Future<String> generateStory() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateStory');
      return response.data['story'] ?? '';
    } catch (e) {
      throw Exception('Error generating story: ${e.toString()}');
    }
  }

  Future<String> generateViewTasks() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateViewTasks');
      return response.data['viewTasks'] ?? '';
    } catch (e) {
      throw Exception('Error generating view tasks: ${e.toString()}');
    }
  }

  Future<Map<String, String>> generateQuickTips() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateQuickTips');
      final quickTip = response.data['quickTip'];
      return {
        'title': quickTip['title'] ?? '',
        'message': quickTip['message'] ?? '',
      };
    } catch (e) {
      throw Exception('Error generating quick tips: ${e.toString()}');
    }
  }

  Future<String> generateTaskCompletionQuestion(String taskDescription) async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post(
        '/ai/generateTaskCompletionQuestion',
        data: {'taskDescription': taskDescription},
      );
      return response.data['question'] ?? '';
    } catch (e) {
      throw Exception('Error generating question: ${e.toString()}');
    }
  }

  Future<bool> checkQuestionCompletion(
    String question,
    String userAnswer,
  ) async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post(
        '/ai/checkQuestionCompletion',
        data: {'question': question, 'userAnswer': userAnswer},
      );
      return response.data['questionAnswered'] ?? false;
    } catch (e) {
      throw Exception('Error checking completion: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> generateDailyAdventure() async {
    try {
      _getAuthToken(); // Verify token exists

      final response = await _apiClient.post('/ai/generateDailyAdventure');
      return response.data['adventure'] ?? {};
    } catch (e) {
      throw Exception('Error generating adventure: ${e.toString()}');
    }
  }

  // New Chat History Methods with Filters
  Future<ChatHistoryResponse> getChatHistoryByFilter(
    ChatHistoryFilter filter,
  ) async {
    try {
      if (_useMockChatHistory) {
        return _getMockChatHistory(filter);
      } else {
        // Real API call
        _getAuthToken(); // Verify token exists
        final response = await _apiClient.get(filter.apiEndpoint);
        return ChatHistoryResponse.fromJson(response.data);
      }
    } catch (e) {
      return ChatHistoryResponse.error(
        'Error loading chat history: ${e.toString()}',
      );
    }
  }

  ChatHistoryResponse _getMockChatHistory(ChatHistoryFilter filter) {
    final now = DateTime.now();

    switch (filter) {
      case ChatHistoryFilter.today:
        return ChatHistoryResponse.success([
          Chat(
            id: 'today_1',
            userId: 'user123',
            title: 'Morning Homework Help',
            messages: [
              ChatMessage(
                message: 'Can you help me with math?',
                sender: 'user',
                timestamp: now.subtract(const Duration(hours: 2)),
              ),
              ChatMessage(
                message:
                    'Of course! I\'d love to help with math. What topic are you working on?',
                sender: 'bot',
                timestamp: now.subtract(const Duration(hours: 2, minutes: 1)),
              ),
            ],
            createdAt: now.subtract(const Duration(hours: 3)),
            updatedAt: now.subtract(const Duration(hours: 2)),
          ),
          Chat(
            id: 'today_2',
            userId: 'user123',
            title: 'Creative Activities',
            messages: [
              ChatMessage(
                message: 'What creative activities can we do today?',
                sender: 'user',
                timestamp: now.subtract(const Duration(minutes: 30)),
              ),
              ChatMessage(
                message:
                    '🎨 Here are some fun creative activities for kids:\n\n• Art & Crafts: Make paper plate masks\n• Nature Projects: Collect leaves and make collages',
                sender: 'bot',
                timestamp: now.subtract(const Duration(minutes: 29)),
              ),
            ],
            createdAt: now.subtract(const Duration(hours: 1)),
            updatedAt: now.subtract(const Duration(minutes: 29)),
          ),
        ]);

      case ChatHistoryFilter.lastWeek:
        return ChatHistoryResponse.success([
          Chat(
            id: 'week_1',
            userId: 'user123',
            title: 'Science Project Help',
            messages: [
              ChatMessage(
                message: 'Need help with volcano experiment',
                sender: 'user',
                timestamp: now.subtract(const Duration(days: 3)),
              ),
            ],
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 3)),
          ),
          Chat(
            id: 'week_2',
            userId: 'user123',
            title: 'Recipe Planning',
            messages: [
              ChatMessage(
                message: 'Easy recipes for kids?',
                sender: 'user',
                timestamp: now.subtract(const Duration(days: 5)),
              ),
            ],
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 5)),
          ),
        ]);

      case ChatHistoryFilter.lastMonth:
        return ChatHistoryResponse.success([
          Chat(
            id: 'month_1',
            userId: 'user123',
            title: 'Reading Comprehension',
            messages: [
              ChatMessage(
                message: 'Help with reading questions',
                sender: 'user',
                timestamp: now.subtract(const Duration(days: 15)),
              ),
            ],
            createdAt: now.subtract(const Duration(days: 15)),
            updatedAt: now.subtract(const Duration(days: 15)),
          ),
          Chat(
            id: 'month_2',
            userId: 'user123',
            title: 'Planning Activities',
            messages: [
              ChatMessage(
                message: 'How to organize daily activities?',
                sender: 'user',
                timestamp: now.subtract(const Duration(days: 20)),
              ),
            ],
            createdAt: now.subtract(const Duration(days: 20)),
            updatedAt: now.subtract(const Duration(days: 20)),
          ),
        ]);
    }
  }
}
