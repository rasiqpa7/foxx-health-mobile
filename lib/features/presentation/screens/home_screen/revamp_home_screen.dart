import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foxxhealth/core/constants/user_profile_constants.dart';
import 'package:foxxhealth/core/network/api_client.dart';
import 'package:foxxhealth/core/utils/app_storage.dart';
import 'package:foxxhealth/features/data/models/appointment_companion_model.dart';
import 'package:foxxhealth/features/presentation/cubits/appointment_companion/appointment_companion_cubit.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/view/appointment_companion_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/view/appointment_flow.dart';
import 'package:foxxhealth/features/presentation/screens/home_screen/no_symptom_dialog.dart';
import 'package:foxxhealth/features/presentation/screens/premiumScreen/premium_overlay.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/screens/my_prep/my_prep_screen.dart';
import 'package:foxxhealth/features/presentation/screens/profile/profile_screen.dart';
import 'package:foxxhealth/features/presentation/screens/health_tracker/health_tracker_screen.dart';
import 'package:foxxhealth/features/data/models/banner_model.dart';
import 'package:foxxhealth/features/presentation/cubits/banner/banner_cubit.dart';
import 'package:foxxhealth/features/presentation/widgets/banner_carousel.dart';
import 'package:foxxhealth/features/presentation/screens/health_profile/health_profile_screen.dart';
import 'package:foxxhealth/features/presentation/screens/feedback/index.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/create_appointment_intro_screen.dart';

class RevampHomeScreen extends StatefulWidget {
  const RevampHomeScreen({Key? key}) : super(key: key);
  @override
  State<RevampHomeScreen> createState() => _RevampHomeScreenState();
}

class _RevampHomeScreenState extends State<RevampHomeScreen> {
  List<BannerData> _banners = [];
  bool _isLoadingBanners = true;
  String? _bannerError;
  String? _userName;
  List<dynamic> _recentAppointments = [];
  List<AppointmentCompanion> _filteredCompanions = [];
  List<AppointmentCompanion> _companions = [];
  bool _isLoading = true;
  String? _error;

  final AppointmentCompanionCubit _service = AppointmentCompanionCubit();

  // Sort functionality
  String _selectedSortOption = 'Date updated';
  final List<String> _sortOptions = [
    'Date created',
    'Date updated',
    'Appointment date'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRecentItems();
    _loadAppointmentCompanions();
    _loadBanners();
  }

