import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Mock Data Models (remove when backend is ready)
class ChatMessage {
  final String id;
  final String senderName;
  final String senderAvatar;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isMuted;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderAvatar,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isMuted = false,
  });
}

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock data - replace with real data when backend is ready
  final List<ChatMessage> _mockChats = [
    ChatMessage(
      id: '1',
      senderName: 'Sarah Johnson',
      senderAvatar: '',
      lastMessage: 'Hey! How are you doing today?',
      time: '09:45 AM',
      unreadCount: 2,
      isOnline: true,
    ),
    ChatMessage(
      id: '2',
      senderName: 'Family Group',
      senderAvatar: '',
      lastMessage: 'Mom: Don\'t forget about dinner tonight!',
      time: '09:30 AM',
      unreadCount: 5,
      isOnline: false,
    ),
    ChatMessage(
      id: '3',
      senderName: 'Mike Chen',
      senderAvatar: '',
      lastMessage: 'Thanks for the help yesterday 👍',
      time: '08:15 AM',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatMessage(
      id: '4',
      senderName: 'Emma Wilson',
      senderAvatar: '',
      lastMessage: 'Can we reschedule our meeting?',
      time: 'Yesterday',
      unreadCount: 1,
      isOnline: false,
    ),
    ChatMessage(
      id: '5',
      senderName: 'Work Team',
      senderAvatar: '',
      lastMessage: 'John: The project is almost done',
      time: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      isMuted: true,
    ),
    ChatMessage(
      id: '6',
      senderName: 'David Brown',
      senderAvatar: '',
      lastMessage: 'See you at the gym!',
      time: 'Tuesday',
      unreadCount: 0,
      isOnline: false,
    ),
    ChatMessage(
      id: '7',
      senderName: 'Lisa Anderson',
      senderAvatar: '',
      lastMessage: 'Happy birthday! 🎉🎂',
      time: 'Monday',
      unreadCount: 0,
      isOnline: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  void _openChat(ChatMessage chat) {
    // Navigate to individual chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${chat.senderName}'),
        backgroundColor: const Color(0xFF0EA5E9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Chat List
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search chats...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 16,
              ),
            )
          : const Text(
              'Messages',
              style: TextStyle(
                color: Color(0xFF1A202C),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0EA5E9)),
              onPressed: _stopSearch,
            )
          : null,
      actions: [
        if (!_isSearching) ...[
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF0EA5E9)),
            onPressed: _startSearch,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0EA5E9)),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildSearchBar() {
    if (_isSearching) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search messages...',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF0EA5E9),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: _mockChats.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final chat = _mockChats[index];
          return _buildChatTile(chat);
        },
      ),
    );
  }

  Widget _buildChatTile(ChatMessage chat) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openChat(chat),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: chat.senderAvatar.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  chat.senderAvatar,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildAvatarFallback(chat.senderName),
                                ),
                              )
                            : _buildAvatarFallback(chat.senderName),
                      ),
                    ),
                    if (chat.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Chat info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.senderName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: chat.unreadCount > 0 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                color: const Color(0xFF1A202C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.isMuted)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.volume_off_rounded,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: chat.unreadCount > 0 
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                          fontWeight: chat.unreadCount > 0 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Time and badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: chat.unreadCount > 0 
                            ? const Color(0xFF0EA5E9)
                            : const Color(0xFF94A3B8),
                        fontWeight: chat.unreadCount > 0 
                            ? FontWeight.w600 
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (chat.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildAvatarFallback(String name) {
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'U',
      style: const TextStyle(
        color: Color(0xFF0EA5E9),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          // Open new chat/contact selection
          _showNewChatOptions();
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start New Chat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 20),
            _buildNewChatOption(
              icon: Icons.person_add_rounded,
              title: 'New Contact',
              subtitle: 'Add someone new to chat with',
              onTap: () => Navigator.pop(context),
            ),
            _buildNewChatOption(
              icon: Icons.group_add_rounded,
              title: 'New Group',
              subtitle: 'Create a group chat',
              onTap: () => Navigator.pop(context),
            ),
            _buildNewChatOption(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan QR Code',
              subtitle: 'Add contact by scanning QR code',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0EA5E9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF94A3B8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Don't forget to add this import at the top of your file:
