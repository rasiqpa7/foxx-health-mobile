import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';





class HeightInputScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(Map<String, dynamic>)? onDataUpdate;
  
  const HeightInputScreen({super.key, this.onNext, this.onDataUpdate});

  @override
  State<HeightInputScreen> createState() => _HeightInputScreenState();
}

class _HeightInputScreenState extends State<HeightInputScreen> {
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();
  final FocusNode _feetFocusNode = FocusNode();
  final FocusNode _inchesFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the feet field when screen loads
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(_feetFocusNode);
    });
  }

  @override
  void dispose() {
    _feetController.dispose();
    _inchesController.dispose();
    _feetFocusNode.dispose();
    _inchesFocusNode.dispose();
    super.dispose();
  }

  bool isHeightValid() {
    return _feetController.text.isNotEmpty;
  }

  bool hasTextInput() {
    return _feetController.text.isNotEmpty || _inchesController.text.isNotEmpty;
  }

  Map<String, dynamic>? getHeight() {
    if (_feetController.text.isEmpty) return null;
    final feet = int.tryParse(_feetController.text);
    final inches = int.tryParse(_inchesController.text) ?? 0;
    if (feet == null) return null;
    return {'feet': feet, 'inches': inches};
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
                  'How tall are you?',
                  style: AppTypography.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your height helps us interpret symptom trends and offer more accurate support for your body.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTypography.regular,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _feetController,
                                focusNode: _feetFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                decoration: InputDecoration(
                                  hintText: '0',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: AppTypography.bodyLg,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_inchesFocusNode);
                                },
                              ),
                            ),
                            Text(
                              'ft',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inchesController,
                                focusNode: _inchesFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                decoration: InputDecoration(
                                  hintText: '0',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: AppTypography.bodyLg,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            Text(
                              'in',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FoxxNextButton(
                    isEnabled: hasTextInput(),
                    onPressed: (){
                      final height = getHeight();
                      if (height != null) {
                        widget.onDataUpdate?.call(height);
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
        ),
      ),
    );
  }
}