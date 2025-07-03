import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/chat_models.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../injection_container.dart' as di;

// Simple filter enum
enum ChatHistoryFilter {
  all,
  today,
  lastWeek,
  lastMonth;

  String get displayName {
    switch (this) {
      case ChatHistoryFilter.all:
        return 'All';
      case ChatHistoryFilter.today:
        return 'Today';
      case ChatHistoryFilter.lastWeek:
        return 'This Week';
      case ChatHistoryFilter.lastMonth:
        return 'This Month';
    }
  }
}

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ChatRepository _chatRepository = di.sl<ChatRepository>();

  // Store all chats once, then filter locally
  List<Chat> _allChats = [];
  bool _isLoadingAllChats = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load all chats once
    _loadAllChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllChats() async {
    if (_isLoadingAllChats) return;

    setState(() {
      _isLoadingAllChats = true;
      _loadError = null;
    });

    try {
      final allChats = await _chatRepository.getChats();

      setState(() {
        _allChats = allChats;
        _loadError = null;
        _isLoadingAllChats = false;
      });

      debugPrint('📚 Loaded ${allChats.length} total chats');
    } catch (e) {
      setState(() {
        _loadError = 'Error loading chat history: $e';
        _allChats = [];
        _isLoadingAllChats = false;
      });

      debugPrint('❌ Error loading chats: $e');
    }
  }

  // Get filtered chats for current tab
  List<Chat> _getFilteredChats(ChatHistoryFilter filter) {
    if (_allChats.isEmpty) return [];

    final now = DateTime.now();

    switch (filter) {
      case ChatHistoryFilter.all:
        return _allChats;

      case ChatHistoryFilter.today:
        return _allChats.where((chat) {
          final chatDate = chat.updatedAt.toLocal();
          final nowLocal = DateTime.now();
          return chatDate.year == nowLocal.year &&
              chatDate.month == nowLocal.month &&
              chatDate.day == nowLocal.day;
        }).toList();

      case ChatHistoryFilter.lastWeek:
        return _allChats.where((chat) {
          return now.difference(chat.updatedAt).inDays <= 7;
        }).toList();

      case ChatHistoryFilter.lastMonth:
        return _allChats.where((chat) {
          return now.difference(chat.updatedAt).inDays <= 30;
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.childishGradient),
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children:
                    ChatHistoryFilter.values.map((filter) {
                      return _buildChatHistoryTab(filter);
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Chat History Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your previous conversations 💬',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Refresh button
          GestureDetector(
            onTap: _loadAllChats,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _isLoadingAllChats
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryTeal.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryTeal,
        unselectedLabelColor: AppColors.darkGray,
        indicatorColor: AppColors.primaryTeal,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        isScrollable: true,
        tabs:
            ChatHistoryFilter.values.map((filter) {
              final chatCount = _getFilteredChats(filter).length;
              return Tab(
                text:
                    '${filter.displayName}${chatCount > 0 ? ' ($chatCount)' : ''}',
              );
            }).toList(),
      ),
    );
  }

  Widget _buildChatHistoryTab(ChatHistoryFilter filter) {
    if (_isLoadingAllChats) {
      return _buildLoadingState();
    }

    if (_loadError != null) {
      return _buildErrorState(_loadError!, _loadAllChats);
    }

    final chats = _getFilteredChats(filter);

    if (chats.isEmpty) {
      return _buildEmptyState(filter);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadAllChats,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _buildChatItem(chat);
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(Chat chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openChat(chat),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chat.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(chat.updatedAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (chat.messages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    chat.messages.last.message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.message_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${chat.messages.length} messages',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
            ),
            SizedBox(height: 16),
            Text(
              'Loading chat history...',
              style: TextStyle(color: AppColors.darkGray, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ChatHistoryFilter filter) {
    String message = 'No chats yet!';
    String subtitle = 'Start a conversation with your Family Helper AI.';

    if (filter != ChatHistoryFilter.all) {
      message = 'No chats found for ${filter.displayName.toLowerCase()}';
      subtitle = 'Try checking the "All" tab or start a new conversation.';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, color: AppColors.darkGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to AI Assistant
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Start Chatting',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(Chat chat) {
    // Show loading state temporarily
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Loading ${chat.title}...'),
          ],
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );

    // Navigate back to AI assistant screen and pass the chat to load
    Navigator.of(context).pop(chat); // Return the chat to the previous screen
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
