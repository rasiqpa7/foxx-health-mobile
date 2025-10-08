import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';

import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';


class AgeSelectionRevampScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(int)? onDataUpdate;
  
  const AgeSelectionRevampScreen({super.key, this.onNext, this.onDataUpdate});

  @override
  State<AgeSelectionRevampScreen> createState() => _AgeSelectionRevampScreenState();
}

class _AgeSelectionRevampScreenState extends State<AgeSelectionRevampScreen> {
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _ageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ageFocusNode.addListener(() {
      if (_ageFocusNode.hasFocus) {
        // Show keyboard when field is focused
      }
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  int? getSelectedAge() {
    if (_ageController.text.isEmpty) return null;
    return int.tryParse(_ageController.text);
  }

  bool hasTextInput() {
    return _ageController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your age matters',
                style: AppTypography.h4,
              ),
              const SizedBox(height: 8),
              Text(
                'Age can impact how symptoms show up and change over time—knowing yours helps us get it right.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTypography.regular,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        focusNode: _ageFocusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: InputDecoration(
                          hintText: '16',
                          hintStyle: AppTypography.bodySm.copyWith(
                            color: AppColors.inputTextPlaceholder,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.bodyLg,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    Text(
                      'Years',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FoxxNextButton(
                  isEnabled: hasTextInput(),
                  onPressed: () {
                    final selectedAge = getSelectedAge();
                    if (selectedAge != null) {
                      widget.onDataUpdate?.call(selectedAge);
                    }
                    // Close keyboard
                    FocusScope.of(context).unfocus();
                    widget.onNext?.call();
                  },
                  text: 'Next')
              ),
            ],
          ),
        ),
      
    );
  }
}