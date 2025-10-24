import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/cubits/symptom_search/symptom_search_cubit.dart';
import 'package:foxxhealth/features/data/models/appointment_question_model.dart';
import 'package:foxxhealth/features/data/models/appointment_companion_model.dart';

import 'package:foxxhealth/features/presentation/screens/appointment/widgets/personal_info_review_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/appointment_type_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/care_provider_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/main_reason_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/symptom_selection_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/life_situation_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/journey_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/concern_prioritization_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/symptom_changes_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/communication_preferences_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/care_experience_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/concerns_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/widgets/data_privacy_screen.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/view/appointment_companion_screen.dart';

class AppointmentFlow extends StatefulWidget {
  final VoidCallback? onRefresh;
  
  const AppointmentFlow({super.key, this.onRefresh});

  @override
  State<AppointmentFlow> createState() => _AppointmentFlowState();
}

class _AppointmentFlowState extends State<AppointmentFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // User data collected through the flow
  String? appointmentType;
  String? careProvider;
  String? mainReason;
  List<String> selectedSymptoms = [];
  List<String> lifeSituations = [];
  List<String> journeySteps = [];
  List<String> concernPriorities = [];
  List<String> symptomChanges = [];
  List<String> communicationPreferences = [];
  List<String> careExperiences = [];
  List<String> concerns = [];
  Map<String, String> additionalInfo = {};
  
  // API data
  List<AppointmentQuestion> _appointmentQuestions = [];
  bool _isLoading = true;
  String? _error;
  
  // Next button state
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    _loadAppointmentQuestions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointmentQuestions() async {
    try {
      final symptomCubit = SymptomSearchCubit();
      final questionsData = await symptomCubit.getAppointmentQuestions();
      setState(() {
        _appointmentQuestions = questionsData.map((data) => AppointmentQuestion.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  AppointmentQuestion? _getQuestionByType(String type) {
    try {
      return _appointmentQuestions.firstWhere((q) => q.type == type);
    } catch (e) {
      return null;
    }
  }

  AppointmentCompanionRequest _buildAppointmentCompanionRequest() {
    return AppointmentCompanionRequest(
      typeOfVisitOrExam: appointmentType != null 
          ? CompanionItem(description: appointmentType!, value: appointmentType!.toUpperCase().replaceAll(' ', '_'))
          : null,
      typeOfDoctorProvider: careProvider != null
          ? CompanionItem(description: careProvider!, value: careProvider!.toUpperCase().replaceAll(' ', '_'))
          : null,
      mainReasonForVisit: mainReason != null
          ? CompanionItem(description: mainReason!, value: mainReason!.toUpperCase().replaceAll(' ', '_'))
          : null,
      importantSymptomsToDiscuss: selectedSymptoms.isNotEmpty
          ? selectedSymptoms.map((symptom) => CompanionItem(
              description: symptom,
              value: symptom.toUpperCase().replaceAll(' ', '_'),
            )).toList()
          : null,
      lifeStressorsAffectingHealth: lifeSituations.isNotEmpty
          ? lifeSituations.map((situation) => CompanionItem(
              description: situation,
              value: situation.toUpperCase().replaceAll(' ', '_'),
            )).toList()
          : null,
      journeyWithThisConcern: journeySteps.isNotEmpty
          ? CompanionItem(
              description: journeySteps.first,
              value: journeySteps.first.toUpperCase().replaceAll(' ', '_'),
            )
          : null,
      prioritizeYourConcerns: concernPriorities.isNotEmpty
          ? CompanionItem(
              description: concernPriorities.first,
              value: concernPriorities.first.toUpperCase().replaceAll(' ', '_'),
            )
          : null,
      symptomsBeenChangingOverTime: symptomChanges.isNotEmpty
          ? CompanionItem(
              description: symptomChanges.first,
              value: symptomChanges.first.toUpperCase().replaceAll(' ', '_'),
            )
          : null,
      communicateWithYourHealthcare: communicationPreferences.isNotEmpty
          ? communicationPreferences.map((preference) => CompanionItem(
              description: preference,
              value: preference.toUpperCase().replaceAll(' ', '_'),
            )).toList()
          : null,
      tryingToGetCare: careExperiences.isNotEmpty
          ? careExperiences.map((experience) => CompanionItem(
              description: experience,
              value: experience.toUpperCase().replaceAll(' ', '_'),
            )).toList()
          : null,
      afraidOverlooked: concerns.isNotEmpty
          ? concerns.map((concern) => CompanionItem(
              description: concern,
              value: concern.toUpperCase().replaceAll(' ', '_'),
            )).toList()
          : null,
      status: 'In-Progress',
      lastPausedAt: DateTime.now().toIso8601String(),
      lastPausedPage: 'appointment_companion',
    );
  }

  void _nextPage() {
    if (_currentPage < 12) { // 15 screens total (0-14)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete appointment creation and navigate to companion screen
      _navigateToCompanionScreen();
    }
  }

  Future<void> _navigateToCompanionScreen() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Prepare all collected data
      final Map<String, dynamic> appointmentData = {
        'appointmentType': appointmentType,
        'careProvider': careProvider,
        'mainReason': mainReason,
        'selectedSymptoms': selectedSymptoms,
        'lifeSituations': lifeSituations,
        'journeySteps': journeySteps,
        'concernPriorities': concernPriorities,
        'symptomChanges': symptomChanges,
        'communicationPreferences': communicationPreferences,
        'careExperiences': careExperiences,
        'concerns': concerns,
        'additionalInfo': additionalInfo,
      };

      // Create appointment companion request
      final request = _buildAppointmentCompanionRequest();
      
      // Call API to create appointment companion
      final symptomCubit = SymptomSearchCubit();
      final response = await symptomCubit.createAppointmentCompanion(request.toJson());
      
      // Debug: Print the raw response
      print('🔍 Debug - Raw API response: $response');
      print('🔍 Debug - Response type: ${response.runtimeType}');
      print('🔍 Debug - Response keys: ${response?.keys.toList()}');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response != null && response['companions'] != null && (response['companions'] as List).isNotEmpty) {
        // Add API response to appointment data
        final companion = response['companions'][0];
        
        // Debug: Print the response and companion data
        print('🔍 Debug - Full API response: $response');
        print('🔍 Debug - Companion data: $companion');
        print('🔍 Debug - Companion ID: ${companion['id']}');
        print('🔍 Debug - Companion ID type: ${companion['id'].runtimeType}');
        
        appointmentData['companionId'] = companion['id'];
        appointmentData['companionStatus'] = companion['status'];
        
        print('🔍 Debug - Updated appointmentData: $appointmentData');
        
        // Navigate to companion screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AppointmentCompanionScreen(
                appointmentData: appointmentData,
                onRefresh: widget.onRefresh,
              ),
            ),
          );
        }
      } else if (response != null && response['id'] != null) {
        // Fallback: Handle case where response contains companion data directly
        print('🔍 Debug - Using fallback: response contains companion data directly');
        print('🔍 Debug - Companion ID from direct response: ${response['id']}');
        print('🔍 Debug - Companion ID type: ${response['id'].runtimeType}');
        
        appointmentData['companionId'] = response['id'];
        appointmentData['companionStatus'] = response['status'] ?? 'active';
        
        print('🔍 Debug - Updated appointmentData (fallback): $appointmentData');
        
        // Navigate to companion screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AppointmentCompanionScreen(
                appointmentData: appointmentData,
                onRefresh: widget.onRefresh,
              ),
            ),
          );
        }
      } else {
        // Debug: Print why the condition failed
        print('🔍 Debug - Condition failed:');
        print('🔍 Debug - response != null: ${response != null}');
        print('🔍 Debug - response[companions] != null: ${response?['companions'] != null}');
        print('🔍 Debug - companions is not empty: ${response?['companions'] != null ? (response!['companions'] as List).isNotEmpty : false}');
        
        // Show error message but still navigate to companion screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save appointment companion, but you can still continue'),
              backgroundColor: Colors.orange,
            ),
          );
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AppointmentCompanionScreen(
                appointmentData: appointmentData,
                onRefresh: widget.onRefresh,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error message but still navigate to companion screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        final Map<String, dynamic> appointmentData = {
          'appointmentType': appointmentType,
          'careProvider': careProvider,
          'mainReason': mainReason,
          'selectedSymptoms': selectedSymptoms,
          'lifeSituations': lifeSituations,
          'journeySteps': journeySteps,
          'concernPriorities': concernPriorities,
          'symptomChanges': symptomChanges,
          'communicationPreferences': communicationPreferences,
          'careExperiences': careExperiences,
          'concerns': concerns,
          'additionalInfo': additionalInfo,
        };
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AppointmentCompanionScreen(
              appointmentData: appointmentData,
            ),
          ),
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate back to previous screen outside appointment flow
      Navigator.of(context).pop();
    }
  }

  void _updateAppointmentData({
    String? type,
    String? provider,
    String? reason,
    List<String>? symptoms,
    List<String>? situations,
    List<String>? steps,
    List<String>? priorities,
    List<String>? changes,
    List<String>? preferences,
    List<String>? experiences,
    List<String>? concerns,
    Map<String, String>? info,
    bool canProceed = false,
  }) {
    setState(() {
      if (type != null) appointmentType = type;
      if (provider != null) careProvider = provider;
      if (reason != null) mainReason = reason;
      if (symptoms != null) selectedSymptoms = symptoms;
      if (situations != null) lifeSituations = situations;
      if (steps != null) journeySteps = steps;
      if (priorities != null) concernPriorities = priorities;
      if (changes != null) symptomChanges = changes;
      if (preferences != null) communicationPreferences = preferences;
      if (experiences != null) careExperiences = experiences;
      if (concerns != null) this.concerns = concerns;
      if (info != null) additionalInfo.addAll(info);
      _canProceed = canProceed;
    });
  }
  
  List<Widget> get screens {
    if (_isLoading) {
      return [
        const Center(child: CircularProgressIndicator()),
      ];
    }

    if (_error != null) {
      return [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading appointment questions: $_error',
                style: AppOSTextStyles.osMd.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAppointmentQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      PersonalInfoReviewScreen(
        onDataUpdate: (info) => _updateAppointmentData(info: info, canProceed: true),
      ),
      AppointmentTypeScreen(
        question: _getQuestionByType('TYPE_OF_VISIT_OR_EXAM'),
        onDataUpdate: (type, info, canProceed) => _updateAppointmentData(type: type, info: info, canProceed: canProceed),
      ),
      CareProviderScreen(
        question: _getQuestionByType('TYPE_OF_DOCTOR_PROVIDER'),
        onDataUpdate: (provider, info, canProceed) => _updateAppointmentData(provider: provider, info: info, canProceed: canProceed),
      ),
      MainReasonScreen(
        question: _getQuestionByType('MAIN_REASON_FOR_VISIT'),
        onDataUpdate: (reason, info, canProceed) => _updateAppointmentData(reason: reason, info: info, canProceed: canProceed),
      ),
      SymptomSelectionScreen(
        question: _getQuestionByType('IMPORTANT_SYMPTOMS_TO_DISCUSS'),
        onDataUpdate: (symptoms, info, canProceed) => _updateAppointmentData(symptoms: symptoms, info: info, canProceed: canProceed),
      ),
      LifeSituationScreen(
        question: _getQuestionByType('LIFE_STRESSORS_AFFECTING_HEALTH'),
        onDataUpdate: (situations, info, canProceed) => _updateAppointmentData(situations: situations, info: info, canProceed: canProceed),
      ),
      JourneyScreen(
        question: _getQuestionByType('JOURNEY_WITH_THIS_CONCERN'),
        onDataUpdate: (steps, info, canProceed) => _updateAppointmentData(steps: steps, info: info, canProceed: canProceed),
      ),
    
      ConcernPrioritizationScreen(
        onDataUpdate: (priorities, info, canProceed) => _updateAppointmentData(priorities: priorities, info: info, canProceed: canProceed),
      ),
      SymptomChangesScreen(
        onDataUpdate: (changes, info, canProceed) => _updateAppointmentData(changes: changes, info: info, canProceed: canProceed),
      ),
      CommunicationPreferencesScreen(
        onDataUpdate: (preferences, info, canProceed) => _updateAppointmentData(preferences: preferences, info: info, canProceed: canProceed),
      ),
      CareExperienceScreen(
        onDataUpdate: (experiences, info, canProceed) => _updateAppointmentData(experiences: experiences, info: info, canProceed: canProceed),
      ),
      ConcernsScreen(
        onDataUpdate: (concerns, info, canProceed) => _updateAppointmentData(concerns: concerns, info: info, canProceed: canProceed),
      ),
      DataPrivacyScreen(
        onDataUpdate: (info) => _updateAppointmentData(info: info, canProceed: true),
      ),
    ];
  }

  double get _progressValue {
    return ( _currentPage + 1 ) / screens.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: FoxxBackButton(onPressed: _previousPage),
          title: Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.progressBarBase,
              borderRadius: BorderRadius.circular(3),
            ),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(3),
              value: _progressValue,
              backgroundColor: AppColors.progressBarBase,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressBarSelected),
              minHeight: 4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: Implement pause functionality
              },
              child: Text(
                '',
                style: TextStyle(
                  color: AppColors.amethyst,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: screens,
                ),
              ),
              // Centralized Next Button
              if (_currentPage < 14) // Show on all screens except the last one
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _nextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canProceed ? AppColors.amethyst : AppColors.gray400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: AppOSTextStyles.osMdSemiboldLink.copyWith(
                          color: Colors.white,
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
}