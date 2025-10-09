import 'package:flutter/material.dart';
import 'package:foxxhealth/core/constants/user_profile_constants.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/loginScreen/login_screen.dart';
import 'package:foxxhealth/features/presentation/screens/profile/update_password_screen.dart';
import 'package:foxxhealth/features/presentation/screens/profile/privacy_policy_screen.dart';
import 'package:foxxhealth/features/presentation/screens/profile/den_privacy_screen.dart';
import 'package:foxxhealth/core/utils/app_storage.dart';
import 'package:foxxhealth/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:foxxhealth/features/presentation/screens/splash/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  
  String? _profileIconUrl;
  bool _hasProfileIcon = false;
  bool _isLoadingProfileIcon = false;
  
  // User profile data
  String? _userName;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _signOut() async {
    try {
      // Show confirmation dialog
      final shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sign Out'),
              ),
            ],
          );
        },
      );

      if (shouldSignOut == true) {
        // Clear all storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        GetStorage().erase();
        
        // Clear AppStorage
        AppStorage.clearCredentials();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to splash screen and clear all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfileIcon = true;
    });

    try {
      final token = AppStorage.accessToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final apiClient = ApiClient();
      final response = await apiClient.get(
        '/api/v1/accounts/me',
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;
        
        setState(() {
          _userName = userData['user_name'];
          _gender = userData['gender'];
          
          // Handle profile icon
          final profileIconUrl = userData['profile_icon_url'];
          if (profileIconUrl != null && profileIconUrl.isNotEmpty) {
            _hasProfileIcon = true;
            _profileIconUrl = profileIconUrl;
          } else {
            _hasProfileIcon = false;
            _profileIconUrl = null;
          }
          
          _isLoadingProfileIcon = false;
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _isLoadingProfileIcon = false;
        // Fallback to UserProfileConstants if API fails
        _userName = UserProfileConstants.getDisplayName();
      });
    }
  }


  String _getFullImageUrl(String imageUrl) {
    // If the URL is already a full URL, return it as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // If it's a relative path, prepend the base URL
    return 'https://fastapi-backend-v2-788993188947.us-central1.run.app/$imageUrl';
  }

  String _getGenderPronouns(String? gender) {
    if (gender == null || gender.isEmpty) {
      return 'she/her'; // Default fallback
    }
    
    switch (gender.toLowerCase()) {
      case 'female':
      case 'woman':
      case 'f':
        return 'she/her';
      case 'male':
      case 'man':
      case 'm':
        return 'he/him';
      case 'non-binary':
      case 'nonbinary':
      case 'nb':
        return 'they/them';
      default:
        return 'she/her'; // Default fallback
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    'Update Profile Picture',
                    style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                      color: AppColors.primary01,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Camera option
                  _buildBottomSheetOption(
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.camera);
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Gallery option
                  _buildBottomSheetOption(
                    icon: Icons.photo_library,
                    title: 'Choose from Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(ImageSource.gallery);
                    },
                  ),
                  
                  if (_hasProfileIcon) ...[
                    const SizedBox(height: 12),
                    
                    // Delete option (only show if user has a profile icon)
                    _buildBottomSheetOption(
                      icon: Icons.delete,
                      title: 'Remove Photo',
                      onTap: () {
                        Navigator.pop(context);
                        _deleteProfileIcon();
                      },
                      isDestructive: true,
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.amethyst,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                color: isDestructive ? Colors.red : AppColors.primary01,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoadingProfileIcon = true;
        });

        final result = await _uploadProfileIcon(image.path);
        
        if (result != null) {
          // Reload complete profile data
          await _loadUserProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload profile picture. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfileIcon = false;
        });
      }
    }
  }

  Future<String?> _uploadProfileIcon(String imagePath) async {
    try {
      final token = AppStorage.accessToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final apiClient = ApiClient();
      
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: 'profile_icon.jpg',
        ),
      });

      final response = await apiClient.dio.post(
        '/api/v1/accounts/me/profile-icon/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['profile_icon_url'] ?? 
               responseData['url'] ?? 
               responseData['image_url'];
      } else {
        throw Exception('Failed to upload profile icon');
      }
    } catch (e) {
      print('Error uploading profile icon: $e');
      rethrow;
    }
  }

  Future<void> _deleteProfileIcon() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Profile Picture'),
          content: const Text('Are you sure you want to remove your profile picture?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _isLoadingProfileIcon = true;
      });

      try {
        final token = AppStorage.accessToken;
        if (token == null) {
          throw Exception('No authentication token found');
        }

        final apiClient = ApiClient();
        final response = await apiClient.delete(
          '/api/v1/accounts/me/profile-icon',
        );

        if (response.statusCode == 200) {
          // Reload complete profile data
          await _loadUserProfile();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture removed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to delete profile icon');
        }
      } catch (e) {
        print('Error deleting profile icon: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing profile picture: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingProfileIcon = false;
          });
        }
      }
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Account',
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete your account?',
                style: AppOSTextStyles.osMd.copyWith(
                  color: AppColors.primary01,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All your data, including:',
                style: AppOSTextStyles.osMd.copyWith(
                  color: AppColors.davysGray,
                ),
              ),
              const SizedBox(height: 8),
              _buildWarningItem('• Health records and symptoms'),
              _buildWarningItem('• Profile information'),
              _buildWarningItem('• Account settings'),
              _buildWarningItem('• All associated data'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action is permanent and irreversible.',
                        style: AppOSTextStyles.osSmSemiboldBody.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppOSTextStyles.osMdSemiboldLabel.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete Account',
                style: AppOSTextStyles.osMdSemiboldLabel.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        text,
        style: AppOSTextStyles.osMd.copyWith(
          color: AppColors.davysGray,
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.amethyst),
              ),
              const SizedBox(height: 16),
              Text(
                'Deleting your account...',
                style: AppOSTextStyles.osMd.copyWith(
                  color: AppColors.primary01,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we process your request.',
                style: AppOSTextStyles.osMd.copyWith(
                  color: AppColors.davysGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    try {
      final token = AppStorage.accessToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final apiClient = ApiClient();
      final response = await apiClient.delete(
        '/api/v1/accounts/me/hard',
      );

      if (response.statusCode == 200) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Clear all storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        GetStorage().erase();
        
        // Clear AppStorage
        AppStorage.clearCredentials();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // Navigate to splash screen and clear all previous routes
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            ),
            (route) => false,
          );
        }
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
   
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Account',
                      style: AppHeadingTextStyles.h2.copyWith(
                        color: AppColors.primary01,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _signOut();
                      },
                      child: Text(
                        'Sign Out',
                        style: AppOSTextStyles.osMdSemiboldLabel.copyWith(
                          color: AppColors.amethyst,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // User Profile Section
                _buildUserProfileCard(),
                const SizedBox(height: 32),

                // Settings Section
                Text(
                  'Settings',
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Settings Items
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSettingsItem(
                          icon: Icons.lock_outline,
                          title: 'Update Password',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const UpdatePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsItem(
                          icon: Icons.share,
                          title: 'Den Privacy',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DenPrivacyScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // _buildSettingsItem(
                        //   icon: Icons.star,
                        //   title: 'My subscription',
                        //   onTap: () {
                        //     // TODO: Navigate to subscription screen
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       const SnackBar(
                        //         content: Text('Subscription functionality coming soon'),
                        //         backgroundColor: Colors.blue,
                        //       ),
                        //     );
                        //   },
                        // ),
                        const SizedBox(height: 12),
                        _buildSettingsItem(
                          icon: Icons.person_remove,
                          title: 'Delete my account',
                          onTap: () {
                            _showDeleteAccountConfirmation();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Privacy Policy Link
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Privacy Policy',
                      style: AppOSTextStyles.osMdSemiboldLabel.copyWith(
                        color: AppColors.amethyst,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return GestureDetector(
      onTap: _showImagePickerBottomSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration2,
        child: Row(
          children: [
            // Profile Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.mauve50,
                  backgroundImage: _hasProfileIcon && _profileIconUrl != null
                      ? NetworkImage(_getFullImageUrl(_profileIconUrl!))
                      : null,
                  child: _hasProfileIcon && _profileIconUrl != null
                      ? null
                      : _isLoadingProfileIcon
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.amethyst),
                            )
                          : Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.amethyst,
                            ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.amethyst,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: _isLoadingProfileIcon
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  _userName ?? UserProfileConstants.getDisplayName(),
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getGenderPronouns(_gender),
                  style: AppOSTextStyles.osMd.copyWith(
                    color: AppColors.davysGray,
                  ),
                ),
                ],
              ),
            ),
            
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.amethyst,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: AppColors.glassCardDecoration2,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.amethyst.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.amethyst,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                  color: AppColors.primary01,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.amethyst,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false, () {
            Navigator.of(context).pop();
          }),
          _buildNavItem(Icons.assignment, 'My Prep', false, () {
            // TODO: Navigate to My Prep
          }),
          _buildNavItem(Icons.timeline, 'Tracker', false, () {
            // TODO: Navigate to Tracker
          }),
          _buildNavItem(Icons.search, 'Insight', false, () {
            // TODO: Navigate to Insight
          }),
       
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary01 : AppColors.gray600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
              color: isActive ? AppColors.primary01 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
