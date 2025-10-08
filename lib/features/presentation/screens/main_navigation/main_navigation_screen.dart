// Updated by Joy — homescreen update - not final
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foxxhealth/features/presentation/cubits/health_tracker/health_tracker_cubit.dart';
import 'package:foxxhealth/features/presentation/cubits/profile/profile_cubit.dart';
import 'package:foxxhealth/features/presentation/screens/health_tracker/health_tracker_screen.dart';
import 'package:foxxhealth/features/presentation/screens/main_navigation/day_symptom_dialog.dart';
// import 'package:foxxhealth/features/presentation/screens/main_navigation/day_symptom_screen.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/screens/den/den_screen.dart';
import 'package:foxxhealth/features/presentation/screens/home_screen/revamp_home_screen.dart';
import 'package:foxxhealth/features/presentation/screens/my_prep/my_prep_screen.dart';
import 'package:foxxhealth/features/presentation/screens/health_tracker/symptom_details_bottom_sheet.dart';
import 'package:foxxhealth/features/presentation/screens/health_tracker/symptom_insights_screen.dart';
import 'package:foxxhealth/features/presentation/cubits/symptom_search/symptom_search_cubit.dart';
import 'package:foxxhealth/features/data/models/health_tracker_model.dart';
import 'package:foxxhealth/features/data/models/symptom_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final bool _showDenTab = false;

  List<Widget> get _visibleScreens =>
      _showDenTab ? _screens : _screens.take(4).toList();

  List<String> get _visibleTabLabels =>
      _showDenTab ? _tabLabels : _tabLabels.take(4).toList();

  List<Map<String, String>> get _visibleTabIconAssets =>
      _showDenTab ? _tabIconAssets : _tabIconAssets.take(4).toList();
  final List<Widget> _screens = [
    const HomeTab(),
    const MyPrepTab(),
    const TrackerTab(),
    const InsightTab(),
    const DenTab(),
  ];
  final List<String> _tabLabels = [
    'Home',
    'My Prep',
    'Tracker',
    'Insight',
    'The Den',
  ];
  // Active/Inactive SVG icon assets for tabs
  final List<Map<String, String>> _tabIconAssets = [
    {
      'inactive': 'assets/svg/main_nav_tabs/home_off.svg',
      'active': 'assets/svg/main_nav_tabs/home_on.svg',
    },
    {
      'inactive': 'assets/svg/main_nav_tabs/myprep_off.svg',
      'active': 'assets/svg/main_nav_tabs/myprep_on.svg',
    },
    {
      'inactive': 'assets/svg/main_nav_tabs/tracker_off.svg',
      'active': 'assets/svg/main_nav_tabs/tracker_on.svg',
    },
    {
      'inactive': 'assets/svg/main_nav_tabs/insight_off.svg',
      'active': 'assets/svg/main_nav_tabs/insight_on.svg',
    },
    {
      'inactive': 'assets/svg/main_nav_tabs/den_off.svg',
      'active': 'assets/svg/main_nav_tabs/den_on.svg',
    },
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileCubit>().fetchProfile();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index >= _visibleScreens.length) return;
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => SymptomSearchCubit()),
      ],
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading profile: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Foxxbackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _visibleScreens,
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 32, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _visibleTabLabels.length,
          (index) => _buildNavItem(
            index,
            _visibleTabLabels[index],
            _currentIndex == index,
            () => _onTabTapped(index),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, String label, bool isActive, VoidCallback onTap) {
    final assetPath = isActive
        ? _visibleTabIconAssets[index]['active']!
        : _visibleTabIconAssets[index]['inactive']!;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 28,
            height: 28,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: isActive
                ? AppTypography.labelSmBold.copyWith(
                    fontWeight: FontWeight.w700,
                    fontVariations: const [ui.FontVariation('wght', 700)],
                  )
                : AppTypography.labelSmSemibold.copyWith(
                    color: AppColors.textSecondary,
                    fontVariations: const [ui.FontVariation('wght', 600)],
                  ),
          ),
        ],
      ),
    );
  }
}

// Tab Screen Widgets
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RevampHomeScreen();
  }
}

class MyPrepTab extends StatelessWidget {
  const MyPrepTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyPrepScreen();
  }
}

class TrackerTab extends StatefulWidget {
  const TrackerTab({Key? key}) : super(key: key);

