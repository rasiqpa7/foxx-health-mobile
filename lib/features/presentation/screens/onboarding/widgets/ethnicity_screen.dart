import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/theme/app_typography.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/cubits/onboarding/onboarding_cubit.dart';

class EthnicityScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final List<OnboardingQuestion> questions;
  final Function(String)? onDataUpdate;
  
  const EthnicityScreen({super.key, this.onNext, this.questions = const [], this.onDataUpdate});

  @override
  State<EthnicityScreen> createState() => _EthnicityScreenState();
}

class _EthnicityScreenState extends State<EthnicityScreen> {
  String? _selectedEthnicity;

  List<String> get _ethnicityOptions {
    final question = OnboardingCubit().getQuestionByType(widget.questions, 'ETHNICITY');
    if (question != null) {
      return question.choices;
    }
    // Fallback options if API data is not available
    return [
      'Asian (East Asian, South Asian)',
      'Black or African American',
      'Hispanic or Latino',
      'Middle Eastern or North African',
      'Mixed/Multiracial',
      'Native American or Alaska Native',
      'Pacific Islander or Native Hawaiian',
      'White or Caucasian',
      'Prefer not to answer',
    ];
  }

  String get _description {
    final question = OnboardingCubit().getQuestionByType(widget.questions, 'ETHNICITY');
    return question?.description ?? 'How do you identify racially or ethnically?';
  }

  

  Widget _buildEthnicityOption(String option) {
    final bool isSelected = _selectedEthnicity == option;

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
            _selectedEthnicity = option;
          });
        },
        child: 
         ClipRRect(
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
      )
         )
      )
        
    );
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _description.split('?')[0] + '?',
                  style: AppTypography.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  _description.split('?').length > 1 ? _description.split('?')[1] : '',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTypography.regular,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _ethnicityOptions.map(_buildEthnicityOption).toList(),
                    ),
                  ),
                ),
                if (_selectedEthnicity != null)
                  SizedBox(
                    width: double.infinity,
                    child: FoxxNextButton(
                      isEnabled: true,
                      onPressed: () {
                        if (_selectedEthnicity != null) {
                          widget.onDataUpdate?.call(_selectedEthnicity!);
                        }
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
      ),
    );
  }
}