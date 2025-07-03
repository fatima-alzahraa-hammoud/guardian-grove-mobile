import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/chat_models.dart';

abstract class ChatService {
  Future<ChatResponse> sendMessage(ChatRequest request);
  Future<List<Chat>> getChats();
  Future<Chat?> getChatById(String chatId); // NEW: Get specific chat by ID
  Future<Chat?> createNewChat({String? firstMessage});
  Future<bool> deleteChat(String chatId);
  Future<bool> renameChat(String chatId, String newTitle);

  // AI Feature Methods
  Future<String> generateGrowthPlans();
  Future<String> generateLearningZone();
  Future<String> generateTrackDay();
  Future<String> generateStory();
  Future<String> generateViewTasks();
  Future<Map<String, String>> generateQuickTip();
}

class ChatServiceImpl implements ChatService {
  final ApiClient _apiClient;

  // 🔧 EASY SWITCH: Change this to false when you want to use real backend
  static const bool useMockData = false; // Changed to false to use real API

  ChatServiceImpl(this._apiClient);

  @override
  Future<ChatResponse> sendMessage(ChatRequest request) async {
    if (useMockData) {
      // MOCK MODE: Return mock responses
      await Future.delayed(const Duration(milliseconds: 800));
      String mockResponse = _generateMockResponse(request.message);
      return ChatResponse(message: mockResponse, success: true, error: null);
    } else {
      // REAL API MODE: Call your actual backend
      try {
        // Step 1: Create new chat if no chatId provided
        String? chatId = request.chatId;

        if (chatId == null || chatId.isEmpty) {
          final newChatResponse = await _apiClient.post(
            '/chats/',
            data: {'sender': 'user', 'message': request.message},
          );

          if (newChatResponse.statusCode == 200) {
            final newChat = Chat.fromJson(newChatResponse.data['chat']);
            chatId = newChat.id;
          } else {
            throw Exception('Failed to create new chat');
          }
        }

        // Step 2: Send message to existing chat
        final response = await _apiClient.post(
          '/chats/handle',
          data: {
            'chatId': chatId,
            'message': request.message,
            'sender': 'user',
            'isCall': request.metadata?['isCall'] ?? false,
          },
        );

        if (response.statusCode == 200) {
          final responseData = response.data;

          return ChatResponse(
            message:
                responseData['aiResponse']?['content'] ??
                'No response received',
            success: true,
            chatId: chatId,
            metadata: {
              'chat': responseData['chat'],
              'sendedMessage': responseData['sendedMessage'],
              if (responseData['audio'] != null) 'audio': responseData['audio'],
            },
          );
        } else {
          throw Exception('Failed to send message: ${response.statusCode}');
        }
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

  @override
  Future<List<Chat>> getChats() async {
    if (useMockData) {
      // Return mock chats
      return [
        Chat(
          id: '1',
          userId: 'user123',
          title: 'Welcome Chat',
          messages: [
            ChatMessage.bot(
              "Welcome to Guardian Grove! 🌳💚 I'm your family's AI helper!",
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      ];
    } else {
      try {
        final response = await _apiClient.get('/chats/getChats');

        if (response.statusCode == 200) {
          final responseData = response.data;

          List<dynamic> chatsData = [];
          if (responseData['chats'] != null) {
            chatsData = responseData['chats'];
          } else if (responseData is List) {
            chatsData = responseData;
          }

          return chatsData.map((chatData) => Chat.fromJson(chatData)).toList();
        } else {
          return [];
        }
      } catch (e) {
        throw Exception('Error getting chats: $e');
      }
    }
  }

  @override
  Future<Chat?> getChatById(String chatId) async {
    if (useMockData) {
      // Return mock chat
      return Chat(
        id: chatId,
        userId: 'user123',
        title: 'Mock Chat',
        messages: [ChatMessage.bot("This is a mock chat with ID: $chatId")],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      );
    } else {
      try {
        final response = await _apiClient.post(
          '/chats/getChatById',
          data: {'chatId': chatId},
        );

        if (response.statusCode == 200) {
          final responseData = response.data;

          if (responseData['chat'] != null) {
            return Chat.fromJson(responseData['chat']);
          }
        }
        return null;
      } catch (e) {
        throw Exception('Error getting chat by ID: $e');
      }
    }
  }

  @override
  Future<Chat?> createNewChat({String? firstMessage}) async {
    if (useMockData) {
      return Chat(
        id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user123',
        title: 'New Chat',
        messages: firstMessage != null ? [ChatMessage.user(firstMessage)] : [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      try {
        final response = await _apiClient.post(
          '/chats/',
          data: {'sender': 'user', 'message': firstMessage ?? 'Hello!'},
        );

        if (response.statusCode == 200) {
          return Chat.fromJson(response.data['chat']);
        } else {
          return null;
        }
      } catch (e) {
        throw Exception('Error creating chat: $e');
      }
    }
  }

  @override
  Future<bool> deleteChat(String chatId) async {
    if (useMockData) {
      return true; // Mock success
    } else {
      try {
        final response = await _apiClient.delete(
          '/chats/',
          data: {'chatId': chatId},
        );
        return response.statusCode == 200;
      } catch (e) {
        throw Exception('Error deleting chat: $e');
      }
    }
  }

  @override
  Future<bool> renameChat(String chatId, String newTitle) async {
    if (useMockData) {
      return true; // Mock success
    } else {
      try {
        final response = await _apiClient.put(
          '/chats/rename',
          data: {'chatId': chatId, 'title': newTitle},
        );
        return response.statusCode == 200;
      } catch (e) {
        throw Exception('Error renaming chat: $e');
      }
    }
  }

  // AI Feature Methods
  @override
  Future<String> generateGrowthPlans() async {
    if (useMockData) {
      return "🎯 **Personal Growth Plan**\n\n**Short-term Goals:**\n• Complete daily reading for 20 minutes\n• Practice math skills 3x per week\n• Try one new creative activity\n\n**Long-term Goals:**\n• Improve problem-solving skills\n• Build confidence in learning\n• Develop healthy habits";
    } else {
      try {
        final userResponse = await _apiClient.get('/users/user');
        final userData = userResponse.data['user'] ?? userResponse.data;
        final userId = userData['_id'];

        final response = await _apiClient.post(
          '/users/generatePlan',
          data: {'userId': userId},
        );

        if (response.statusCode == 200) {
          return response.data['plan'] ?? 'No plan generated';
        } else {
          throw Exception('Failed to generate growth plans');
        }
      } catch (e) {
        throw Exception('Error generating growth plans: $e');
      }
    }
  }

  @override
  Future<String> generateLearningZone() async {
    if (useMockData) {
      return "📚 **Your Learning Zone**\n\n**Recommended Activities:**\n• Interactive science experiments\n• Creative writing exercises\n• Math puzzle games\n• Art and craft projects\n\n**Learning Schedule:**\n• Morning: Reading time\n• Afternoon: Creative activities\n• Evening: Review and planning";
    } else {
      try {
        final userResponse = await _apiClient.get('/users/user');
        final userData = userResponse.data['user'] ?? userResponse.data;
        final userId = userData['_id'];

        final response = await _apiClient.post(
          '/users/generateLearningZone',
          data: {'userId': userId},
        );

        if (response.statusCode == 200) {
          return response.data['learningZone'] ?? 'No learning zone generated';
        } else {
          throw Exception('Failed to generate learning zone');
        }
      } catch (e) {
        throw Exception('Error generating learning zone: $e');
      }
    }
  }

  @override
  Future<String> generateTrackDay() async {
    if (useMockData) {
      return "📊 **Daily Progress Summary**\n\n**Today's Achievements:**\n• ✅ Completed 2 tasks\n• ⭐ Earned 15 stars\n• 🎯 Met daily goals\n\n**Statistics:**\n• Tasks completed: 2/3\n• Time spent learning: 45 minutes\n• Achievements unlocked: 1\n\n**Great job today! Keep up the excellent work! 🌟**";
    } else {
      try {
        final userResponse = await _apiClient.get('/users/user');
        final userData = userResponse.data['user'] ?? userResponse.data;
        final userId = userData['_id'];

        final response = await _apiClient.post(
          '/users/generateTrackDay',
          data: {'userId': userId},
        );

        if (response.statusCode == 200) {
          return response.data['dailySummary'] ?? 'No daily summary generated';
        } else {
          throw Exception('Failed to generate track day');
        }
      } catch (e) {
        throw Exception('Error generating track day: $e');
      }
    }
  }

  @override
  Future<String> generateStory() async {
    if (useMockData) {
      return "📖 **The Magic Learning Tree**\n\nOnce upon a time, in a magical forest, there grew a special tree that loved to help children learn and grow. This tree had branches that sparkled with knowledge and leaves that whispered encouraging words.\n\nEvery day, children would visit the tree to share their dreams and challenges. The tree would listen carefully and offer wisdom to help them succeed.\n\nWhat adventures will you have today? 🌳✨";
    } else {
      try {
        final userResponse = await _apiClient.get('/users/user');
        final userData = userResponse.data['user'] ?? userResponse.data;
        final userId = userData['_id'];

        final response = await _apiClient.post(
          '/users/generateStory',
          data: {'userId': userId},
        );

        if (response.statusCode == 200) {
          return response.data['story'] ?? 'No story generated';
        } else {
          throw Exception('Failed to generate story');
        }
      } catch (e) {
        throw Exception('Error generating story: $e');
      }
    }
  }

  @override
  Future<String> generateViewTasks() async {
    if (useMockData) {
      return "📝 **Your Task Dashboard**\n\n**Current Tasks:**\n• 📚 Complete reading assignment\n• 🔢 Practice multiplication tables\n• 🎨 Finish art project\n\n**Completed Today:**\n• ✅ Math homework\n• ✅ Science experiment\n\n**Tips for Success:**\n• Break tasks into smaller steps\n• Take breaks when needed\n• Celebrate your progress! 🎉";
    } else {
      try {
        final userResponse = await _apiClient.get('/users/user');
        final userData = userResponse.data['user'] ?? userResponse.data;
        final userId = userData['_id'];

        final response = await _apiClient.post(
          '/users/generateViewTasks',
          data: {'userId': userId},
        );

        if (response.statusCode == 200) {
          return response.data['viewTasks'] ?? 'No tasks generated';
        } else {
          throw Exception('Failed to generate view tasks');
        }
      } catch (e) {
        throw Exception('Error generating view tasks: $e');
      }
    }
  }

  @override
  Future<Map<String, String>> generateQuickTip() async {
    if (useMockData) {
      return {
        'title': 'Stay Curious!',
        'message':
            'Ask questions about everything around you - curiosity is the key to learning! 🔍✨',
      };
    } else {
      try {
        final userResponse = await _apiClient.get('/users/user');
        final userData = userResponse.data['user'] ?? userResponse.data;
        final userId = userData['_id'];

        final response = await _apiClient.post(
          '/users/generateQuickTip',
          data: {'userId': userId},
        );

        if (response.statusCode == 200) {
          final quickTip = response.data['quickTip'];
          return {
            'title': quickTip['title'] ?? 'Quick Tip',
            'message': quickTip['message'] ?? 'No tip generated',
          };
        } else {
          throw Exception('Failed to generate quick tip');
        }
      } catch (e) {
        throw Exception('Error generating quick tip: $e');
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
