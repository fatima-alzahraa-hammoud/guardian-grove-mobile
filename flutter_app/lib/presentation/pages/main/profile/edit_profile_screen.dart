import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/family_api_service.dart';
import 'package:flutter_app/core/services/storage_service.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final String familyName;
  final String familyAvatar;
  final bool isParent;
  final void Function(Map<String, dynamic> data)? onConfirm;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.familyName,
    required this.familyAvatar,
    required this.isParent,
    this.onConfirm,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController familyNameController;
  String? gender;
  DateTime? birthday;
  String? avatar;
  String? familyAvatar;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? error;

  // Avatar options - same as ProfileSetupScreen
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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    familyNameController = TextEditingController(text: widget.familyName);
    gender = widget.user.gender;
    birthday = widget.user.birthday;
    avatar = widget.user.avatar;
    familyAvatar = widget.familyAvatar;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    familyNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
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
    if (picked != null) setState(() => birthday = picked);
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
            ),
            // Avatar grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _personalAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarData = _personalAvatars[index];
                    final isSelected = avatar == avatarData['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => avatar = avatarData['id']);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF0EA5E9) 
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            avatarData['path'],
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
          ],
        ),
      ),
    );
  }

  void _showFamilyAvatarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose Family Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A202C),
                ),
              ),
            ),
            // Avatar grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _familyAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarData = _familyAvatars[index];
                    final isSelected = familyAvatar == avatarData['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => familyAvatar = avatarData['id']);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF0EA5E9) 
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            avatarData['path'],
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
          ],
        ),
      ),
    );
  }

  Future<void> _updateStoredUserData(Map<String, dynamic> updatedData) async {
    try {
      // Get current user from storage
      final currentUser = StorageService.getUser();
      if (currentUser == null) return;

      // Create updated user model with new data
      final updatedUser = UserModel(
        id: currentUser.id,
        name: updatedData['name'] ?? currentUser.name,
        email: updatedData['email'] ?? currentUser.email,
        birthday: updatedData['birthday'] != null 
            ? DateTime.parse(updatedData['birthday']) 
            : currentUser.birthday,
        dailyMessage: currentUser.dailyMessage,
        gender: updatedData['gender'] ?? currentUser.gender,
        role: updatedData['role'] ?? currentUser.role,
        avatar: updatedData['avatar'] ?? currentUser.avatar,
        interests: currentUser.interests,
        memberSince: currentUser.memberSince,
        currentLocation: currentUser.currentLocation,
        stars: currentUser.stars,
        coins: currentUser.coins,
        nbOfTasksCompleted: currentUser.nbOfTasksCompleted,
        rankInFamily: currentUser.rankInFamily,
        familyId: currentUser.familyId,
        isTempPassword: currentUser.isTempPassword,
      );

      // Save updated user to storage
      await StorageService.saveUser(updatedUser);
      debugPrint('✅ Updated user data in storage');
    } catch (e) {
      debugPrint('❌ Error updating stored user data: $e');
    }
  }

  Future<void> _onConfirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() {
      isLoading = true;
      error = null;
    });

    final api = FamilyApiService();
    api.init();

    try {
      debugPrint('🔍 === STARTING PROFILE UPDATE DEBUG ===');
      debugPrint('📱 User: ${widget.user.name}');
      debugPrint('🏠 Family: ${widget.familyName}');
      debugPrint('👑 Is Parent: ${widget.isParent}');
      
      // Prepare user data - only include fields that have changed and are not null
      final userData = <String, dynamic>{};
      
      if (nameController.text.trim() != widget.user.name) {
        userData['name'] = nameController.text.trim();
        debugPrint('📝 Name changed: ${widget.user.name} → ${nameController.text.trim()}');
      }
      
      if (gender != null && gender != widget.user.gender) {
        userData['gender'] = gender;
        debugPrint('👤 Gender changed: ${widget.user.gender} → $gender');
      }
      
      if (birthday != null && birthday != widget.user.birthday) {
        userData['birthday'] = birthday!.toIso8601String();
        debugPrint('🎂 Birthday changed: ${widget.user.birthday} → $birthday');
      }
      
      if (avatar != null && avatar != widget.user.avatar) {
        userData['avatar'] = avatar;
        debugPrint('🖼️ Avatar changed: ${widget.user.avatar} → $avatar');
      }

      debugPrint('📦 Final user data to send: $userData');

      // Update user profile if there are changes
      bool userUpdateSuccess = true;
      if (userData.isNotEmpty) {
        debugPrint('🚀 Updating user profile...');
        
        // Update user profile with enhanced error reporting
        userUpdateSuccess = await api.updateUserProfile(userData);
        
        if (!userUpdateSuccess) {
          throw Exception('Failed to update user profile. Please check the console logs for details.');
        }
        debugPrint('✅ User profile updated successfully');
      } else {
        debugPrint('ℹ️ No user profile changes to save');
      }

      // If parent, update family details
      bool familyUpdateSuccess = true;
      if (widget.isParent) {
        final familyData = <String, dynamic>{};
        
        if (familyNameController.text.trim() != widget.familyName) {
          familyData['familyName'] = familyNameController.text.trim();
          debugPrint('🏠 Family name changed: ${widget.familyName} → ${familyNameController.text.trim()}');
        }
        
        if (familyAvatar != null && familyAvatar != widget.familyAvatar) {
          familyData['familyAvatar'] = familyAvatar;
          debugPrint('🖼️ Family avatar changed: ${widget.familyAvatar} → $familyAvatar');
        }
        
        if (emailController.text.trim() != widget.user.email) {
          familyData['email'] = emailController.text.trim();
          debugPrint('📧 Email changed: ${widget.user.email} → ${emailController.text.trim()}');
        }

        debugPrint('📦 Final family data to send: $familyData');
        
        if (familyData.isNotEmpty) {
          debugPrint('🚀 Updating family details...');
          familyUpdateSuccess = await api.updateFamilyDetails(familyData);
          if (!familyUpdateSuccess) {
            throw Exception('Failed to update family details. Please check your permissions and try again.');
          }
          debugPrint('✅ Family details updated successfully');
        } else {
          debugPrint('ℹ️ No family changes to save');
        }
      }

      // Show success message
      if (mounted) {
        final hasUserChanges = userData.isNotEmpty;
        final hasFamilyChanges = widget.isParent && familyUpdateSuccess;
        
        String successMessage;
        if (hasUserChanges && hasFamilyChanges) {
          successMessage = 'Profile and family updated successfully!';
        } else if (hasUserChanges) {
          successMessage = 'Profile updated successfully!';
        } else if (hasFamilyChanges) {
          successMessage = 'Family details updated successfully!';
        } else {
          successMessage = 'No changes to save';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(successMessage)),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // UPDATE: Refresh the stored user data with new values
      if (userData.isNotEmpty) {
        await _updateStoredUserData(userData);
      }

      if (widget.onConfirm != null) {
        final allData = {...userData};
        if (widget.isParent) {
          allData['familyName'] = familyNameController.text.trim();
          allData['familyAvatar'] = familyAvatar;
          allData['email'] = emailController.text.trim();
        }
        widget.onConfirm!(allData);
      }
      
      debugPrint('🎉 Profile update completed successfully');
      if (mounted) Navigator.of(context).pop(true); // Return true to indicate success
      
    } catch (e) {
      debugPrint('❌ Error in _onConfirm: $e');
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
      
      // Show error snackbar as well
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _onConfirm,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF64748B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Removed duplicate save button
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0EA5E9)),
                  SizedBox(height: 16),
                  Text(
                    'Updating profile...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                error!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Personal Avatar Section
                    _buildSectionCard(
                      title: 'Your Avatar',
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FE),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0EA5E9),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: avatar != null && avatar!.isNotEmpty
                                    ? Image.asset(
                                        avatar!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Color(0xFF64748B),
                                          );
                                        },
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Color(0xFF64748B),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to change avatar',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Personal Information Section
                    _buildSectionCard(
                      title: 'Personal Information',
                      child: Column(
                        children: [
                          // Name
                          TextFormField(
                            controller: nameController,
                            decoration: _buildInputDecoration('Name', Icons.person_outline),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // Birthday
                          GestureDetector(
                            onTap: _pickBirthday,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Color(0xFF0EA5E9),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      birthday != null
                                          ? DateFormat.yMMMMd().format(birthday!)
                                          : 'Select birthday',
                                      style: TextStyle(
                                        color: birthday != null 
                                            ? const Color(0xFF1A202C) 
                                            : const Color(0xFF94A3B8),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Gender
                          DropdownButtonFormField<String>(
                            value: gender,
                            decoration: _buildInputDecoration('Gender', Icons.person_outline),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Male')),
                              DropdownMenuItem(value: 'female', child: Text('Female')),
                            ],
                            onChanged: (v) => setState(() => gender = v),
                            validator: (v) => v == null || v.isEmpty ? 'Gender is required' : null,
                          ),
                        ],
                      ),
                    ),

                    // Family Section (Only for parents)
                    if (widget.isParent) ...[
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        title: 'Family Information',
                        child: Column(
                          children: [
                            // Family Avatar
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _showFamilyAvatarPicker,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FE),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF0EA5E9),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: familyAvatar != null && familyAvatar!.isNotEmpty
                                          ? Image.asset(
                                              familyAvatar!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.family_restroom,
                                                  size: 30,
                                                  color: Color(0xFF64748B),
                                                );
                                              },
                                            )
                                          : const Icon(
                                              Icons.family_restroom,
                                              size: 30,
                                              color: Color(0xFF64748B),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Family Avatar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A202C),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to change family avatar',
                                        style: TextStyle(
                                          color: const Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Email
                            TextFormField(
                              controller: emailController,
                              decoration: _buildInputDecoration('Email', Icons.email_outlined),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Email is required' : null,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Family Name
                            TextFormField(
                              controller: familyNameController,
                              decoration: _buildInputDecoration('Family Name', Icons.home_outlined),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Family name is required' : null,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0EA5E9),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF0EA5E9), size: 20),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}