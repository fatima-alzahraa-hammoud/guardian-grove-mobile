import '../models/chat_models.dart';
import '../../core/services/chat_service.dart'; // Your existing ChatService
import '../../core/services/storage_service.dart';

class ChatRepository {
  final ChatService _chatService;

  ChatRepository(this._chatService);

  String? _getAuthToken() {
    final token = StorageService.getToken();
    if (token == null) throw Exception('No authentication token found');
    return token;
  }

  Future<List<Chat>> getChats() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.getChats();
    } catch (e) {
      throw Exception('Error loading chats: ${e.toString()}');
    }
  }

  // NEW: Get specific chat by ID
  Future<Chat?> getChatById(String chatId) async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.getChatById(chatId);
    } catch (e) {
      throw Exception('Error loading chat: ${e.toString()}');
    }
  }

  Future<Chat> createChat({required String title, String? firstMessage}) async {
    try {
      _getAuthToken(); // Verify token exists
      final chat = await _chatService.createNewChat(firstMessage: firstMessage);
      if (chat == null) {
        throw Exception('Failed to create chat');
      }
      return chat;
    } catch (e) {
      throw Exception('Error creating chat: ${e.toString()}');
    }
  }

  Future<ChatResponse> sendMessage({
    required String message,
    String? chatId,
    bool isCall = false,
  }) async {
    try {
      _getAuthToken(); // Verify token exists

      final request = ChatRequest(
        message: message,
        chatId: chatId,
        metadata: {'isCall': isCall},
      );

      return await _chatService.sendMessage(request);
    } catch (e) {
      throw Exception('Error sending message: ${e.toString()}');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      _getAuthToken(); // Verify token exists
      final success = await _chatService.deleteChat(chatId);
      if (!success) {
        throw Exception('Failed to delete chat');
      }
    } catch (e) {
      throw Exception('Error deleting chat: ${e.toString()}');
    }
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    try {
      _getAuthToken(); // Verify token exists
      final success = await _chatService.renameChat(chatId, newTitle);
      if (!success) {
        throw Exception('Failed to rename chat');
      }
    } catch (e) {
      throw Exception('Error renaming chat: ${e.toString()}');
    }
  }

  // AI Helper Methods
  Future<String> generateGrowthPlans() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.generateGrowthPlans();
    } catch (e) {
      throw Exception('Error generating growth plans: ${e.toString()}');
    }
  }

  Future<String> generateLearningZone() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.generateLearningZone();
    } catch (e) {
      throw Exception('Error generating learning zone: ${e.toString()}');
    }
  }

  Future<String> generateTrackDay() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.generateTrackDay();
    } catch (e) {
      throw Exception('Error generating track day: ${e.toString()}');
    }
  }

  Future<String> generateStory() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.generateStory();
    } catch (e) {
      throw Exception('Error generating story: ${e.toString()}');
    }
  }

  Future<String> generateViewTasks() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.generateViewTasks();
    } catch (e) {
      throw Exception('Error generating view tasks: ${e.toString()}');
    }
  }

  Future<Map<String, String>> generateQuickTips() async {
    try {
      _getAuthToken(); // Verify token exists
      return await _chatService.generateQuickTip();
    } catch (e) {
      throw Exception('Error generating quick tips: ${e.toString()}');
    }
  }

  // New Chat History Methods with Filters
  Future<ChatHistoryResponse> getChatHistoryByFilter(
    ChatHistoryFilter filter,
  ) async {
    try {
      // For now, just return regular chats and filter them
      final chats = await getChats();
      final filteredChats = _filterChatsByDate(chats, filter);
      return ChatHistoryResponse.success(filteredChats);
    } catch (e) {
      return ChatHistoryResponse.error(
        'Error loading chat history: ${e.toString()}',
      );
    }
  }

  List<Chat> _filterChatsByDate(List<Chat> chats, ChatHistoryFilter filter) {
    final now = DateTime.now();

    return chats.where((chat) {
      switch (filter) {
        case ChatHistoryFilter.today:
          return chat.updatedAt.day == now.day &&
              chat.updatedAt.month == now.month &&
              chat.updatedAt.year == now.year;
        case ChatHistoryFilter.lastWeek:
          return now.difference(chat.updatedAt).inDays <= 7;
        case ChatHistoryFilter.lastMonth:
          return now.difference(chat.updatedAt).inDays <= 30;
      }
    }).toList();
  }
}
