import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/cubits/onboarding/onboarding_cubit.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final List<OnboardingQuestion> questions;
  final Function(Set<String>)? onDataUpdate;
  
  const DiagnosisHistoryScreen({super.key, this.onNext, this.questions = const [], this.onDataUpdate});

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  final Set<String> _selectedDiagnoses = {};
  final TextEditingController _otherController = TextEditingController();
  bool _showOtherField = false;

  List<String> get _diagnoses {
    final onboardingCubit = OnboardingCubit();
    final question = onboardingCubit.getQuestionByType(widget.questions, 'HEALTH_HISTORY');
    if (question != null) {
      return question.choices;
    }
    // Fallback options if API data is not available
    return [
      'Anxiety or Depression',
      'Autoimmune condition (e.g., lupus, Hashimoto\'s)',
      'Cancer (any type)',
      'Chronic fatigue or burnout',
      'Diabetes or insulin resistance',
      'Endometriosis',
      'Heart Disease',
      'High blood pressure',
      'IBS or other digestive issues',
      'PCOS (Polycystic Ovary Syndrome)',
      'I\'m not sure / still figuring it out',
    ];
  }

  String get _description {
    final onboardingCubit = OnboardingCubit();
    final question = onboardingCubit.getQuestionByType(widget.questions, 'HEALTH_HISTORY');
    return question?.description ?? 'Have you ever been given a diagnosis that still feels relevant?';
  }

  Widget _buildDiagnosisOption(String option) {
    final bool isSelected = _selectedDiagnoses.contains(option);
    
    final backgroundColor = isSelected
        ? AppColors.progressBarSelected
        : Colors.white.withOpacity(0.15);

    final shadowColor = isSelected
        ? Colors.white.withOpacity(0.5)
        : Colors.white.withOpacity(0.3);

    final textColor = isSelected
        ? Colors.black.withOpacity(0.85)
        : Colors.black.withOpacity(0.85);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedDiagnoses.remove(option);
            } else {
              _selectedDiagnoses.add(option);
            }
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color:
                isSelected? AppColors.progressBarSelected:
                 Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.amethyst)
                      : Icon(Icons.circle_outlined, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: isSelected ? AppTypography.semibold : AppTypography.regular,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherOption() {
    final bool isSelected = _selectedDiagnoses.contains('Others');
    
    final backgroundColor = isSelected
        ? AppColors.progressBarSelected
        : Colors.white.withOpacity(0.15);

    final shadowColor = isSelected
        ? Colors.white.withOpacity(0.5)
        : Colors.white.withOpacity(0.3);

    final textColor = isSelected
        ? Colors.black.withOpacity(0.85)
        : Colors.black.withOpacity(0.85);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedDiagnoses.remove('Others');
              _showOtherField = false;
            } else {
              _selectedDiagnoses.add('Others');
              _showOtherField = true;
            }
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color:
                isSelected? AppColors.progressBarSelected:
                 Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.amethyst)
                      : Icon(Icons.circle_outlined, color: Colors.grey[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Others',
                      style: AppTextStyles.bodyOpenSans.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherField() {
    return Visibility(
      visible: _showOtherField,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _otherController,
            decoration: InputDecoration(
              hintText: 'Please specify',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: AppTextStyles.bodyOpenSans,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  bool hasValidSelection() {
    return _selectedDiagnoses.isNotEmpty || (_showOtherField && _otherController.text.isNotEmpty);
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _description.split('?')[0] + '?',
                style: AppHeadingTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(
                _description.split('?').length > 1 ? _description.split('?')[1] : '',
                style: AppOSTextStyles.osMd
                    .copyWith(color: AppColors.primary01),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._diagnoses.map(_buildDiagnosisOption).toList(),
                      _buildOtherOption(),
                      _buildOtherField(),
                    ],
                  ),
                ),
              ),
              if (hasValidSelection())
                SizedBox(
                  width: double.infinity,
                  child: FoxxNextButton(
                    isEnabled: true,
                    onPressed: () {
                      // Prepare the final set of diagnoses including custom text
                      final diagnoses = Set<String>.from(_selectedDiagnoses);
                      if (_showOtherField && _otherController.text.isNotEmpty) {
                        diagnoses.remove('Others');
                        diagnoses.add(_otherController.text);
                      }
                      widget.onDataUpdate?.call(diagnoses);
                      // Close keyboard
                      FocusScope.of(context).unfocus();
                      widget.onNext?.call();
                    },
                    text: 'Next'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}