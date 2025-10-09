import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CompareSymptomsBottomSheet extends StatefulWidget {
  final String currentSymptom;
  final List<String> availableSymptoms;
  final Function(List<String>) onApply;

  const CompareSymptomsBottomSheet({
    Key? key,
    required this.currentSymptom,
    required this.availableSymptoms,
    required this.onApply,
  }) : super(key: key);

  @override
  State<CompareSymptomsBottomSheet> createState() =>
      _CompareSymptomsBottomSheetState();
}

class _CompareSymptomsBottomSheetState
    extends State<CompareSymptomsBottomSheet> {
  final Set<String> selectedSymptoms = <String>{};
  final int maxSelections = 3;

  // Color mapping for symptoms
  final Map<String, Color> symptomColors = {
    'Cramps': const Color(0xFF20B2AA), // Teal
    'Fatigue': const Color(0xFFFFD700), // Yellow
    'Sleep': const Color(0xFF4682B4), // Steel Blue
    'Headaches': const Color(0xFF805EC9), // Purple
    'Back Pain': const Color(0xFFDC143C), // Red
    'Nausea': const Color(0xFF32CD32), // Lime Green
    'Dizziness': const Color(0xFF9370DB), // Medium Purple
    'Anxiety': const Color(0xFFFF6347), // Tomato
    'Depression': const Color(0xFF2F4F4F), // Dark Slate Gray
    'Insomnia': const Color(0xFF4169E1), // Royal Blue
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compare symptoms',
                  style: AppOSTextStyles.osXlSemibold.copyWith(
                    color: AppColors.primary01,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can layer up to $maxSelections additional symptoms to explore connections.',
                  style: AppOSTextStyles.osMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Symptoms list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.availableSymptoms.length,
              itemBuilder: (context, index) {
                final symptom = widget.availableSymptoms[index];
                final isSelected = selectedSymptoms.contains(symptom);
                final canSelect =
                    selectedSymptoms.length < maxSelections || isSelected;

                return _buildSymptomItem(
                  symptom: symptom,
                  isSelected: isSelected,
                  canSelect: canSelect,
                );
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryTint),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppOSTextStyles.osMdSemiboldBody.copyWith(
                          color: AppColors.primaryTint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: selectedSymptoms.isNotEmpty ? _applySelection : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: selectedSymptoms.isNotEmpty
                            ? AppColors.primaryTint
                            : AppColors.gray300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Apply',
                        style: AppOSTextStyles.osMdSemiboldBody.copyWith(
                          color: selectedSymptoms.isNotEmpty 
                              ? AppColors.buttonTextPrimary 
                              : AppColors.gray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomItem({
    required String symptom,
    required bool isSelected,
    required bool canSelect,
  }) {
    final color = symptomColors[symptom] ?? AppColors.gray400;

    return GestureDetector(
      onTap: canSelect ? () => _toggleSymptom(symptom) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: canSelect ? Colors.white : AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryTint : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),

            // Symptom name
            Expanded(
              child: Text(
                symptom,
                style: AppOSTextStyles.osMdSemiboldBody.copyWith(
                  color: canSelect ? AppColors.primary01 : AppColors.gray400,
                ),
              ),
            ),

            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryTint : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryTint
                      : AppColors.primaryTint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (selectedSymptoms.contains(symptom)) {
        selectedSymptoms.remove(symptom);
      } else if (selectedSymptoms.length < maxSelections) {
        selectedSymptoms.add(symptom);
      }
    });
  }

  void _applySelection() {
    if (selectedSymptoms.isNotEmpty) {
      widget.onApply(selectedSymptoms.toList());
      Navigator.pop(context);
    }
  }
}
