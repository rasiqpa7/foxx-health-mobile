// Updated by Joy — homescreen update - not final
import 'package:flutter/material.dart';
import 'package:foxxhealth/core/constants/user_profile_constants.dart';
import 'package:foxxhealth/features/presentation/screens/premiumScreen/premium_overlay.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/screens/my_prep/my_prep_screen.dart';
import 'package:foxxhealth/features/presentation/screens/my_prep/appointment_companion_details_screen.dart';
import 'package:foxxhealth/features/presentation/screens/profile/profile_screen.dart';
import 'package:foxxhealth/features/presentation/screens/health_tracker/health_tracker_screen.dart';
import 'package:foxxhealth/features/data/models/banner_model.dart';
import 'package:foxxhealth/features/presentation/cubits/banner/banner_cubit.dart';
import 'package:foxxhealth/features/presentation/widgets/banner_carousel.dart';
import 'package:foxxhealth/features/presentation/screens/health_profile/health_profile_screen.dart';
import 'package:foxxhealth/features/presentation/screens/feedback/index.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:flutter_svg/svg.dart';

class RevampHomeScreen extends StatefulWidget {
  const RevampHomeScreen({Key? key}) : super(key: key);
  @override
  State<RevampHomeScreen> createState() => _RevampHomeScreenState();
}

class _RevampHomeScreenState extends State<RevampHomeScreen> {
  List<BannerData> _banners = [];
  bool _isLoadingBanners = true;
  String? _bannerError;

  @override
  void initState() {
    super.initState();
    _loadBanners();
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
            if (banner.questionText != null)
              Text(banner.questionText!),
            if (banner.answers != null) ...[
              const SizedBox(height: 16),
              ...banner.answers!.answerOptions.map((option) => 
                CheckboxListTile(
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                                    builder: (context) => const FeedbackPreferencesScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
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
                              child: CircleAvatar(
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
                      'Wednesday, Apr 17',
                      style: AppTypography.labelMd,
                    ),
                    
                    // Greeting
                    Text(
                      'Hi, ${UserProfileConstants.getDisplayName()}',
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
                              Icon(Icons.error_outline, color: AppColors.amethystViolet),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load banners',
                                style: AppTypography.bodySm,
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

                 

                    // Create & Health Profile cards (equal height, top-aligned)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildCreateCard(context)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildHealthProfileCard()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Items
                    Text('Recent Items',
                        style: AppTypography.titleMd),
                    const SizedBox(height: 12),

                    // Recent Item Cards
                    Column(
                      children: [
                        _RecentItemCard(
                          title: 'Yearly Check Up',
                          date: 'Mar 2025',
                          lastEdited: 'Apr 13, 2025',
                        ),
                        const SizedBox(height: 12),
                        _RecentItemCard(
                          title: 'Appointment prep with PCP',
                          date: 'Mar 2025',
                          lastEdited: 'Apr 13, 2025',
                        ),
                      ],
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
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: AppColors.glassCardDecoration.copyWith(
                    color: AppColors.gray100.withOpacity(0.7),
                  ),
                    child: Center(
                      child: Text(
                        "I feel good, no symptoms",
                        style: AppTypography.titleMd,
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
          builder: (context) => const AppointmentCompanionDetailsScreen(origin: 'home'),
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
  final String date;
  final String lastEdited;

  const _RecentItemCard({
    required this.title,
    required this.date,
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
          Text(title,
              style: AppTypography.titleMd
                  .copyWith(color: AppColors.primary01)),
          const SizedBox(height: 4),
          Text('Last Edited: $lastEdited',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.primary01)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Date',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.primary01)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: AppColors.amethyst),
                    const SizedBox(width: 4),
                    Text(date,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.primary01)),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: 18, color: AppColors.amethyst),
            ],
          ),
        ],
      ),
    );
  }
}
