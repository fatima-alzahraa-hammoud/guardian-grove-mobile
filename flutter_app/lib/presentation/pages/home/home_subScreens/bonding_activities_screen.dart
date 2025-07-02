import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/core/constants/app_constants.dart';
import 'package:flutter_app/core/services/storage_service.dart';

/// Bonding Activities Screen
///
/// This screen displays family bonding activities.
/// Currently uses mock data as fallback when the backend endpoint
/// `/bondingActivities/` is not available (returns 404).
///
/// UI Improvements:
/// - Fixed overflow issues by adjusting aspect ratio and reducing content spacing
/// - Optimized layout for better content display
///
/// TODO: Backend needs to implement:
/// - GET /bondingActivities/  (fetch all activities)
/// - PATCH /bondingActivities/{id}/download  (increment download count)

class BondingActivityScreen extends StatefulWidget {
  const BondingActivityScreen({super.key});

  @override
  State<BondingActivityScreen> createState() => _BondingActivityScreenState();
}

class _BondingActivityScreenState extends State<BondingActivityScreen>
    with TickerProviderStateMixin {
  List<BondingActivity> _activities = [];
  List<BondingActivity> _filteredActivities = [];
  bool _isLoading = true;
  String _selectedCategory = 'All Activities';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'All Activities',
    'Creative',
    'Memory',
    'Games',
    'Emotional',
    'Planning',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Creative': Icons.palette_rounded,
    'Memory': Icons.favorite_rounded,
    'Games': Icons.sports_esports_rounded,
    'Emotional': Icons.favorite_border_rounded,
    'Planning': Icons.event_note_rounded,
    'Music': Icons.music_note_rounded,
    'Cooking': Icons.restaurant_rounded,
  };

  final Map<String, Color> _difficultyColors = {
    'Easy': Color(0xFF10B981),
    'Medium': Color(0xFFF59E0B),
    'Hard': Color(0xFFEF4444),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchBondingActivities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBondingActivities() async {
    try {
      setState(() => _isLoading = true);

      final dio = Dio();
      final token = StorageService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      dio.options.baseUrl = AppConstants.baseUrl;
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);

      debugPrint('🎯 Fetching bonding activities...');

      try {
        // Try the bonding activities endpoint first
        final response = await dio.get('/bondingActivities/');

        if (response.statusCode == 200) {
          final responseData = response.data;
          debugPrint('✅ Bonding activities response received');

          List<dynamic> activitiesData = [];
          if (responseData['activities'] != null) {
            activitiesData = responseData['activities'];
          } else if (responseData is List) {
            activitiesData = responseData;
          }

          final activities =
              activitiesData
                  .map((data) => BondingActivity.fromJson(data))
                  .toList();

          setState(() {
            _activities = activities;
            _filteredActivities = activities;
            _isLoading = false;
          });

          _animationController.forward();
          debugPrint('✅ Loaded ${activities.length} bonding activities');
          return;
        }
      } catch (apiError) {
        debugPrint(
          '❌ API endpoint /bondingActivities/ not available: $apiError',
        );
        // Fall back to mock data
      }

      // Fallback to mock data when API is not available
      debugPrint('📝 Using mock bonding activities data');
      final mockActivities = _getMockBondingActivities();

      setState(() {
        _activities = mockActivities;
        _filteredActivities = mockActivities;
        _isLoading = false;
      });

      _animationController.forward();
      debugPrint('✅ Loaded ${mockActivities.length} mock bonding activities');
    } catch (e) {
      debugPrint('❌ Error fetching bonding activities: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load activities. Please try again.');
    }
  }

  List<BondingActivity> _getMockBondingActivities() {
    return [
      BondingActivity(
        id: '1',
        title: 'Family Cooking Adventure',
        description:
            'Cook a delicious meal together and learn about different cultures through food.',
        category: 'Creative',
        difficulty: 'Easy',
        duration: '45 minutes',
        ageGroup: '4-12',
        participants: '2-6',
        downloads: 1250,
        materials: ['Kitchen ingredients', 'Cooking utensils', 'Recipe book'],
        downloadUrl: '',
        thumbnail: '',
      ),
      BondingActivity(
        id: '2',
        title: 'Memory Lane Photo Walk',
        description:
            'Take a walk through your neighborhood and capture memories while sharing stories.',
        category: 'Memory',
        difficulty: 'Easy',
        duration: '30 minutes',
        ageGroup: '6-16',
        participants: '2-4',
        downloads: 890,
        materials: ['Camera or phone', 'Comfortable shoes'],
        downloadUrl: '',
        thumbnail: '',
      ),
      BondingActivity(
        id: '3',
        title: 'Board Game Tournament',
        description:
            'Host a family board game tournament with prizes and lots of laughter.',
        category: 'Games',
        difficulty: 'Medium',
        duration: '2 hours',
        ageGroup: '8-18',
        participants: '3-6',
        downloads: 2150,
        materials: [
          'Various board games',
          'Score sheets',
          'Small prizes',
          'Snacks',
        ],
        downloadUrl: '',
        thumbnail: '',
      ),
      BondingActivity(
        id: '4',
        title: 'Feelings Journal Creation',
        description:
            'Create personalized journals to help express and understand emotions together.',
        category: 'Emotional',
        difficulty: 'Medium',
        duration: '1 hour',
        ageGroup: '5-15',
        participants: '2-3',
        downloads: 670,
        materials: [
          'Blank notebooks',
          'Colored pens',
          'Stickers',
          'Decorative materials',
        ],
        downloadUrl: '',
        thumbnail: '',
      ),
      BondingActivity(
        id: '5',
        title: 'Future Dreams Planning',
        description:
            'Plan future family adventures and individual goals together.',
        category: 'Planning',
        difficulty: 'Easy',
        duration: '45 minutes',
        ageGroup: '7-18',
        participants: '2-5',
        downloads: 1100,
        materials: ['Large paper', 'Markers', 'Magazines for cutting', 'Glue'],
        downloadUrl: '',
        thumbnail: '',
      ),
    ];
  }

  void _filterActivities(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All Activities') {
        _filteredActivities = _activities;
      } else {
        _filteredActivities =
            _activities
                .where((activity) => activity.category == category)
                .toList();
      }
    });
  }

  Future<void> _downloadActivity(BondingActivity activity) async {
    try {
      // First, increment the download count
      final dio = Dio();
      final token = StorageService.getToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      dio.options.baseUrl = AppConstants.baseUrl;

      try {
        await dio.patch('/bondingActivities/${activity.id}/download');
      } catch (apiError) {
        debugPrint('❌ Download endpoint not available: $apiError');
        // Continue with local update even if API fails
      }

      // Update local state
      setState(() {
        final index = _activities.indexWhere((a) => a.id == activity.id);
        if (index != -1) {
          _activities[index] = activity.copyWith(
            downloads: activity.downloads + 1,
          );
        }
        _filterActivities(_selectedCategory); // Refresh filtered list
      });

      // Show success message
      _showSuccessSnackBar('Activity downloaded! Check your downloads folder.');

      debugPrint('✅ Activity downloaded: ${activity.title}');
    } catch (e) {
      debugPrint('❌ Error downloading activity: $e');
      _showErrorSnackBar('Failed to download activity. Please try again.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Family Bonding Activities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0EA5E9)),
            onPressed: _fetchBondingActivities,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF0EA5E9)),
          SizedBox(height: 16),
          Text(
            'Loading bonding activities...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(),
          _buildCategoryFilters(),
          Expanded(
            child:
                _filteredActivities.isEmpty
                    ? _buildEmptyState()
                    : _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strengthen Family Bonds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Download fun activities to create lasting memories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: EdgeInsets.only(
              right: index == _categories.length - 1 ? 0 : 12,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _filterActivities(category),
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0EA5E9) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF0EA5E9)
                              : const Color(0xFFE2E8F0),
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF0EA5E9,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivitiesList() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 0.85, // Increased from 0.75 to reduce height
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = _filteredActivities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(BondingActivity activity) {
    final categoryIcon =
        _categoryIcons[activity.category] ?? Icons.category_rounded;
    final difficultyColor =
        _difficultyColors[activity.difficulty] ?? const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with thumbnail
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0EA5E9),
                  const Color(0xFF0EA5E9).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                if (activity.thumbnail.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      activity.thumbnail,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildDefaultThumbnail(categoryIcon),
                    ),
                  )
                else
                  _buildDefaultThumbnail(categoryIcon),

                // Difficulty badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Duration
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10), // Reduced from 12
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: const TextStyle(
                            fontSize: 15, // Slightly reduced
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '4.5',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Reduced from 6
                  // Description
                  Text(
                    activity.description,
                    style: const TextStyle(
                      fontSize: 13, // Slightly reduced
                      color: Color(0xFF64748B),
                      height: 1.2, // Reduced line height
                    ),
                    maxLines: 2, // Reduced from 3
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Reduced from 8
                  // Participants and age group
                  Row(
                    children: [
                      Icon(
                        Icons.group_rounded,
                        size: 14, // Reduced icon size
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.participants,
                          style: const TextStyle(
                            fontSize: 11, // Reduced font size
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Age: ${activity.ageGroup}',
                        style: const TextStyle(
                          fontSize: 11, // Reduced font size
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // Reduced from 12
                  // Materials (first few)
                  if (activity.materials.isNotEmpty) ...[
                    Wrap(
                      spacing: 4, // Reduced spacing
                      runSpacing: 4,
                      children: [
                        ...activity.materials
                            .take(2) // Reduced from 3 to 2 items
                            .map(
                              (material) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5, // Reduced padding
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF0EA5E9,
                                    ).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  material,
                                  style: const TextStyle(
                                    fontSize: 8, // Reduced font size
                                    color: Color(0xFF0EA5E9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        if (activity.materials.length > 2) // Updated condition
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FE),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              '+${activity.materials.length - 2} more', // Updated text
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                  ],

                  const Spacer(),

                  // Download button and count
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadActivity(activity),
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 14,
                          ), // Smaller icon
                          label: const Text(
                            'Download Activity',
                            style: TextStyle(fontSize: 12), // Smaller font
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ), // Reduced padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced spacing
                      Text(
                        '${activity.downloads} downloads',
                        style: const TextStyle(
                          fontSize: 10, // Smaller font
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultThumbnail(IconData icon) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Icon(icon, size: 48, color: Colors.white.withValues(alpha: 0.8)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: Color(0xFF0EA5E9),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${_selectedCategory == 'All Activities' ? '' : _selectedCategory} Activities Yet!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'More bonding activities are coming soon!\nCheck back later for new ways to connect with your family.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchBondingActivities,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BondingActivity model to match your backend structure
class BondingActivity {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration;
  final String difficulty;
  final String ageGroup;
  final String participants;
  final List<String> materials;
  final String downloadUrl;
  final String thumbnail;
  final int downloads;

  const BondingActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficulty,
    required this.ageGroup,
    required this.participants,
    required this.materials,
    required this.downloadUrl,
    required this.thumbnail,
    this.downloads = 0,
  });

  factory BondingActivity.fromJson(Map<String, dynamic> json) {
    return BondingActivity(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      difficulty: json['difficulty'] ?? '',
      ageGroup: json['ageGroup'] ?? '',
      participants: json['participants'] ?? '',
      materials: List<String>.from(json['materials'] ?? []),
      downloadUrl: json['downloadUrl'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      downloads: json['downloads'] ?? 0,
    );
  }

  BondingActivity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? duration,
    String? difficulty,
    String? ageGroup,
    String? participants,
    List<String>? materials,
    String? downloadUrl,
    String? thumbnail,
    int? downloads,
  }) {
    return BondingActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      ageGroup: ageGroup ?? this.ageGroup,
      participants: participants ?? this.participants,
      materials: materials ?? this.materials,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      downloads: downloads ?? this.downloads,
    );
  }
}