  @override
  State<TrackerTab> createState() => _TrackerTabState();
}

class _TrackerTabState extends State<TrackerTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _symptomController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _feelingGood = true;
  String? _selectedRecentSymptom;

  // Health tracker data
  List<HealthTrackerResponse> _healthTrackers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealthTrackers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthTrackers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final symptomCubit = context.read<SymptomSearchCubit>();
      final healthTrackersData =
          await symptomCubit.getHealthTrackersByDate(_selectedDate);

      setState(() {
        _healthTrackers = healthTrackersData
            .map((data) => HealthTrackerResponse.fromJson(data))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  // My Health - Symptoms Section
                  Text(
                    'My Health',
                    style: AppHeadingTextStyles.h2.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Symptoms',
                    style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feeling Good Card
                  _buildFeelingGoodCard(),
                  const SizedBox(height: 24),

                  // Recent Symptoms Section
                  Text(
                    'Recent symptoms',
                    style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recent Symptoms Cards
                  _buildRecentSymptomsCards(),
                  const SizedBox(height: 24),

                  // Add Symptoms Section
                  // Text(
                  //   'Add symptoms',
                  //   style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                  //     color: AppColors.primary01,
                  //   ),
                  // ),
                  // const SizedBox(height: 16),

                  // // Search Bar
                  // _buildSearchBar(),
                  // const SizedBox(height: 12),

                  // // Symptom Input Field
                  // _buildSymptomInputField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      children: [
        // Main Date Button
        GestureDetector(
          onTap: () {
            _showDatePicker();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: AppColors.glassCardDecoration,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.amethyst,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_selectedDate),
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Date Cards
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().subtract(Duration(days: 3 - index));
              final isSelected = date.day == _selectedDate.day;
              final dayAbbreviation = _getDayAbbreviation(date.weekday);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  _loadHealthTrackers();
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.amethyst
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayAbbreviation,
                        style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.primary01,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.primary01,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeelingGoodCard() {
    // Check if there are any active symptoms for the selected date
    final activeSymptoms = _healthTrackers
        .where((tracker) => tracker.isActive)
        .expand((tracker) => tracker.selectedSymptoms)
        .toList();

    final hasSymptoms = activeSymptoms.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppColors.glassCardDecoration,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _feelingGood = !_feelingGood;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _feelingGood ? AppColors.amethyst : Colors.transparent,
                border: Border.all(
                  color: AppColors.amethyst,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _feelingGood
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasSymptoms
                  ? 'Experiencing: ${activeSymptoms.take(2).map((s) => s.info.name).join(', ')}'
                  : 'I feel good, no symptoms',
              style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                color: AppColors.primary01,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (activeSymptoms.isNotEmpty) {
                try {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading symptom details...'),
                      backgroundColor: Colors.blue,
                    ),
                  );

                  // Get the symptom cubit to call API
                  final symptomCubit = context.read<SymptomSearchCubit>();

                  // Convert SelectedSymptom to Map<String, dynamic> format
                  final symptomsData = activeSymptoms.map((symptom) {
                    // Check if we have existing details for this symptom in the cubit
                    final existingDetails =
                        symptomCubit.symptomDetails[symptom.info.id];

                    return {
                      'id': symptom.info.id,
                      'name': symptom.info.name,
                      'filter_grouping': symptom.info.filterGrouping,
                      'body_parts': symptom.info.bodyParts,
                      'tags': symptom.info.tags,
                      'visual_insights': symptom.info.visualInsights,
                      'question_map': symptom.info.questionMap,
                      'need_help_popup': symptom.needHelpPopup,
                      'notes': symptom.notes,
                      // Include existing answers if they exist in the symptom details
                      'answers': existingDetails?['answers'] ?? {},
                    };
                  }).toList();

                  // Optionally fetch additional details from API for each symptom
                  final enhancedSymptomsData = <Map<String, dynamic>>[];
                  for (final symptom in symptomsData) {
                    final symptomId = symptom['id'] as String;
                    final apiDetails =
                        await symptomCubit.getSymptomDetails(symptomId);

                    if (apiDetails != null) {
                      // Merge API data with existing data
                      final enhancedSymptom =
                          Map<String, dynamic>.from(symptom);
                      enhancedSymptom.addAll(apiDetails);
                      enhancedSymptomsData.add(enhancedSymptom);
                    } else {
                      // Use existing data if API call fails
                      enhancedSymptomsData.add(symptom);
                    }
                  }

                  // Show the symptom details bottom sheet
                  if (mounted) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SymptomDetailsBottomSheet(
                        symptoms: enhancedSymptomsData,
                        onDetailsSaved: (symptomDetails) {
                          print('Symptom details saved: $symptomDetails');

                          // Store the details back in the cubit for future use
                          for (final detail in symptomDetails) {
                            final symptomId = detail['symptom']['id'] as String;
                            symptomCubit.addSymptomWithDetails(
                              // Create a temporary Symptom object for the cubit
                              Symptom(
                                id: symptomId,
                                name: detail['symptom']['name'] as String,
                                filterGrouping: List<String>.from(
                                    detail['symptom']['filter_grouping'] ?? []),
                                bodyParts: List<String>.from(
                                    detail['symptom']['body_parts'] ?? []),
                                tags: List<String>.from(
                                    detail['symptom']['tags'] ?? []),
                                visualInsights: List<String>.from(
                                    detail['symptom']['visual_insights'] ?? []),
                                questionMap: List<Map<String, dynamic>>.from(
                                    detail['symptom']['question_map'] ?? []),
                                notes: detail['notes'] as String? ?? '',
                                needHelpPopup: detail['symptom']
                                        ['need_help_popup'] as bool? ??
                                    false,
                              ),
                              detail,
                            );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Symptom details saved successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading symptom details: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No symptoms to show details for'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('details'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSymptomsCards() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration,
        child: Text(
          'Error loading symptoms: $_error',
          style: AppOSTextStyles.osMd.copyWith(color: Colors.red),
        ),
      );
    }

    // Get all symptoms from health trackers
    final allSymptoms = _healthTrackers
        .expand((tracker) => tracker.selectedSymptoms)
        .map((symptom) => symptom.info.name)
        .toSet()
        .toList();

    if (allSymptoms.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: AppColors.glassCardDecoration,
        child: Text(
          'No symptoms recorded for this date',
          style: AppOSTextStyles.osMd.copyWith(color: AppColors.davysGray),
        ),
      );
    }

    return Column(
      children: allSymptoms.take(5).map((symptom) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: AppColors.glassCardDecoration,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRecentSymptom =
                        _selectedRecentSymptom == symptom ? null : symptom;
                  });
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _selectedRecentSymptom == symptom
                        ? AppColors.amethyst
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.amethyst,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: _selectedRecentSymptom == symptom
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  symptom,
                  style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                    color: AppColors.primary01,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.amethyst,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search symptoms',
                hintStyle: AppOSTextStyles.osMd.copyWith(
                  color: AppColors.gray400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppOSTextStyles.osMd.copyWith(
                color: AppColors.primary01,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomInputField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _symptomController,
        decoration: InputDecoration(
          hintText: 'Enter symptom name',
          hintStyle: AppOSTextStyles.osMd.copyWith(
            color: AppColors.gray400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: AppOSTextStyles.osMd.copyWith(
          color: AppColors.primary01,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == today) {
      return 'Today, ${_formatDateString(date)}';
    } else if (selectedDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_formatDateString(date)}';
    } else if (selectedDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatDateString(date)}';
    } else {
      return _formatDateString(date);
    }
  }

  String _formatDateString(DateTime date) {
    const months = [
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
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['M', 'TU', 'W', 'TH', 'F', 'S', 'SU'];
    return days[weekday - 1];
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.amethyst,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primary01,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadHealthTrackers(); // Reload data for new date
    }
  }
}

class InsightTab extends StatefulWidget {
  const InsightTab({Key? key}) : super(key: key);

  @override
  State<InsightTab> createState() => _InsightTabState();
}

class _InsightTabState extends State<InsightTab> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  // Insight data
  Map<DateTime, List<Symptom>> _symptomsOfTheMonth = {};
  List<Symptom> _tenRecentSymptoms = [];
  List<String> _userRecentSymptoms = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getSymptomsForMonth();
    _getUserSymptoms();
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section with Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // Spacer for balance
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.mauve50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.amethyst,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.mauve50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: AppColors.amethyst,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title Section
                  Text(
                    'Symptom Insights',
                    style: AppHeadingTextStyles.h2.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Symptom Insights helps you spot patterns and changes over time, so you can feel more informed and in control.',
                    style: AppOSTextStyles.osMd.copyWith(
                      color: AppColors.davysGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Calendar Section
                  _buildCalendarSection(),
                  const SizedBox(height: 32),

                  // Insights by Symptom Section
                  Text(
                    'Insights by symptom',
                    style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _symptomsOfTheMonth.isEmpty
                          ? Column(
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  "You have not recorded any symptom",
                                  style: AppOSTextStyles.osMd.copyWith(
                                    color: AppColors.davysGray,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HealthTrackerScreen(),
                                      ),
                                    )
                                        .then((_) {
                                      _getSymptomsForMonth();
                                      _getUserSymptoms();
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 40,
                                    decoration:
                                        AppColors.glassCardDecoration.copyWith(
                                      color: AppColors.amethystViolet,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Log Symptoms",
                                        style: AppOSTextStyles.osMdSemiboldTitle
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _buildSymptomInsightsList(),
                    ],
                  ),

                  const SizedBox(height: 100), // Bottom padding for navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.glassCardDecoration,
      child: Column(
        children: [
          // Month Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatMonthYear(_currentMonth),
                style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                  color: AppColors.primary01,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month - 1, 1);
                        _getSymptomsForMonth();
                        _getUserSymptoms();
                      });
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.amethyst,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month + 1, 1);
                        _getSymptomsForMonth();
                        _getUserSymptoms();
                      });
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.amethyst,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Su', 'M', 'Tu', 'W', 'Th', 'F', 'Sa'].map((day) {
              return Text(
                day,
                style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
                  color: AppColors.davysGray,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  //symptom colors map
  final Map<int, Color> symptomColors = {
    0: AppColors.insightPurple,
    1: AppColors.insightTeal,
    2: AppColors.insightCoralPink,
    3: AppColors.insightMintGreen,
    4: AppColors.insightYellow,
    5: AppColors.insightCoolNavy,
    6: AppColors.insightOliveGreen,
    7: AppColors.insightGray,
    8: AppColors.insightIceBlue,
    9: AppColors.insightDarkRed,
    10: AppColors.insightOrange,
    11: AppColors.mauve,
    12: AppColors.insightEmerald,
    13: AppColors.insightPeachPastel,
    14: AppColors.insightLakeBlue,
    15: AppColors.insightHotPink,
    16: AppColors.insightRed,
    17: AppColors.insightLimeGreen,
    18: AppColors.insightCamelBrown,
    19: AppColors.insightBrightBlue,
    20: AppColors.insightMintGreen,
    21: AppColors.insightBrown,
    22: AppColors.insightBubblegumPink,
    23: AppColors.insightPineGreen,
    24: AppColors.insightColumbiaBlue,
    25: AppColors.insightNeonGreen,
    26: AppColors.insightBrightCayan,
    27: AppColors.foxxWhite,
    28: AppColors.insightSageGreen,
    29: AppColors.insightMustard
  };

// making symptom color dots
  Widget buildSymptomDots(List<Symptom> symptoms) {
    // Take the 10 most recent symptoms
    final recentSymptoms = symptoms.length > 10
        ? symptoms.sublist(symptoms.length - 10)
        : symptoms;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: recentSymptoms.asMap().entries.map((entry) {
        final index = entry.key;

        // Use index from the sliced list, not the original one
        final color = symptomColors[index] ?? Colors.grey; // fallback

        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _getSymptomsForMonth() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final symptomCubit = context.read<SymptomSearchCubit>();
      final symptomsMap = await symptomCubit.getSymptomsByMonth(_currentMonth);

      // Flatten into a list with dates
      final allEntries = symptomsMap.entries.expand((entry) {
        final date = entry.key;
        return entry.value.map((s) => MapEntry(date, s));
      }).toList();

      // Sort by date descending
      allEntries.sort((a, b) => b.key.compareTo(a.key));

      // Use a set to track uniqueness (by symptom.id or symptom.name)
      final seen = <String>{};
      final uniqueSymptoms = <Symptom>[];
      // Flatten all symptoms in the month
      final allSymptoms =
          symptomsMap.entries.expand((entry) => entry.value).toList();

      for (final symptom in allSymptoms) {
        if (seen.add(symptom.id)) {
          uniqueSymptoms.add(symptom);
        }
        if (uniqueSymptoms.length == 10) break;
      }

      setState(() {
        _symptomsOfTheMonth = symptomsMap;
        _tenRecentSymptoms = uniqueSymptoms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserSymptoms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final symptomCubit = context.read<SymptomSearchCubit>();
      final symptomsList = await symptomCubit.getAllUserSymptomNames();

      // Sort by date descending
      symptomsList.sort((a, b) => b.compareTo(a));

      // Use a set to track uniqueness (by symptom.id or symptom.name)
      final seen = <String>{};
      final uniqueSymptoms = <String>[];

      for (final symptom in symptomsList) {
        if (seen.add(symptom)) {
          uniqueSymptoms.add(symptom);
        }
        if (uniqueSymptoms.length == 30) break;
      }

      setState(() {
        _userRecentSymptoms = uniqueSymptoms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showSymptomsDialogm(BuildContext context, List<String> symptoms) {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside to dismiss
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7, // 70% of screen
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE9D3FF),
                  Color(0xFFFFE5AA),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  "Symptoms",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E3D48),
                  ),
                ),
                const SizedBox(height: 12),

                // Symptoms List
                Expanded(
                  child: ListView.separated(
                    itemCount: symptoms.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final symptom = symptoms[index];
                      return ListTile(
                        title: Text(symptom),
                        trailing: Checkbox(
                          value: false, // TODO: bind with state
                          onChanged: (val) {},
                          shape: const CircleBorder(), // Circle checkbox
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate total cells needed (including empty cells for days before month starts)
    final totalCells = firstWeekday - 1 + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return Column(
      children: List.generate(weeks, (weekIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (dayIndex) {
            final cellIndex = weekIndex * 7 + dayIndex;
            final dayOfMonth = cellIndex - (firstWeekday - 1) + 1;

            if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
              // Empty cell
              return Container(
                width: 32,
                height: 40,
                margin: const EdgeInsets.all(2),
              );
            }

            final date =
                DateTime(_currentMonth.year, _currentMonth.month, dayOfMonth);
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;
            final symptomsOfTheDay = _symptomsOfTheMonth[date] ?? [];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                  _getUserSymptoms();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // allows full-height
                    backgroundColor:
                        Colors.transparent, // so your custom container shows
                    builder: (context) => DaySymptomsDialog(
                      symptoms: _userRecentSymptoms, // pass your list
                      date: _selectedDate,
                    ),
                  );
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day circle
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.amethyst : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayOfMonth',
                      style: AppOSTextStyles.osSmSemiboldLabel.copyWith(
                        color: isSelected ? Colors.white : AppColors.primary01,
                      ),
                    ),
                  ),

                  // Symptom dots (shown below circle)
                  if (dayOfMonth != 1 && symptomsOfTheDay.isNotEmpty)
                    SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: buildSymptomDots(symptomsOfTheDay),
                  ),
                ],
              ),
              // ),
            );
          }),
        );
      }),
    );
  }

  Widget buildSymptomDotsd(List<Symptom> symptoms) {
    // Take the 10 most recent symptoms
    final recentSymptoms = symptoms.length > 10
        ? symptoms.sublist(symptoms.length - 10)
        : symptoms;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: recentSymptoms.asMap().entries.map((entry) {
        final index = entry.key;

        // Use index from the sliced list, not the original one
        final color = symptomColors[index] ?? Colors.grey; // fallback

        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomInsightsList() {
    final symptoms = _tenRecentSymptoms;

    return Column(
      children: symptoms.asMap().entries.map((entry) {
        final index = entry.key;
        final symptom = entry.value;

        // pick color by index, fallback to gray if > 9
        final color = symptomColors[index] ?? Colors.grey;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SymptomInsightsScreen(symptom: symptom),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: AppColors.glassCardDecoration,
            child: Row(
              children: [
                // // colored circle
                // Container(
                //   width: 24,
                //   height: 24,
                //   decoration: BoxDecoration(
                //     color: color,
                //     shape: BoxShape.circle,
                //   ),
                // ),
                // const SizedBox(width: 12),

                // symptom name
                Expanded(
                  child: Text(
                    symptom.name,
                    style: AppOSTextStyles.osMdSemiboldTitle.copyWith(
                      color: AppColors.primary01,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.amethyst,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
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
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class DenTab extends StatelessWidget {
  const DenTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DenScreen();
  }
}
