// lib/presentation/widgets/add_goal_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/goals_adventure_repository.dart'
    show GoalsAdventuresRepository;
import '../../core/constants/app_colors.dart';
import '../../data/models/goal_model.dart';

class AddGoalDialog extends StatefulWidget {
  final Function(Goal) onGoalCreated;
  final GoalsAdventuresRepository repository;

  const AddGoalDialog({
    super.key,
    required this.onGoalCreated,
    required this.repository,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'personal';
  DateTime? _selectedDueDate;
  bool _isGeneratingTasks = false;
  bool _isSaving = false;
  bool _hasGeneratedTasks = false;
  List<Task> _generatedTasks = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700), // Increased max height
        child: Column(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Goal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'ComicSans',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal Title
                    const Text(
                      'Goal Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      enabled: !_isGeneratingTasks && !_isSaving,
                      decoration: InputDecoration(
                        hintText: 'Enter your goal title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Goal Description
                    const Text(
                      'Goal Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      enabled: !_isGeneratingTasks && !_isSaving,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe your goal in detail...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Goal Type (Changed to column layout)
                    const Text(
                      'Goal Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'personal',
                          child: Text('Personal'),
                        ),
                        DropdownMenuItem(
                          value: 'family',
                          child: Text('Family'),
                        ),
                      ],
                      onChanged:
                          (!_isGeneratingTasks && !_isSaving)
                              ? (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedType = value;
                                  });
                                }
                              }
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Due Date (Changed to column layout)
                    const Text(
                      'Due Date (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap:
                          _isGeneratingTasks || _isSaving
                              ? null
                              : _selectDueDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDueDate != null
                                  ? _formatDate(_selectedDueDate!)
                                  : 'Select date',
                              style: TextStyle(
                                color:
                                    _selectedDueDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Generate Tasks Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _canGenerateTasks() ? _generateTasks : null,
                        icon:
                            _isGeneratingTasks
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                          _isGeneratingTasks
                              ? 'Generating Tasks...'
                              : 'Generate Tasks',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    // Generated Tasks Section
                    if (_hasGeneratedTasks && _generatedTasks.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Generated Tasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'ComicSans',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppColors.primaryYellow,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_calculateTotalRewards()['stars']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.monetization_on_rounded,
                                  size: 16,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_calculateTotalRewards()['coins']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _generatedTasks.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = _generatedTasks[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTeal,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          task.description,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontFamily: 'Poppins',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: AppColors.primaryYellow,
                                      ),
                                      Text(
                                        '${task.rewards.stars}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.monetization_on_rounded,
                                        size: 14,
                                        color: AppColors.primaryOrange,
                                      ),
                                      Text(
                                        '${task.rewards.coins}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isGeneratingTasks || _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSaveGoal() ? _saveGoal : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Save Goal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canGenerateTasks() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        !_isGeneratingTasks &&
        !_isSaving;
  }

  bool _canSaveGoal() {
    return _hasGeneratedTasks &&
        _generatedTasks.isNotEmpty &&
        !_isGeneratingTasks &&
        !_isSaving;
  }

  Future<void> _generateTasks() async {
    setState(() {
      _isGeneratingTasks = true;
      _generatedTasks.clear();
      _hasGeneratedTasks = false;
    });

    try {
      // For now, we'll create mock tasks since the AI endpoint might not be available
      // In a real implementation, you would call an AI service here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      final mockTasks = [
        Task(
          id: '1',
          title: 'Research and Planning',
          description: 'Research the topic and create a detailed plan',
          type: _selectedType,
          rewards: const TaskRewards(stars: 3, coins: 2),
          isCompleted: false,
        ),
        Task(
          id: '2',
          title: 'Take the First Step',
          description: 'Start working on the first component of your goal',
          type: _selectedType,
          rewards: const TaskRewards(stars: 5, coins: 3),
          isCompleted: false,
        ),
        Task(
          id: '3',
          title: 'Progress Review',
          description: 'Review your progress and adjust if needed',
          type: _selectedType,
          rewards: const TaskRewards(stars: 2, coins: 1),
          isCompleted: false,
        ),
        Task(
          id: '4',
          title: 'Final Push',
          description: 'Complete the remaining work to achieve your goal',
          type: _selectedType,
          rewards: const TaskRewards(stars: 5, coins: 4),
          isCompleted: false,
        ),
      ];

      setState(() {
        _generatedTasks = mockTasks;
        _hasGeneratedTasks = true;
        _isGeneratingTasks = false;
      });

      _showSuccessSnackBar('Tasks generated successfully!');
    } catch (e) {
      setState(() {
        _isGeneratingTasks = false;
      });
      _showErrorSnackBar('Failed to generate tasks: $e');
    }
  }

  Future<void> _saveGoal() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final goal = await widget.repository.createGoal(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        dueDate: _selectedDueDate,
        rewards: {
          'stars': _calculateTotalRewards()['stars'],
          'coins': _calculateTotalRewards()['coins'],
        },
      );

      // In a real implementation, you would also create the tasks
      // For now, we'll just call the callback with the goal
      widget.onGoalCreated(goal);

      _showSuccessSnackBar('Goal created successfully!');
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorSnackBar('Failed to create goal: $e');
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primaryTeal),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      if (!mounted) return;
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Map<String, int> _calculateTotalRewards() {
    int totalStars = 0;
    int totalCoins = 0;

    for (final task in _generatedTasks) {
      totalStars += task.rewards.stars;
      totalCoins += task.rewards.coins;
    }

    // Add goal completion bonus
    totalStars += 10;
    totalCoins += 5;

    return {'stars': totalStars, 'coins': totalCoins};
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}