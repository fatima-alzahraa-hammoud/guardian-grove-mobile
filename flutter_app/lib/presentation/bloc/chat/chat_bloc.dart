import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/repositories/chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object> get props => [];
}

class ChatInitialized extends ChatEvent {}

class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
  @override
  List<Object> get props => [message];
}

class ChatCleared extends ChatEvent {}

class ChatHistoryRequested extends ChatEvent {}

class ChatHistoryLoaded extends ChatEvent {
  final List<Chat> chats;
  const ChatHistoryLoaded(this.chats);
  @override
  List<Object> get props => [chats];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? activeChatId;
  final List<Chat> chatHistory;
  final bool historyLoaded;

  const ChatLoaded({
    required this.messages,
    this.isLoading = false,
    this.activeChatId,
    this.chatHistory = const [],
    this.historyLoaded = false,
  });

  @override
  List<Object> get props => [messages, isLoading, chatHistory, historyLoaded];
  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? activeChatId,
    List<Chat>? chatHistory,
    bool? historyLoaded,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      activeChatId: activeChatId ?? this.activeChatId,
      chatHistory: chatHistory ?? this.chatHistory,
      historyLoaded: historyLoaded ?? this.historyLoaded,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  String? _currentChatId;
  List<Chat> _allChats = [];

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<ChatInitialized>(_onChatInitialized);
    on<ChatMessageSent>(_onChatMessageSent);
    on<ChatCleared>(_onChatCleared);
    on<ChatHistoryRequested>(_onChatHistoryRequested);
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

  void _showWelcomeMessage(Emitter<ChatState> emit) {
    final welcomeMessage = ChatMessage.bot(
      "Hello! 👋 I'm your Family Helper AI. I'm here to assist you with anything you need - from homework help to creative ideas, recipes, and fun activities! What would you like to explore today?",
    );
    emit(
      ChatLoaded(
        messages: [welcomeMessage],
        activeChatId: null,
        chatHistory: const [],
        historyLoaded: false,
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

      // Create new chat if needed
      if (_currentChatId == null) {
        final title = _generateChatTitle(event.message);
        final newChat = await _chatRepository.createChat(title: title);
        _currentChatId = newChat.id;
        _allChats.add(newChat);
      }

      // Send message to AI
      final botResponse = await _chatRepository.sendMessage(
        chatId: _currentChatId!,
        message: event.message,
      );

      final botMessage = ChatMessage.bot(botResponse);

      // Update with final messages (remove loading)
      final finalMessages = [...currentState.messages, userMessage, botMessage];

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

      emit(ChatError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onChatCleared(
    ChatCleared event,
    Emitter<ChatState> emit,
  ) async {
    _currentChatId = null;
    _showWelcomeMessage(emit);
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

      emit(currentState.copyWith(chatHistory: chats, historyLoaded: true));
    } catch (e) {
      emit(ChatError('Failed to load chat history: ${e.toString()}'));
    }
  }

  String _generateChatTitle(String message) {
    final words = message.split(' ').take(3).join(' ');
    return words.length > 25 ? '${words.substring(0, 25)}...' : words;
  }
}
