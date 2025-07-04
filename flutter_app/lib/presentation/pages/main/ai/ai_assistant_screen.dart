import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/chat_models.dart'; // Added for Chat model
import '../../../../injection_container.dart' as di;
import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../widgets/chat_message_widget.dart';
import '../../../widgets/chat_input_widget.dart';
import 'chat_history_screen.dart';

class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ChatBloc>()..add(ChatInitialized()),
      child: const AIAssistantView(),
    );
  }
}

class AIAssistantView extends StatefulWidget {
  const AIAssistantView({super.key});

  @override
  State<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends State<AIAssistantView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.childishGradient),
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded && state.messages.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                  }
                  if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatInitial) {
                    return _buildLoadingState();
                  }
                  if (state is ChatLoaded) {
                    return _buildChatContent(state);
                  }
                  if (state is ChatError) {
                    return _buildErrorState(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          // AI Icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.android_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Family Helper AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your friendly AI companion 🤖✨',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // New Chat Button
          GestureDetector(
            onTap: () => context.read<ChatBloc>().add(ChatCleared()),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // History Button
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () async {
                  // Navigate to chat history and wait for result
                  final selectedChat = await Navigator.of(context).push<Chat>(
                    MaterialPageRoute(
                      builder: (context) => const ChatHistoryScreen(),
                    ),
                  );

                  // If a chat was selected, load it
                  if (selectedChat != null && context.mounted) {
                    context.read<ChatBloc>().add(
                      ChatSpecificLoaded(selectedChat.id),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (0.1 * _pulseController.value),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.android_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Getting ready to help! 🚀',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Just a moment while I prepare...',
              style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATE: Your AIAssistantScreen _buildChatContent method to include the end chat callback

  Widget _buildChatContent(ChatLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Show suggestion cards only when no conversation started
          if (state.messages.length <= 1) ...[
            Expanded(child: _buildWelcomeContent()),
          ] else ...[
            // NEW: Add chat header with save/end options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_rounded,
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active Chat (${state.messages.length} messages)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                  // End Chat Button
                  TextButton.icon(
                    onPressed: () => _endCurrentChat(),
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('End & Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Show chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageWidget(message: state.messages[index]);
                },
              ),
            ),
          ],

          // Input with end chat functionality
          ChatInputWidget(
            onMessageSent: (message) {
              context.read<ChatBloc>().add(ChatMessageSent(message));
            },
            isLoading: state.isLoading,
            onNewChat: () => _startNewChat(), // NEW: Start new chat
            onEndChat: () => _endCurrentChat(), // NEW: End current chat
          ),
        ],
      ),
    );
  }

  // REPLACE the end chat methods in your AIAssistantView with these fixed versions:

  void _startNewChat() {
    // Clear current chat and start fresh
    context.read<ChatBloc>().add(ChatCleared());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.add_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('New chat started!'),
          ],
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _endCurrentChat() {
    // FIXED: First save the current chat, then clear
    _saveChatToHistory();

    // Then clear the current chat immediately
    context.read<ChatBloc>().add(ChatCleared());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Chat saved and cleared!'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // NEW: Method to actually save the chat to history
  void _saveChatToHistory() {
    final currentState = context.read<ChatBloc>().state;
    if (currentState is ChatLoaded && currentState.messages.isNotEmpty) {
      // The chat will be automatically saved when ChatCleared is called
      // because the BLoC should handle saving the current chat state

      debugPrint(
        '💾 Saving chat with ${currentState.messages.length} messages to history',
      );
    }
  }

  Widget _buildWelcomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Welcome Robot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -5 * _pulseController.value),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.sunsetGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Hello there! 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            'I\'m your family\'s AI helper, ready to assist with anything you need!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGray,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // AI FEATURE BUTTONS (connects to your backend)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withValues(alpha: 0.1),
                  AppColors.primaryGreen.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '🌟 AI Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    _buildFeatureCard(
                      '🎯',
                      'Growth Plans',
                      'Personal development',
                      AIFeatureType.growthPlans,
                    ),
                    _buildFeatureCard(
                      '📚',
                      'Learning Zone',
                      'Educational activities',
                      AIFeatureType.learningZone,
                    ),
                    _buildFeatureCard(
                      '📊',
                      'Track My Day',
                      'Daily progress',
                      AIFeatureType.trackDay,
                    ),
                    _buildFeatureCard(
                      '📖',
                      'Tell Story',
                      'Fun stories',
                      AIFeatureType.story,
                    ),
                    _buildFeatureCard(
                      '📝',
                      'View Tasks',
                      'Task management',
                      AIFeatureType.viewTasks,
                    ),
                    _buildFeatureCard(
                      '💡',
                      'Quick Tip',
                      'Helpful tips',
                      AIFeatureType.quickTip,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Conversation Starters
          const Text(
            '💭 Quick Conversation Starters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: [
              _buildSuggestionCard(
                '🎨',
                'Creative Ideas',
                'Fun activities for kids',
              ),
              _buildSuggestionCard('📚', 'Homework Help', 'Study assistance'),
              _buildSuggestionCard(
                '🍳',
                'Recipe Ideas',
                'Family meal suggestions',
              ),
              _buildSuggestionCard('🎯', 'Daily Planning', 'Organize your day'),
              _buildSuggestionCard('🎪', 'Fun Games', 'Interactive games'),
              _buildSuggestionCard('💡', 'Random Fun', 'Ask me anything!'),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withValues(alpha: 0.1),
                  AppColors.primaryGreen.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '💭 Start typing below to begin our conversation!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AI Feature Card (connects to backend)
  Widget _buildFeatureCard(
    String emoji,
    String title,
    String subtitle,
    AIFeatureType featureType,
  ) {
    return GestureDetector(
      onTap: () {
        // Trigger AI feature using BLoC event
        context.read<ChatBloc>().add(AIFeatureRequested(featureType));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Conversation Starter Card
  Widget _buildSuggestionCard(String emoji, String title, String subtitle) {
    return GestureDetector(
      onTap: () => _sendSuggestedMessage(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryTeal.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.mediumGray),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _sendSuggestedMessage(String title) {
    String message = '';
    switch (title) {
      case 'Creative Ideas':
        message = 'Can you suggest some fun creative activities for kids?';
        break;
      case 'Homework Help':
        message = 'How can you help me with my homework?';
        break;
      case 'Recipe Ideas':
        message = 'What are some easy and healthy recipes for families?';
        break;
      case 'Daily Planning':
        message = 'Help me plan my day effectively';
        break;
      case 'Fun Games':
        message = 'What are some fun games we can play together?';
        break;
      case 'Random Fun':
        message = 'Tell me something interesting and fun!';
        break;
    }
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(ChatMessageSent(message));
    }
  }

  Widget _buildErrorState(BuildContext context, ChatError state) {
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withValues(alpha: 0.8),
                      AppColors.error.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong 😅',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                state.message,
                style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    () => context.read<ChatBloc>().add(ChatInitialized()),
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
}