  Future<void> _loadAppointmentCompanions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _service.getAppointmentCompanions();
      setState(() {
        _companions = response.companions;
        _filteredCompanions = _sortCompanions(_companions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<AppointmentCompanion> _sortCompanions(
      List<AppointmentCompanion> companions) {
    final sortedList = List<AppointmentCompanion>.from(companions);

    switch (_selectedSortOption) {
      case 'Date created':
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Date updated':
        sortedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'Appointment date':
        sortedList.sort((a, b) => b.lastPausedAt.compareTo(a.lastPausedAt));
        break;
    }

    return sortedList;
  }

  Future<void> _loadBanners() async {
    try {
      setState(() {
        _isLoadingBanners = true;
        _bannerError = null;
      });

      final bannerCubit = BannerCubit();
      final bannerResponse = await bannerCubit.getBanners();
      setState(() {
        _banners = bannerResponse.allBanners;
        _isLoadingBanners = false;
      });
    } catch (e) {
      setState(() {
        _bannerError = e.toString();
        _isLoadingBanners = false;
      });
    }
  }

  void _onBannerTap(BannerData banner) {
    // Handle banner tap based on type
    switch (banner.type) {
      case 'upsell':
        _showPremiumOverlay();
        break;
      case 'get_to_know_me':
        _showQuestionDialog(banner);
        break;
      default:
        // Handle other banner types
        break;
    }
  }

  void _showPremiumOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.amethystViolet.withOpacity(0.97),
        ),
        child: const PremiumOverlay(),
      ),
    );
  }

  void _showQuestionDialog(BannerData banner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(banner.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (banner.questionText != null) Text(banner.questionText!),
            if (banner.answers != null) ...[
              const SizedBox(height: 16),
              ...banner.answers!.answerOptions.map(
                (option) => CheckboxListTile(
                  title: Text(option.optionText),
                  value: false,
                  onChanged: (value) {
                    // Handle option selection
                  },
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle submission
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserProfile() async {
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
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        // Fallback to UserProfileConstants if API fails
        _userName = UserProfileConstants.getDisplayName();
      });
    }
  }

  Future<void> _loadRecentItems() async {
    try {
      final token = AppStorage.accessToken;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final apiClient = ApiClient();
      final response =
          await apiClient.get('/api/v1/appointment-companions/recent'
              // '/api/v1/appointment-companions/me',
              );

      if (response.statusCode == 200 && response.data != null) {
        final recentData = response.data;
        print('Recent Data: $recentData');
        setState(() {
          _recentAppointments = recentData;
        });
      } else {
        throw Exception('Failed to load user recent items');
      }
    } catch (e) {
      print('Error loading user recent items: $e');
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM d, yyyy').format(date);
    // return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadBanners,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar with date and icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 10),
                        // Top right icons
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FeedbackPreferencesScreen(),
                                  ),
                                );
                              },
                              child: const CircleAvatar(
                                backgroundColor: AppColors.mauve50,
                                radius: 20,
                                child: Icon(Icons.chat_bubble_outline,
                                    color: AppColors.amethyst, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: const CircleAvatar(
                                backgroundColor: AppColors.mauve50,
                                radius: 20,
                                child: Icon(Icons.person_outline,
                                    color: AppColors.amethyst, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Date
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: AppTypography.labelMdSemibold,
                    ),

                    // Greeting
                    Text(
                      'Hi, $_userName',
                      style: AppTypography.h2,
                    ),
                    const SizedBox(height: 24),
                    // How are you feeling card
                    _buildFeelingCard(context),
                    const SizedBox(height: 16),

                    // Banner Carousel
                    if (_isLoadingBanners)
                      Container(
                        height: 120,
                        decoration: AppColors.glassCardDecoration,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_bannerError != null)
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: AppColors.glassCardDecoration,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.amethystViolet),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load banners',
                                style: AppTypography.bodyMd,
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_banners.isNotEmpty)
                      BannerCarousel(
                        banners: _banners,
                        onBannerTap: _onBannerTap,
                      ),
                    const SizedBox(height: 16),

                    // Create & Health Profile cards
                    Row(
                      children: [
                        Expanded(child: _buildCreateCard(context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildHealthProfileCard()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Items
                    Text('Recent Items',
                        style: AppTypography.h4),
                    const SizedBox(height: 12),
                    // Recent Item Cards
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                          //ListView(
                          itemCount: _recentAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _recentAppointments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AppointmentCompanionScreen(
                                        appointmentData: {
                                          'companionId':
                                              _filteredCompanions[index].id,
                                          'status':
                                              _filteredCompanions[index].status,
                                          'createdAt':
                                              _filteredCompanions[index]
                                                  .createdAt
                                                  .toIso8601String(),
                                          'updatedAt':
                                              _filteredCompanions[index]
                                                  .updatedAt
                                                  .toIso8601String(),
                                        },
                                      ),
                                      // onRefresh: _loadAppointmentCompanions,
                                      // ),
                                    ),
                                  );
                                },
                                child: _RecentItemCard(
                                  title: appointment['title'],
                                  lastEdited: _formatDate(
                                      appointment['last_updated_at']),
                                ),
                              ),
                            );
                          }),
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

  Widget _buildFeelingCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle feeling card tap
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.mauve50,
                  child: SvgPicture.asset(
                    'assets/svg/home/home-health-tracker.svg',
                    width: 48,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'How are you feeling?',
                  style: AppTypography.h4,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true, // allows full-height
                      backgroundColor:
                          Colors.transparent, // so your custom container shows
                      builder: (context) => const NoSymptomsDialog(),
                      // symptoms: _userRecentSymptoms, // pass your list
                      // date: _selectedDate,
                      // ),
                    );
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => const NoSymptomsDialog(),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: AppColors.glassCardDecoration.copyWith(
                      color: AppColors.gray100.withOpacity(0.7),
                    ),
                    child: Center(
                      child: Text(
                        "Nothing to report today",
                        style: AppTypography.titleMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HealthTrackerScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: AppColors.glassCardDecoration.copyWith(
                      color: AppColors.gray100.withOpacity(0.7),
                    ),
                    child: Center(
                      child: Text(
                        "Log my symptoms",
                        style: AppTypography.titleMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const CreateAppointmentIntroScreen(),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/home/home-create.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 12),
                Text('Create', style: AppTypography.titleXl),
              ],
            ),
            const SizedBox(height: 4),
            Text('Appointment companion', style: AppTypography.bodyMd),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthProfileCard() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HealthProfileScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svg/home/home-health-profile.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Health Profile',
                    style: AppTypography.titleXl,
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Help us get to know you',
              style: AppTypography.bodyMd,
              softWrap: true,
            ),  
          ],
        ),
      ),
    );
  }
}

class _RecentItemCard extends StatelessWidget {
  final String title;
  // final String date;
  final String lastEdited;

  const _RecentItemCard({
    required this.title,
    // required this.date,
    required this.lastEdited,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.glassCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLg),
          const SizedBox(height: 4),
          Text('Last Edited: $lastEdited',
              style: AppTypography.bodyMdSemibold),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

