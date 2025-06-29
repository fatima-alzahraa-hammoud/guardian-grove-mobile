import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../data/models/user_model.dart';
import 'add_member_choice_dialog.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const ProfileSetupScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form data
  String _selectedRole = '';
  String _selectedGender = '';
  String _selectedAvatar = '';
  String _familyAvatar = '';
  DateTime? _selectedBirthday;
  final List<String> _interests = [];
  final TextEditingController _familyNameController = TextEditingController();

  // Avatar options
  // Personal Avatar options (Parent/Child)
final List<Map<String, dynamic>> _personalAvatars = [
  {
    'id': 'assets/images/avatars/parent/avatar1.png',
    'path': 'assets/images/avatars/parent/avatar1.png',
    'label': 'Parent Avatar 1',
  },
  {
    'id': 'assets/images/avatars/parent/avatar2.png',
    'path': 'assets/images/avatars/parent/avatar2.png',
    'label': 'Parent Avatar 2',
  },
  {
    'id': 'assets/images/avatars/parent/avatar3.png',
    'path': 'assets/images/avatars/parent/avatar3.png',
    'label': 'Parent Avatar 3',
  },
  {
    'id': 'assets/images/avatars/parent/avatar4.png',
    'path': 'assets/images/avatars/parent/avatar4.png',
    'label': 'Parent Avatar 4',
  },
  {
    'id': 'assets/images/avatars/parent/avatar5.png',
    'path': 'assets/images/avatars/parent/avatar5.png',
    'label': 'Parent Avatar 5',
  },
  {
    'id': 'assets/images/avatars/parent/avatar6.png',
    'path': 'assets/images/avatars/parent/avatar6.png',
    'label': 'Parent Avatar 6',
  },
  {
    'id': 'assets/images/avatars/child/avatar1.png',
    'path': 'assets/images/avatars/child/avatar1.png',
    'label': 'Child Avatar 1',
  },
  {
    'id': 'assets/images/avatars/child/avatar2.png',
    'path': 'assets/images/avatars/child/avatar2.png',
    'label': 'Child Avatar 2',
  },
  {
    'id': 'assets/images/avatars/child/avatar3.png',
    'path': 'assets/images/avatars/child/avatar3.png',
    'label': 'Child Avatar 3',
  },
  {
    'id': 'assets/images/avatars/child/avatar4.png',
    'path': 'assets/images/avatars/child/avatar4.png',
    'label': 'Child Avatar 4',
  },
];

