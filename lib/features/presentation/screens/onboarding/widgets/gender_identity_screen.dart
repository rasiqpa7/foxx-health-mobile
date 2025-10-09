import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/widgets/neumorphic_card.dart';
import 'package:foxxhealth/features/presentation/cubits/onboarding/onboarding_cubit.dart';

class GenderIdentityScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final List<OnboardingQuestion> questions;
  final Function(String)? onDataUpdate;
  
  const GenderIdentityScreen({super.key, this.onNext, this.questions = const [], this.onDataUpdate});

  @override
  State<GenderIdentityScreen> createState() => _GenderIdentityScreenState();
}

class _GenderIdentityScreenState extends State<GenderIdentityScreen> {
  String? _selectedGender;
  final TextEditingController _selfDescribeController = TextEditingController();
  bool _isSelfDescribeSelected = false;

  List<String> get _genderOptions {
    final question = OnboardingCubit().getQuestionByType(widget.questions, 'GENDER');
    if (question != null) {
      return question.choices;
    }
    // Fallback options if API data is not available
    return [
      'Woman',
      'Transgender Woman',
      'Gender queer/Gender fluid',
      'Agender',
      'Prefer not to say',
      'Prefer to self describe',
    ];
  }

  String get _description {
    final question = OnboardingCubit().getQuestionByType(widget.questions, 'GENDER');
    return question?.description ?? 'How do you currently describe your gender identity?';
  }

  @override
  void dispose() {
    _selfDescribeController.dispose();
    super.dispose();
  }

  String? getSelectedGender() {
    if (_selectedGender == 'Prefer to self describe' ||
        _selectedGender == 'Prefer to self-describe') {
      return _selfDescribeController.text.isNotEmpty
          ? _selfDescribeController.text
          : null;
    }
    return _selectedGender;
  }

  Widget _buildGenderOption(String option) {
    final bool isSelected = _selectedGender == option;
    final bool isSelfDescribe = option == 'Prefer to self describe' || 
                                option == 'Prefer to self-describe';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: NeumorphicOptionCard(
        text: option,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedGender = option;
            _isSelfDescribeSelected = isSelfDescribe;
          });
        },
      ),
    );
  }

  Widget _buildSelfDescribeField() {
    return Visibility(
      visible: _isSelfDescribeSelected,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _selfDescribeController,
            decoration: InputDecoration(
              hintText: 'Self describe',
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
                    .copyWith(color:AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._genderOptions.map(_buildGenderOption).toList(),
                      _buildSelfDescribeField(),
                    ],
                  ),
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                child: 
                FoxxNextButton(
                  isEnabled: getSelectedGender() != null,
                  onPressed: () {
                    final selectedGender = getSelectedGender();
                    if (selectedGender != null) {
                      widget.onDataUpdate?.call(selectedGender);
                    }
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
