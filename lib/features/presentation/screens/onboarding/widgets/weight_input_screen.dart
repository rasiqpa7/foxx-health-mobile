import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/widgets/foxx_background.dart';


class WeightInputScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(double)? onDataUpdate;
  
  const WeightInputScreen({super.key, this.onNext, this.onDataUpdate});

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  final TextEditingController _weightController = TextEditingController();
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the weight field when screen loads
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_weightFocusNode);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  double? getWeight() {
    if (_weightController.text.isEmpty) return null;
    return double.tryParse(_weightController.text);
  }

  bool hasTextInput() {
    return _weightController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your current weight',
                style: AppHeadingTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(
                'Your weight can change symptom trends and insights.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: AppTypography.regular,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTypography.bodyLg,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              Text(
                'lbs',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FoxxNextButton(
                  isEnabled: hasTextInput(),
                  onPressed: (){
                    final weight = getWeight();
                    if (weight != null) {
                      widget.onDataUpdate?.call(weight);
                    }
                    // Close keyboard
                    FocusScope.of(context).unfocus();
                    widget.onNext?.call();
                  }, text: 'Next')
              ),
            ],
          ),
        ),
      ),
    );
  }
}