// lib/presentation/widgets/challenge_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/goals_adventure_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/adventure_model.dart';

class ChallengeDialog extends StatefulWidget {
  final Challenge challenge;
  final String adventureId;
  final String adventureTitle;
  final int challengeNumber;
  final int totalChallenges;
  final bool isCompleted;
  final GoalsAdventuresRepository repository;
  final Function(String) onChallengeComplete;

  const ChallengeDialog({
    super.key,
    required this.challenge,
    required this.adventureId,
    required this.adventureTitle,
    required this.challengeNumber,
    required this.totalChallenges,
    required this.isCompleted,
    required this.repository,
    required this.onChallengeComplete,
  });

  @override
  State<ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends State<ChallengeDialog> {
  String _userAnswer = '';
  String _aiResponse = '';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    // Get keyboard height
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - keyboardHeight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: availableHeight * 0.9, // Use available height instead of full screen height
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Fixed size
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryOrange, AppColors.primaryPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Adventure:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              widget.adventureTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'ComicSans',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderStat(
                        'Stars',
                        '${widget.challenge.starsReward}',
                      ),
                      _buildHeaderStat(
                        'Coins',
                        '${widget.challenge.coinsReward}',
                      ),
                      _buildHeaderStat(
                        'Challenge',
                        '${widget.challengeNumber}/${widget.totalChallenges}',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content - Scrollable and flexible
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenge Title with Completion Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.challenge.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'ComicSans',
                            ),
                          ),
                        ),
                        if (widget.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Challenge Content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.challenge.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Answer Section (only if not completed)
                    if (!widget.isCompleted) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Answer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (value) => setState(() {
                          _userAnswer = value;
                        }),
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          hintText: 'Type your answer here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryTeal,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 3,
                        minLines: 2,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isSubmitting || _userAnswer.trim().isEmpty
                                  ? null
                                  : _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                        ),
                      ),
                    ],

                    // AI Response
                    if (_aiResponse.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              _aiResponse.contains('Excellent')
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _aiResponse.contains('Excellent')
                                    ? AppColors.success
                                    : AppColors.error,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _aiResponse.contains('Excellent')
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              color:
                                  _aiResponse.contains('Excellent')
                                      ? AppColors.success
                                      : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _aiResponse,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _aiResponse.contains('Excellent')
                                          ? AppColors.success
                                          : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Add bottom padding for better scrolling
                    SizedBox(height: keyboardHeight > 0 ? 40 : 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Future<void> _submitAnswer() async {
    if (_userAnswer.trim().isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _aiResponse = 'Checking your answer...';
    });

    try {
      final isCorrect = await widget.repository.checkAnswer(
        question: widget.challenge.content,
        userAnswer: _userAnswer.trim(),
      );

      if (isCorrect) {
        setState(() {
          _aiResponse = 'Excellent! Your answer is correct! 😊';
        });

        // Complete the challenge
        await widget.repository.completeChallenge(
          adventureId: widget.adventureId,
          challengeId: widget.challenge.id,
        );

        // Notify parent widget
        widget.onChallengeComplete(widget.challenge.id);

        // Close dialog after success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        setState(() {
          _aiResponse = 'That\'s not quite right. Try again! 🤔';
        });
      }
    } catch (e) {
      setState(() {
        _aiResponse = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}