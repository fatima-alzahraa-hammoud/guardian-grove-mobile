import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  String? _currentChatId;
  List<Chat> _allChats = [];

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<ChatInitialized>(_onChatInitialized);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatCleared>(_onChatCleared);
    on<ChatHistoryRequested>(_onChatHistoryRequested);
    on<AIFeatureRequested>(_onAIFeatureRequested); // NEW: AI Features
  }

  Future<void> _onChatInitialized(
    ChatInitialized event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatInitial());

      // Load existing chats from backend
      final chats = await _chatRepository.getChats();
      _allChats = chats;

      if (chats.isNotEmpty) {
        // Use the first available chat
        final firstChat = chats.first;
        _currentChatId = firstChat.id;
        emit(
          ChatLoaded(
            messages: firstChat.messages,
            activeChatId: _currentChatId,
            chatHistory: chats,
            historyLoaded: true,
          ),
        );
      } else {
        // Start with welcome message only
        _showWelcomeMessage(emit);
      }
    } catch (e) {
      emit(ChatError('Failed to initialize chat: ${e.toString()}'));
    }
  }

  // ALSO UPDATE the _showWelcomeMessage to use updated history:
  void _showWelcomeMessage(Emitter<ChatState> emit) {
    final welcomeMessage = ChatMessage.bot(
      "Hello! 👋 I'm your Family Helper AI. I'm here to assist you with anything you need - from homework help to creative ideas, recipes, and fun activities! What would you like to explore today?",
    );
    emit(
      ChatLoaded(
        messages: [welcomeMessage],
        activeChatId: null,
        chatHistory: _allChats, // FIXED: Include updated history
        historyLoaded: true,
      ),
    );
  }

  Future<void> _onChatMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    try {
      // Add user message immediately
      final userMessage = ChatMessage.user(event.message);
      final loadingMessage = ChatMessage.loading();

      final updatedMessages = [
        ...currentState.messages,
        userMessage,
        loadingMessage,
      ];

      emit(currentState.copyWith(messages: updatedMessages, isLoading: true));

      // Send message to AI (the repository will handle chat creation if needed)
      final response = await _chatRepository.sendMessage(
        chatId: _currentChatId,
        message: event.message,
      );

      if (response.success) {
        // Update current chat ID if it was created
        if (response.chatId != null && _currentChatId == null) {
          _currentChatId = response.chatId;
        }

        final botMessage = ChatMessage.bot(response.message);

        // Update with final messages (remove loading)
        final finalMessages = [
          ...currentState.messages,
          userMessage,
          botMessage,
        ];

        emit(
          currentState.copyWith(
            messages: finalMessages,
            isLoading: false,
            activeChatId: _currentChatId,
          ),
        );
      } else {
        throw Exception(response.error ?? 'Failed to get AI response');
      }
    } catch (e) {
      // Remove loading message on error
      final messagesWithoutLoading =
          currentState.messages.where((msg) => !msg.isLoading).toList();

      emit(
        currentState.copyWith(
          messages: messagesWithoutLoading,
          isLoading: false,
        ),
      );

      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  // UPDATE your ChatBloc _onChatCleared method to properly save before clearing:

  // UPDATE your ChatBloc _onChatCleared method to properly save before clearing:

  Future<void> _onChatCleared(
    ChatCleared event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final currentState = state;

      // FIXED: Save current chat to history before clearing (if it has messages)
      if (currentState is ChatLoaded &&
          currentState.messages.isNotEmpty &&
          currentState.messages.length > 1 && // More than just welcome message
          _currentChatId != null) {
        // Debug: Saving current chat to history before clearing
        debugPrint('💾 Saving current chat to history before clearing...');

        // The chat should already be saved in the backend when messages were sent
        // But we can add additional logic here if needed

        // Add the current chat to our local history
        if (!_allChats.any((chat) => chat.id == _currentChatId)) {
          // Create a chat object from current state and add to history
          final currentChat = Chat(
            id: _currentChatId!,
            userId: 'current_user', // You might want to get this from storage
            title: _generateChatTitle(currentState.messages.first.message),
            messages: currentState.messages,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            updatedAt: DateTime.now(),
          );
          _allChats.insert(0, currentChat); // Add to beginning of list
        }
      }

      // Clear current chat state
      _currentChatId = null;

      // Show welcome message for new chat
      _showWelcomeMessage(emit);
    } catch (e) {
      debugPrint('❌ Error during chat clear: $e');
      // Still clear even if save fails
      _currentChatId = null;
      _showWelcomeMessage(emit);
    }
  }

  Future<void> _onChatHistoryRequested(
    ChatHistoryRequested event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    // Only load history if not already loaded
    if (currentState.historyLoaded) return;

    try {
      // Fetch chat history from repository (API call)
      final chats = await _chatRepository.getChats();
      _allChats = chats;

      emit(currentState.copyWith(chatHistory: chats, historyLoaded: true));
    } catch (e) {
      emit(ChatError('Failed to load chat history: ${e.toString()}'));
    }
  }

  // NEW: Handle AI Features
  Future<void> _onAIFeatureRequested(
    AIFeatureRequested event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    try {
      // Add loading message
      final loadingMessage = ChatMessage.loading();
      final updatedMessages = [...currentState.messages, loadingMessage];
      emit(currentState.copyWith(messages: updatedMessages, isLoading: true));

      String response = '';

      // Call the appropriate repository method based on feature type
      switch (event.featureType) {
        case AIFeatureType.growthPlans:
          response = await _chatRepository.generateGrowthPlans();
          break;
        case AIFeatureType.learningZone:
          response = await _chatRepository.generateLearningZone();
          break;
        case AIFeatureType.trackDay:
          response = await _chatRepository.generateTrackDay();
          break;
        case AIFeatureType.story:
          response = await _chatRepository.generateStory();
          break;
        case AIFeatureType.viewTasks:
          response = await _chatRepository.generateViewTasks();
          break;
        case AIFeatureType.quickTip:
          final tipData = await _chatRepository.generateQuickTips();
          response = '💡 **${tipData['title']}**\n\n${tipData['message']}';
          break;
      }

      final botMessage = ChatMessage.bot(response);

      // Remove loading message and add bot response
      final finalMessages = [...currentState.messages, botMessage];

      emit(currentState.copyWith(messages: finalMessages, isLoading: false));
    } catch (e) {
      // Remove loading message on error
      final messagesWithoutLoading =
          currentState.messages.where((msg) => !msg.isLoading).toList();

      emit(
        currentState.copyWith(
          messages: messagesWithoutLoading,
          isLoading: false,
        ),
      );

      emit(
        ChatError(
          'Failed to generate ${event.featureType.name}: ${e.toString()}',
        ),
      );
    }
  }

  String _generateChatTitle(String message) {
    final words = message.split(' ').take(3).join(' ');
    return words.length > 25 ? '${words.substring(0, 25)}...' : words;
  }
}
