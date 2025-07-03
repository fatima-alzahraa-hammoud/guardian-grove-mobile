// lib/presentation/pages/home/home_subScreens/goals_adventures_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/goals_adventure_repository.dart'
    show GoalsAdventuresRepository;
import 'package:flutter_app/presentation/widgets/add_goal_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/models/goal_model.dart';
import '../../../../data/models/adventure_model.dart';
import '../../../widgets/goal_card_widget.dart';
import '../../../widgets/adventure_widget.dart';

class GoalsAdventuresScreen extends StatefulWidget {
  const GoalsAdventuresScreen({super.key});

  @override
  State<GoalsAdventuresScreen> createState() => _GoalsAdventuresScreenState();
}

class _GoalsAdventuresScreenState extends State<GoalsAdventuresScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _fadeAnimation;
  late GoalsAdventuresRepository _repository;

  // Goals state
  List<Goal> _goals = [];
  List<Goal> _inProgressGoals = [];
  List<Goal> _completedGoals = [];
  bool _isLoadingGoals = false;

  // Adventures state
  List<Adventure> _adventures = [];
  Adventure? _selectedAdventure;
  DateTime _selectedDate = DateTime.now();
  bool _isLoadingAdventures = false;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _repository = GoalsAdventuresRepository(DioClient());
    _loadInitialData();

    // Start animations
    _headerAnimationController.forward();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadGoals(), _loadAdventures()]);
  }

  Future<void> _loadGoals() async {
    if (mounted) {
      setState(() {
        _isLoadingGoals = true;
      });
    }

    try {
      final goals = await _repository.fetchGoals();
      if (mounted) {
        setState(() {
          _goals = goals;
          _inProgressGoals = goals.where((goal) => !goal.isCompleted).toList();
          _completedGoals = goals.where((goal) => goal.isCompleted).toList();
          _isLoadingGoals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGoals = false;
        });
        _showErrorSnackBar('Failed to load goals: $e');
      }
    }
  }

  Future<void> _loadAdventures() async {
    if (mounted) {
      setState(() {
        _isLoadingAdventures = true;
      });
    }

    try {
      final adventures = await _repository.fetchAdventures();
      if (mounted) {
        setState(() {
          _adventures = adventures;
          _selectedAdventure = _findAdventureForDate(_selectedDate, adventures);
          _isLoadingAdventures = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAdventures = false;
        });
        _showErrorSnackBar('Failed to load adventures: $e');
      }
    }
  }

  Adventure? _findAdventureForDate(DateTime date, List<Adventure> adventures) {
    return adventures.where((adventure) {
      final adventureDate = adventure.startDate;
      return adventureDate.year == date.year &&
          adventureDate.month == date.month &&
          adventureDate.day == date.day;
    }).firstOrNull;
  }

  Future<void> _generateAIGoal() async {
    try {
      await _repository.generateAIGoal();
      await _loadGoals();
      _showSuccessSnackBar('AI Goal generated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate AI goal: $e');
    }
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddGoalDialog(
            onGoalCreated: (goal) {
              _loadGoals();
            },
            repository: _repository,
          ),
    );
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedAdventure = _findAdventureForDate(date, _adventures);
      _showCalendar = false; // Close calendar after selection
    });
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      _onDateChanged(picked);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                floating: true,
                pinned: true,
                expandedHeight: 100, // Reduced height for more compact header
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                    left: 70,
                    bottom: 50,
                  ), // Adjusted padding
                  title: AnimatedBuilder(
                    animation: _headerSlideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_headerSlideAnimation.value, 0),
                        child: const Text(
                          'Goals & Adventures',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18, // Reduced font size
                            fontWeight: FontWeight.w800,
                            fontFamily: 'ComicSans',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryTeal,
                            AppColors.primaryBlue,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      dividerHeight: 0,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flag_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Goals'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.explore_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Adventures'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [_buildGoalsTab(), _buildAdventuresTab()],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsTab() {
    return RefreshIndicator(
      onRefresh: _loadGoals,
      color: AppColors.primaryTeal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 24, // Reduced top padding
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            AnimatedBuilder(
              animation: _headerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: _buildGoalsHeader(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Action Buttons
            _buildGoalsActionButtons(),
            const SizedBox(height: 32),

            // Goals Content
            if (_isLoadingGoals)
              _buildLoadingState()
            else if (_goals.isEmpty)
              _buildEmptyGoalsState()
            else
              _buildGoalsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryTeal,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your amazing goals...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryTeal, AppColors.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Conquer Goals, Embark on Adventures',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'ComicSans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Experience exciting adventures, accomplish meaningful goals, and rise to thrilling challenges together!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatChip(
                Icons.flag_rounded,
                '${_goals.length}',
                'Total Goals',
                Colors.white.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 16),
              _buildStatChip(
                Icons.check_circle_rounded,
                '${_completedGoals.length}',
                'Completed',
                Colors.white.withValues(alpha: 0.25),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label,
    Color backgroundColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_rounded,
            label: 'Add Goal',
            color: AppColors.success,
            onTap: _showAddGoalDialog,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'AI Generate',
            color: AppColors.primaryTeal,
            onTap: _generateAIGoal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.sort_rounded,
            label: 'Sort',
            color: AppColors.primaryOrange,
            onTap: () {
              // TODO: Implement sorting
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.1),
                      color.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGoalsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withValues(alpha: 0.1),
                  AppColors.primaryBlue.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: AppColors.primaryTeal.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 70,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Goals Yet! 🚀',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTeal,
              fontFamily: 'ComicSans',
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start your journey by creating your first goal.\nYou\'re capable of greatness!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryTeal, AppColors.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _showAddGoalDialog,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Create Your First Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // In Progress Goals
        if (_inProgressGoals.isNotEmpty) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'In Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontFamily: 'ComicSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 380, // Increased height for better goal card display
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _inProgressGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 320,
                  child: GoalCardWidget(
                    goal: _inProgressGoals[index],
                    repository: _repository,
                    onGoalUpdated: _loadGoals,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],

        // Completed Goals
        if (_completedGoals.isNotEmpty) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Completed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontFamily: 'ComicSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 380, // Increased height for better goal card display
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _completedGoals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 320,
                  child: GoalCardWidget(
                    goal: _completedGoals[index],
                    repository: _repository,
                    onGoalUpdated: _loadGoals,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdventuresTab() {
    return RefreshIndicator(
      onRefresh: _loadAdventures,
      color: AppColors.primaryTeal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 24, // Reduced top padding
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Beautiful Date Picker Header
            _buildDatePickerHeader(),
            const SizedBox(height: 24),

            // Expandable Calendar
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showCalendar ? 380 : 0,
              child:
                  _showCalendar
                      ? _buildCalendarWidget()
                      : const SizedBox.shrink(),
            ),

            if (_showCalendar) const SizedBox(height: 24),

            // Adventures Header
            AnimatedBuilder(
              animation: _headerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: _buildAdventuresHeader(),
                );
              },
            ),
            const SizedBox(height: 32),

            // Adventure Content
            if (_isLoadingAdventures)
              _buildLoadingState()
            else if (_selectedAdventure == null)
              _buildNoAdventureState()
            else
              AdventureWidget(
                adventure: _selectedAdventure!,
                repository: _repository,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerHeader() {
    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Display
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayNames[_selectedDate.weekday - 1],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedDate.day}',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'ComicSans',
                        height: 1,
                      ),
                    ),
                    Text(
                      '${monthNames[_selectedDate.month]} ${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              // Date picker and calendar toggle buttons
              Column(
                children: [
                  // Calendar button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _showCalendar = !_showCalendar;
                        });
                      },
                      icon: Icon(
                        _showCalendar
                            ? Icons.calendar_view_month
                            : Icons.calendar_today,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date picker button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showDatePicker,
                      icon: const Icon(
                        Icons.date_range,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Adventure status indicator
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _selectedAdventure != null
                      ? Icons.explore
                      : Icons.explore_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedAdventure != null
                      ? '🎯 Adventure Available'
                      : '📅 No Adventure Today',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar<Adventure>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _selectedDate,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          eventLoader: (day) {
            return _adventures.where((adventure) {
              return isSameDay(adventure.startDate, day);
            }).toList();
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markerDecoration: const BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryTeal, AppColors.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            weekendTextStyle: const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
            defaultTextStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
            markerSize: 6,
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'ComicSans',
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.primaryTeal,
              size: 28,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryTeal,
              size: 28,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            _onDateChanged(selectedDay);
          },
        ),
      ),
    );
  }

  Widget _buildAdventuresHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.primaryPink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Adventure Awaits! ✨',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'ComicSans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Take on exciting challenges and achieve your dreams together!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAdventureState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange.withValues(alpha: 0.1),
                  AppColors.primaryPink.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(70),
              border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.explore_off_rounded,
              size: 70,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Adventure Today 🗓️',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryOrange,
              fontFamily: 'ComicSans',
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No adventures available for this date.\nCheck other dates for exciting challenges!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Tip: Use the calendar or date picker to explore different dates',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
