import 'package:equatable/equatable.dart';
import '../../../data/models/chat_models.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? activeChatId;  // ADDED: Missing property
  final List<Chat> chatHistory; // ADDED: Missing property
  final bool historyLoaded;     // ADDED: Missing property

  const ChatLoaded({
    required this.messages,
    this.isLoading = false,
    this.activeChatId,          // ADDED
    this.chatHistory = const [], // ADDED
    this.historyLoaded = false,  // ADDED
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? activeChatId,        // ADDED
    List<Chat>? chatHistory,     // ADDED
    bool? historyLoaded,         // ADDED
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      activeChatId: activeChatId ?? this.activeChatId,           // ADDED
      chatHistory: chatHistory ?? this.chatHistory,             // ADDED
      historyLoaded: historyLoaded ?? this.historyLoaded,       // ADDED
    );
  }

  @override
  List<Object> get props => [
    messages, 
    isLoading, 
    activeChatId ?? '',  // ADDED
    chatHistory,         // ADDED
    historyLoaded        // ADDED
  ];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}