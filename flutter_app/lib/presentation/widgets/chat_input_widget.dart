import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onMessageSent;
  final bool isLoading;
  final VoidCallback? onNewChat;
  final VoidCallback? onEndChat; // NEW: Add end chat callback

  const ChatInputWidget({
    super.key,
    required this.onMessageSent,
    this.isLoading = false,
    this.onNewChat,
    this.onEndChat, // NEW: Add to constructor
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;
  bool _showBackButton = false;
  bool _isTyping = false; // NEW: Track if user is actively typing
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _canSend = _controller.text.trim().isNotEmpty;
      _showBackButton = _controller.text.isNotEmpty;
      _isTyping = _controller.text.isNotEmpty; // NEW: Update typing state
    });
  }

  void _onFocusChanged() {
    setState(() {
      _isTyping = _focusNode.hasFocus && _controller.text.isNotEmpty;
    });

    if (_focusNode.hasFocus) {
      // Use a more direct approach without storing context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    if (_canSend && !widget.isLoading) {
      final message = _controller.text.trim();
      _controller.clear();
      _dismissKeyboard();
      setState(() {
        _canSend = false;
        _showBackButton = false;
        _isTyping = false;
      });
      widget.onMessageSent(message);
    }
  }

  // NEW: Save and end chat functionality
  void _saveAndEndChat() {
    // If there's unsent text, ask user what to do
    if (_controller.text.trim().isNotEmpty) {
      _showSaveDialog();
    } else {
      _endCurrentChat();
    }
  }

  // NEW: Show dialog when there's unsent text
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Draft?'),
          content: const Text(
            'You have unsent text. What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.clear();
                _endCurrentChat();
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final message = _controller.text.trim();
                _controller.clear();
                widget.onMessageSent(message);
                _endCurrentChat();
              },
              child: const Text('Send & End'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Save as draft
                _controller.clear();
                _endCurrentChat();
              },
              child: const Text('Save Draft'),
            ),
          ],
        );
      },
    );
  }

  // NEW: End current chat and start new one
  void _endCurrentChat() {
    _dismissKeyboard();
    setState(() {
      _canSend = false;
      _showBackButton = false;
      _isTyping = false;
    });

    // Call the end chat callback
    if (widget.onEndChat != null) {
      widget.onEndChat!();
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Chat saved successfully!'),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearInput() {
    _controller.clear();
    _dismissKeyboard();
    setState(() {
      _canSend = false;
      _showBackButton = false;
      _isTyping = false;
    });
  }

  void _dismissKeyboard() {
    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      _sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NEW: Show save/end chat options when typing
            if (_isTyping || _focusNode.hasFocus) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: _clearInput,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.mediumGray,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saveAndEndChat,
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Save & End'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (widget.onNewChat != null)
                      TextButton.icon(
                        onPressed: widget.onNewChat,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New Chat'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryTeal,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Main input row
            Row(
              children: [
                // Back button (shows when typing)
                if (_showBackButton) ...[
                  GestureDetector(
                    onTap: _clearInput,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.mediumGray.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.mediumGray,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            _canSend
                                ? AppColors.primaryTeal.withValues(alpha: 0.5)
                                : AppColors.mediumGray.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSubmitted,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGray,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            widget.isLoading
                                ? 'AI is thinking... 🤔'
                                : _isTyping
                                ? 'Type your message... (options above ↑)'
                                : 'Ask me anything! 💭',
                        hintStyle: TextStyle(
                          color: AppColors.mediumGray.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primaryTeal.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                        suffixIcon:
                            _focusNode.hasFocus
                                ? IconButton(
                                  icon: Icon(
                                    Icons.keyboard_hide_rounded,
                                    color: AppColors.mediumGray.withValues(
                                      alpha: 0.7,
                                    ),
                                    size: 20,
                                  ),
                                  onPressed: _dismissKeyboard,
                                )
                                : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Send button
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient:
                              _canSend && !widget.isLoading
                                  ? AppColors.sunsetGradient
                                  : null,
                          color:
                              _canSend && !widget.isLoading
                                  ? null
                                  : AppColors.mediumGray.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          boxShadow:
                              _canSend && !widget.isLoading
                                  ? [
                                    BoxShadow(
                                      color: AppColors.primaryOrange.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                      spreadRadius: _pulseController.value * 2,
                                    ),
                                  ]
                                  : null,
                        ),
                        child:
                            widget.isLoading
                                ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryTeal,
                                    ),
                                  ),
                                )
                                : Icon(
                                  Icons.send_rounded,
                                  color:
                                      _canSend && !widget.isLoading
                                          ? Colors.white
                                          : AppColors.mediumGray,
                                  size: 24,
                                ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Don't use BuildContext across async gaps. If you need to use context after an await, capture a reference to a value or use mounted check.
