import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onMessageSent;
  final bool isLoading;

  const ChatInputWidget({
    super.key,
    required this.onMessageSent,
    this.isLoading = false,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _canSend = _controller.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    if (_canSend && !widget.isLoading) {
      final message = _controller.text.trim();
      _controller.clear();
      setState(() {
        _canSend = false;
      });
      widget.onMessageSent(message);
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
        child: Row(
          children: [
            // Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _canSend
                        ? AppColors.primaryTeal.withValues(alpha: 0.5)
                        : AppColors.mediumGray.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkGray,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.isLoading
                        ? 'AI is thinking... 🤔'
                        : 'Ask me anything! 💭',
                    hintStyle: TextStyle(
                      color: AppColors.mediumGray.withValues(alpha: 0.7),
                      fontSize: 16,
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
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Send Button
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _canSend && !widget.isLoading
                          ? AppColors.sunsetGradient
                          : null,
                      color: _canSend && !widget.isLoading
                          ? null
                          : AppColors.mediumGray.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      boxShadow: _canSend && !widget.isLoading
                          ? [
                              BoxShadow(
                                color: AppColors.primaryOrange.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: _pulseController.value * 2,
                              ),
                            ]
                          : null,
                    ),
                    child: widget.isLoading
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
                            color: _canSend && !widget.isLoading
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
      ),
    );
  }
}
