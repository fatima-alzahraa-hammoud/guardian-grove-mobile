// TODO: Uncomment when real API calls are enabled
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/chat_models.dart';

abstract class ChatService {
  Future<ChatResponse> sendMessage(ChatRequest request);
}

class ChatServiceImpl implements ChatService {
  final ApiClient _apiClient;

  // 🔧 EASY SWITCH: Change this to false when your backend /ai/chat endpoint is ready
  static const bool useMockData = true;

  ChatServiceImpl(this._apiClient);
  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    if (useMockData) {
      // MOCK MODE: Return mock responses
      await Future.delayed(const Duration(milliseconds: 800));
      String mockResponse = _generateMockResponse(request.message);
      return ChatResponse(message: mockResponse, success: true, error: null);
    } else {
      // REAL API MODE: Call backend
      try {
        final response = await _apiClient.post(
          '/ai/chat',
          data: request.toJson(),
        );
        return ChatResponse.fromJson(response.data);
      } on DioException catch (e) {
        return ChatResponse(
          message: '',
          success: false,
          error: _handleDioError(e),
        );
      } catch (e) {
        return ChatResponse(
          message: '',
          success: false,
          error: 'An unexpected error occurred: $e',
        );
      }
    }
  }

  String _generateMockResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('creative') || message.contains('activities')) {
      return "🎨 Here are some fun creative activities for kids:\n\n"
          "• Art & Crafts: Make paper plate masks or finger painting\n"
          "• Nature Projects: Collect leaves and make collages\n"
          "• Building: Create forts with pillows and blankets\n"
          "• Science Fun: Make slime or volcano experiments\n\n"
          "Would you like detailed instructions for any of these?";
    }

    if (message.contains('homework') || message.contains('study')) {
      return "📚 I'd be happy to help with homework! I can assist with:\n\n"
          "• Math problems and explanations\n"
          "• Reading comprehension\n"
          "• Science concepts\n"
          "• Writing and grammar\n"
          "• Study techniques\n\n"
          "What subject are you working on today?";
    }

    if (message.contains('recipe') ||
        message.contains('food') ||
        message.contains('cook')) {
      return "🍳 Here are some easy family-friendly recipes:\n\n"
          "• Mini Pizzas: English muffins + sauce + cheese\n"
          "• Smoothie Bowls: Frozen fruit + yogurt + toppings\n"
          "• Pasta Salad: Pasta + veggies + simple dressing\n"
          "• Healthy Snacks: Apple slices with peanut butter\n\n"
          "Would you like a full recipe for any of these?";
    }

    if (message.contains('planning') || message.contains('organize')) {
      return "🎯 Great! Let's organize your day effectively:\n\n"
          "• Morning routine: Set priorities for the day\n"
          "• Time blocks: Divide tasks into manageable chunks\n"
          "• Family time: Schedule fun activities together\n"
          "• Evening wrap-up: Prepare for tomorrow\n\n"
          "What's your biggest challenge with daily planning?";
    }

    if (message.contains('games') ||
        message.contains('fun') ||
        message.contains('play')) {
      return "🎪 Here are some awesome games to play:\n\n"
          "• Indoor: Hide and seek, charades, board games\n"
          "• Outdoor: Tag, scavenger hunts, nature walks\n"
          "• Educational: Math bingo, spelling games\n"
          "• Creative: Story building, drawing games\n\n"
          "How many people will be playing?";
    }

    // Default responses for general conversation
    final responses = [
      "That's interesting! Tell me more about what you're thinking.",
      "I'm here to help! What would you like to explore together?",
      "Great question! Let me think about the best way to help with that.",
      "I love chatting with you! What's on your mind today?",
      "That sounds fun! How can I assist you with that?",
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        }
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your connection.';
      default:
        return 'Network error. Please try again.';
    }
  }
}