// Family Avatar options
final List<Map<String, dynamic>> _familyAvatars = [
  {
    'id': 'assets/images/avatars/family/avatar1.png',
    'path': 'assets/images/avatars/family/avatar1.png',
    'label': 'Family Avatar 1',
  },
  {
    'id': 'assets/images/avatars/family/avatar2.png',
    'path': 'assets/images/avatars/family/avatar2.png',
    'label': 'Family Avatar 2',
  },
  {
    'id': 'assets/images/avatars/family/avatar3.png',
    'path': 'assets/images/avatars/family/avatar3.png',
    'label': 'Family Avatar 3',
  },
  {
    'id': 'assets/images/avatars/family/avatar4.png',
    'path': 'assets/images/avatars/family/avatar4.png',
    'label': 'Family Avatar 4',
  },
  {
    'id': 'assets/images/avatars/family/avatar5.png',
    'path': 'assets/images/avatars/family/avatar5.png',
    'label': 'Family Avatar 5',
  },
  {
    'id': 'assets/images/avatars/family/avatar6.png',
    'path': 'assets/images/avatars/family/avatar6.png',
    'label': 'Family Avatar 6',
  },
  {
    'id': 'assets/images/avatars/family/avatar7.png',
    'path': 'assets/images/avatars/family/avatar7.png',
    'label': 'Family Avatar 7',
  },
  {
    'id': 'assets/images/avatars/family/avatar8.png',
    'path': 'assets/images/avatars/family/avatar8.png',
    'label': 'Family Avatar 8',
  },
];

  // Interest options
  final List<String> _interestOptions = [
    '⚽ Sports & Games',
    '🎨 Arts & Crafts',
    '📚 Reading & Stories',
    '🎵 Music & Dance',
    '🔬 Science & Experiments',
    '🎮 Video Games',
    '🌳 Outdoor Adventures',
    '🍳 Cooking & Baking',
    '🐶 Animals & Pets',
    '🔧 Building & Making',
    '📸 Photography',
    '✏️ Drawing & Painting',
    '🎲 Board Games',
    '🏊 Swimming',
    '🏃 Running & Fitness',
    '💻 Technology',
    '🌱 Gardening',
    '🎬 Movies & Shows',
    '🧩 Puzzles',
    '🚀 Space & Astronomy',
  ];

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeRegistration() {
    if (_selectedRole.isEmpty ||
        _selectedGender.isEmpty ||
        _familyNameController.text.trim().isEmpty ||
        _selectedAvatar.isEmpty ||
        _familyAvatar.isEmpty ||
        _selectedBirthday == null) {
      _showErrorSnackBar('Please complete all required fields');
      return;
    }

    final registerRequest = RegisterRequest(
      name: widget.name.trim(),
      email: widget.email.trim().toLowerCase(),
      password: widget.password,
      confirmPassword: widget.confirmPassword,
      birthday: _selectedBirthday!,
      gender: _selectedGender.toLowerCase(),
      role: _selectedRole.toLowerCase(),
      avatar: _selectedAvatar,
      interests: _interests,
      familyName: _familyNameController.text.trim(),
      familyAvatar: _familyAvatar,
    );

    context.read<AuthBloc>().add(RegisterEvent(registerRequest));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showChildRestrictionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.child_care_rounded,
                      size: 40,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Hey there, little one!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Text(
                      'Your parent or guardian needs to create the family account first. Ask them to register and set up Guardian Grove for your family!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Got it!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AddMemberChoiceDialog(),
          );
        } else if (state is AuthError) {
          _showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildRoleStep(),
                    _buildPersonalInfoStep(),
                    _buildFamilyStep(),
                    _buildAvatarStep(),
                    _buildInterestsStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF8F9FE), // Match body background
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF64748B),
              size: 24,
            ),
            onPressed: () {
              if (_currentStep > 0) {
                _prevStep();
              } else {
                // Go back to register page
                Navigator.of(context).pop();
              }
            },
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF4CAF50),
                  size: 60,
                );
              },
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
                  decoration: BoxDecoration(
                    color:
                        index <= _currentStep
                            ? const Color(0xFF0EA5E9)
                            : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of 5',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStepHeader(
            'Welcome to Guardian Grove!',
            'Are you a parent or child?',
          ),
          const SizedBox(height: 50),

          _buildRoleCard(
            'Parent',
            Icons.family_restroom_rounded,
            'I take care of my family',
            const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 20),
          _buildRoleCard(
            'Child',
            Icons.child_care_rounded,
            'I love fun and adventures',
            const Color(0xFFFF6B9D),
          ),

          const SizedBox(height: 30),

          // Info notice for children
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Children: Ask your parent or guardian to create the family account first!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildNavigationButtons(canProceed: _selectedRole == 'Parent'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStepHeader('Tell us about yourself', 'Personal information'),
          const SizedBox(height: 40),

          // Gender selection
          _buildSectionCard(
            title: 'Gender',
            child: Row(
              children: [
                Expanded(
                  child: _buildGenderCard(
                    'Male',
                    Icons.male_rounded,
                    const Color(0xFF0EA5E9),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderCard(
                    'Female',
                    Icons.female_rounded,
                    const Color(0xFFFF6B9D),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Birthday selection
          _buildSectionCard(
            title: 'Birthday',
            child: GestureDetector(
              onTap: _selectBirthday,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _selectedBirthday != null
                            ? const Color(0xFF0EA5E9)
                            : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color:
                          _selectedBirthday != null
                              ? const Color(0xFF0EA5E9)
                              : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedBirthday != null
                          ? '${_selectedBirthday!.day}/${_selectedBirthday!.month}/${_selectedBirthday!.year}'
                          : 'Select your birthday',
                      style: TextStyle(
                        color:
                            _selectedBirthday != null
                                ? const Color(0xFF1A202C)
                                : const Color(0xFF94A3B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          _buildNavigationButtons(
            canProceed: _selectedGender.isNotEmpty && _selectedBirthday != null,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStepHeader('Family Information', 'What\'s your family name?'),
          const SizedBox(height: 40),

          _buildSectionCard(
            title: 'Family Name',
            child: Column(
              children: [
                // Family icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.family_restroom_rounded,
                    size: 40,
                    color: Color(0xFF0EA5E9),
                  ),
                ),

                const SizedBox(height: 30),

                // Family name input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _familyNameController.text.trim().isNotEmpty
                              ? const Color(0xFF0EA5E9)
                              : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _familyNameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your family name',
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                      prefixIcon: Icon(
                        Icons.home_rounded,
                        color: Color(0xFF0EA5E9),
                        size: 20,
                      ),
                    ),
                    textAlign: TextAlign.left,
                    onChanged: (value) => setState(() {}),
                  ),
                ),

                const SizedBox(height: 16),

                // Helper text
                Text(
                  'This will be displayed as your family\'s name in the app',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          _buildNavigationButtons(
            canProceed: _familyNameController.text.trim().isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildStepHeader(
              'Choose Your Avatars',
              'Pick personal and family avatars',
            ),
            const SizedBox(height: 40),

          // Personal Avatar
          _buildSectionCard(
            title: 'Your Avatar',
            child: SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _personalAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _personalAvatars[index];
                  final isSelected = _selectedAvatar == avatar['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = avatar['id']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF4F46E5) 
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          avatar['path'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
            const SizedBox(height: 20),
            // Family Avatar
          _buildSectionCard(
            title: 'Family Avatar',
            child: SizedBox(
              height: 200,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _familyAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = _familyAvatars[index];
                  final isSelected = _familyAvatar == avatar['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _familyAvatar = avatar['id']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF4F46E5) 
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          avatar['path'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.family_restroom,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
            const SizedBox(height: 40),

            _buildNavigationButtons(
              canProceed:
                  _selectedAvatar.isNotEmpty && _familyAvatar.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStepHeader(
            'What do you love?',
            'Select your interests (optional)',
          ),
          const SizedBox(height: 40),

          _buildSectionCard(
            title: 'Interests',
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Select an interest',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                          ),
                        ),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF0EA5E9),
                        ),
                        items:
                            _interestOptions.map((interest) {
                              return DropdownMenuItem(
                                value: interest,
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    color: Color(0xFF1A202C),
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (interest) {
                          if (interest != null &&
                              !_interests.contains(interest)) {
                            setState(() => _interests.add(interest));
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Selected interests
                  Expanded(
                    child:
                        _interests.isNotEmpty
                            ? SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    _interests
                                        .map(
                                          (interest) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0EA5E9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  interest,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                GestureDetector(
                                                  onTap:
                                                      () => setState(
                                                        () => _interests.remove(
                                                          interest,
                                                        ),
                                                      ),
                                                  child: const Icon(
                                                    Icons.close_rounded,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            )
                            : Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      size: 48,
                                      color: Color(0xFFFF6B9D),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No interests selected yet',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'That\'s okay! You can add them later.',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          _buildCompleteButton(),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    String role,
    IconData icon,
    String subtitle,
    Color color,
  ) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        if (role == 'Child') {
          _showChildRestrictionDialog();
        } else {
          setState(() => _selectedRole = role);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? color.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF1A202C),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.9)
                              : const Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildGenderCard(String gender, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isSelected ? Colors.white : color),
            const SizedBox(width: 12),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A202C),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons({required bool canProceed}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient:
            canProceed
                ? const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                : null,
        color: canProceed ? null : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(26),
        boxShadow:
            canProceed
                ? [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: canProceed ? _nextStep : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Step',
                  style: TextStyle(
                    color: canProceed ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: canProceed ? Colors.white : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: state is AuthLoading ? null : _completeRegistration,
              child: Center(
                child:
                    state is AuthLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.celebration_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Complete Setup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0EA5E9),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A202C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedBirthday = picked);
  }
}
