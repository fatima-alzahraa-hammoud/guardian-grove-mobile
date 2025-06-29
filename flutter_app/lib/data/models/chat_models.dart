class ChatMessage {
  final String? id;
  final String message;
  final String? image;
  final String sender; // 'user' or 'bot'
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    this.id,
    required this.message,
    this.image,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
  });

  bool get isUser => sender == 'user';

  factory ChatMessage.user(String content) {
    return ChatMessage(
      message: content,
      sender: 'user',
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.bot(String content) {
    return ChatMessage(
      message: content,
      sender: 'bot',
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      message: '',
      sender: 'bot',
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      message: json['message'] ?? '',
      image: json['image'],
      sender: json['sender'] ?? 'bot',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'message': message,
      if (image != null) 'image': image,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class Chat {
  final String id;
  final String userId;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isResponding;

  Chat({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.isResponding = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'New Chat',
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((message) => ChatMessage.fromJson(message))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isResponding: json['isResponding'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'messages': messages.map((message) => message.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isResponding': isResponding,
    };
  }

  Chat copyWith({
    String? id,
    String? userId,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isResponding,
  }) {
    return Chat(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isResponding: isResponding ?? this.isResponding,
    );
  }
}

// Chat Request Model for API calls
class ChatRequest {
  final String message;
  final String? chatId;
  final Map<String, dynamic>? metadata;

  ChatRequest({required this.message, this.chatId, this.metadata});

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (chatId != null) 'chatId': chatId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      message: json['message'] ?? '',
      chatId: json['chatId'],
      metadata: json['metadata'],
    );
  }
}

// Chat Response Model for API responses
class ChatResponse {
  final String message;
  final bool success;
  final String? error;
  final String? chatId;
  final Map<String, dynamic>? metadata;

  ChatResponse({
    required this.message,
    this.success = true,
    this.error,
    this.chatId,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      if (error != null) 'error': error,
      if (chatId != null) 'chatId': chatId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? true,
      error: json['error'],
      chatId: json['chatId'],
      metadata: json['metadata'],
    );
  }

  // Factory constructor for error responses
  factory ChatResponse.error(String errorMessage) {
    return ChatResponse(message: '', success: false, error: errorMessage);
  }

  // Factory constructor for successful responses
  factory ChatResponse.success(String message, {String? chatId}) {
    return ChatResponse(message: message, success: true, chatId: chatId);
  }
}

// Chat History Filter Types
enum ChatHistoryFilter {
  today,
  lastWeek,
  lastMonth;

  String get displayName {
    switch (this) {
      case ChatHistoryFilter.today:
        return 'Today';
      case ChatHistoryFilter.lastWeek:
        return 'Last 7 Days';
      case ChatHistoryFilter.lastMonth:
        return 'Last 30 Days';
    }
  }

  String get apiEndpoint {
    switch (this) {
      case ChatHistoryFilter.today:
        return '/chats/history/today';
      case ChatHistoryFilter.lastWeek:
        return '/chats/history/week';
      case ChatHistoryFilter.lastMonth:
        return '/chats/history/month';
    }
  }
}

// Chat History Response Model
class ChatHistoryResponse {
  final List<Chat> chats;
  final bool success;
  final String? error;

  ChatHistoryResponse({required this.chats, required this.success, this.error});

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      chats:
          json['chats'] != null
              ? (json['chats'] as List)
                  .map((chat) => Chat.fromJson(chat))
                  .toList()
              : [],
      success: json['success'] ?? false,
      error: json['error'],
    );
  }

  factory ChatHistoryResponse.success(List<Chat> chats) {
    return ChatHistoryResponse(chats: chats, success: true);
  }

  factory ChatHistoryResponse.error(String error) {
    return ChatHistoryResponse(chats: [], success: false, error: error);
  }
}
