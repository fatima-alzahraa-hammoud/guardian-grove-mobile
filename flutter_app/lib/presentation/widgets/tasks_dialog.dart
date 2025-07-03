// lib/presentation/widgets/tasks_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/goals_adventure_repository.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/goal_model.dart';

class TasksDialog extends StatefulWidget {
  final Goal goal;
  final GoalsAdventuresRepository repository;
  final VoidCallback onGoalUpdated;

  const TasksDialog({
    super.key,
    required this.goal,
    required this.repository,
    required this.onGoalUpdated,
  });

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  bool _showAiDialog = false;
  Task? _selectedTask;
  String _aiQuestion = '';
  String _userAnswer = '';
  String _aiResponse = '';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Dialog
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryTeal, AppColors.primaryBlue],
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
                                  'Goal:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  widget.goal.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'ComicSans',
                                  ),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderStat(
                            'Total Tasks',
                            '${widget.goal.tasks.length}',
                          ),
                          _buildHeaderStat(
                            'Total Stars',
                            '${widget.goal.rewards.stars}',
                          ),
                          _buildHeaderStat(
                            'Total Coins',
                            '${widget.goal.rewards.coins}',
                          ),
                        ],
                      ),
                      if (widget.goal.rewards.achievementName != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Badge: ${widget.goal.rewards.achievementName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Tasks List
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      itemCount: widget.goal.tasks.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = widget.goal.tasks[index];
                        return _buildTaskCard(task, index + 1);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // AI Dialog Overlay - Now properly positioned above everything
        if (_showAiDialog) _buildAiDialog(),
      ],
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

  Widget _buildTaskCard(Task task, int number) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            task.isCompleted
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted ? AppColors.success : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Task Number/Checkmark
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color:
                      task.isCompleted
                          ? AppColors.success
                          : AppColors.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      task.isCompleted
                          ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                          : Text(
                            '$number',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),

              // Task Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? Colors.grey : Colors.black,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            task.isCompleted ? Colors.grey : Colors.grey[600],
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              // Rewards and Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRewardChip(
                        Icons.star_rounded,
                        '${task.rewards.stars}',
                      ),
                      const SizedBox(width: 4),
                      _buildRewardChip(
                        Icons.monetization_on_rounded,
                        '${task.rewards.coins}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        task.isCompleted
                            ? null
                            : () => _startTaskCompletion(task),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          task.isCompleted
                              ? AppColors.success
                              : AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(70, 32),
                    ),
                    child: Text(
                      task.isCompleted ? 'Done!' : 'Do it',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryTeal),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDialog() {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.7), // Darker overlay
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
          ),
          child: Center(
            child: SingleChildScrollView(
              // Added to handle keyboard overflow
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                margin: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.7, // Reduced to leave more space
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AI Dialog Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryTeal,
                            AppColors.primaryBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'AI Assistant',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'ComicSans',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _closeAiDialog(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dialog Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // AI Question
                            const Text(
                              'Question:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _aiQuestion,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // User Answer Input
                            const Text(
                              'Your Answer:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              onChanged: (value) => _userAnswer = value,
                              enabled: !_isSubmitting,
                              autofocus: true, // Auto focus for better UX
                              decoration: InputDecoration(
                                hintText: 'Type your answer here...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
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
                              textInputAction:
                                  TextInputAction
                                      .done, // Better keyboard action
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),

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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
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
                                          'Submit Answer',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                              ),
                            ),

                            // AI Response
                            if (_aiResponse.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      _aiResponse.contains('Good Job')
                                          ? AppColors.success.withValues(
                                            alpha: 0.1,
                                          )
                                          : AppColors.error.withValues(
                                            alpha: 0.1,
                                          ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _aiResponse.contains('Good Job')
                                            ? AppColors.success
                                            : AppColors.error,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _aiResponse.contains('Good Job')
                                          ? Icons.check_circle_rounded
                                          : Icons.error_rounded,
                                      color:
                                          _aiResponse.contains('Good Job')
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
                                              _aiResponse.contains('Good Job')
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

                            // Add some bottom padding to ensure content is scrollable
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startTaskCompletion(Task task) async {
    setState(() {
      _selectedTask = task;
      _userAnswer = '';
      _aiResponse = '';
      _isSubmitting = false;
    });

    try {
      final question = await widget.repository.generateTaskQuestion(
        task.description,
      );
      setState(() {
        _aiQuestion = question;
        _showAiDialog = true;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to generate question: $e');
    }
  }

  Future<void> _submitAnswer() async {
    if (_userAnswer.trim().isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _aiResponse = '';
    });

    try {
      final isCorrect = await widget.repository.checkAnswer(
        question: _aiQuestion,
        userAnswer: _userAnswer.trim(),
      );

      if (isCorrect) {
        setState(() {
          _aiResponse = 'Good Job! 😊';
        });

        // Complete the task
        await widget.repository.completeTask(
          goalId: widget.goal.id,
          taskId: _selectedTask!.id,
        );

        // Show success message and close dialog
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _closeAiDialog();
            // Immediately close the main tasks dialog and refresh the parent
            Navigator.of(context).pop();
            widget.onGoalUpdated();
          }
        });
      } else {
        setState(() {
          _aiResponse = 'Oops! Try again.. 😮‍💨';
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

  void _closeAiDialog() {
    setState(() {
      _showAiDialog = false;
      _selectedTask = null;
      _aiQuestion = '';
      _userAnswer = '';
      _aiResponse = '';
      _isSubmitting = false;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
