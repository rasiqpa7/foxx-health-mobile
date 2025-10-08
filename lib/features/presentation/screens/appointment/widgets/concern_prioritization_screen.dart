import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/widgets/neumorphic_card.dart';

class ConcernPrioritizationScreen extends StatefulWidget {
  final Function(List<String>, Map<String, String>, bool) onDataUpdate;

  const ConcernPrioritizationScreen({
    Key? key,
    required this.onDataUpdate,
  }) : super(key: key);

  @override
  State<ConcernPrioritizationScreen> createState() => _ConcernPrioritizationScreenState();
}

class _ConcernPrioritizationScreenState extends State<ConcernPrioritizationScreen> {
  final Set<String> selectedPriorities = {};
  final TextEditingController _otherController = TextEditingController();
  bool isOtherSelected = false;

  final List<String> prioritizationOptions = [
    'Start with what\'s most disruptive to my daily life',
    'Lead with what I\'m most worried could be serious',
    'Highlight the symptoms that are worsening, unpredictable, or have changed',
    'Focus on what\'s been dismissed by providers before',
    'Prioritize what has the best chance of getting addressed',
    'Start with what\'s easiest to explain and build from there',
    'Emphasize what I have the most evidence or tracking for',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select "Others" as shown in the image
    selectedPriorities.add('Others');
    isOtherSelected = true;
    
    // Add sample text to the "Others" field
    _otherController.text = 'Focus on symptoms that have been getting progressively worse over time';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update data after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateData();
    });
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _updateData() {
    List<String> priorities = selectedPriorities.toList();
    Map<String, String> info = {};
    
    if (isOtherSelected && _otherController.text.trim().isNotEmpty) {
      info['other_priority_description'] = _otherController.text.trim();
    }
    
    widget.onDataUpdate(priorities, info, _canProceed());
  }

  void _togglePriority(String priority) {
    setState(() {
      if (selectedPriorities.contains(priority)) {
        selectedPriorities.remove(priority);
      } else {
        selectedPriorities.add(priority);
      }
    });
    _updateData();
  }

  void _toggleOther() {
    setState(() {
      if (isOtherSelected) {
        selectedPriorities.remove('Others');
        isOtherSelected = false;
      } else {
        selectedPriorities.add('Others');
        isOtherSelected = true;
      }
    });
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          
          // Central Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              size: 40,
              color: AppColors.amethyst,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'How should we prioritize your concerns for this appointment?',
            style: AppHeadingTextStyles.h4.copyWith(
              color: AppColors.primary01,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'Your answer helps our AI support you on which symptoms or issues to lead with and how to structure your talking points.',
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.davysGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          // Instruction
          Text(
            'Select all that apply',
            style: AppOSTextStyles.osMd.copyWith(
              color: AppColors.davysGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Prioritization options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...prioritizationOptions.map((priority) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeumorphicOptionCard(
                      text: priority,
                      isSelected: selectedPriorities.contains(priority),
                      onTap: () => _togglePriority(priority),
                    ),
                  )),
                  
                  // Others option
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeumorphicOptionCard(
                      text: 'Other',
                      isSelected: isOtherSelected,
                      onTap: _toggleOther,
                    ),
                  ),
                  
                  // Other description field
                  if (isOtherSelected) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.gray200,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _otherController,
                        decoration: InputDecoration(
                          hintText: 'Please describe',
                          hintStyle: AppOSTextStyles.osMd.copyWith(
                            color: AppColors.gray600,
                          ),
                          border: InputBorder.none,
                        ),
                        style: AppOSTextStyles.osMd.copyWith(
                          color: AppColors.primary01,
                        ),
                        onChanged: (value) => _updateData(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Spacer for bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  bool _canProceed() {
    return selectedPriorities.isNotEmpty;
  }
}
