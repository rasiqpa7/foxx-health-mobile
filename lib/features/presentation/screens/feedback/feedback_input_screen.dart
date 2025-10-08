import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/screens/feedback/feedback_thank_you_screen.dart';
import 'package:foxxhealth/features/data/services/feedback_service.dart';
import 'package:foxxhealth/features/data/models/feedback_model.dart';
import 'package:foxxhealth/core/constants/user_profile_constants.dart';

class FeedbackInputScreen extends StatefulWidget {
  final List<String> selectedPreferences;

  const FeedbackInputScreen({
    Key? key,
    required this.selectedPreferences,
  }) : super(key: key);

  @override
  State<FeedbackInputScreen> createState() => _FeedbackInputScreenState();
}

class _FeedbackInputScreenState extends State<FeedbackInputScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final FocusNode _feedbackFocusNode = FocusNode();
  final FeedbackService _feedbackService = FeedbackService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(() {
      setState(() {}); // rebuilds UI when text changes
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _feedbackFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create feedback model
      final feedback = FeedbackModel(
        favoritesCode: widget.selectedPreferences,
        feedbackText: _feedbackController.text.trim(),
        accountId: UserProfileConstants.accountId ?? 0,
        isDeleted: false,
      );

      // Submit feedback via API
      final success = await _feedbackService.submitFeedback(feedback);

      if (success) {
        // Navigate to thank you screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const FeedbackThankYouScreen(),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit feedback. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.amethyst,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Feedback',
                      style: AppHeadingTextStyles.h2.copyWith(
                        color: AppColors.primary01,
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why are you using FoXX?',
                        style: AppHeadingTextStyles.h2.copyWith(
                          color: AppColors.primary01,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tell us what you\'re loving about FoXX, and what you\'d like to see more of. Your feedback helps us make FoXX even better, for you, and for every woman who uses it.',
                        style: AppTextStyles.bodyOpenSans.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Text input area
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.foxxWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.mauve50,
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _feedbackController,
                            focusNode: _feedbackFocusNode,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Share your thoughts here...',
                              hintStyle: AppTextStyles.bodyOpenSans.copyWith(
                                color: AppColors.inputTextPlaceholder,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            style: AppTextStyles.bodyOpenSans.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              (_feedbackController.text.trim().isNotEmpty &&
                                      !_isSubmitting)
                                  ? () async {
                                      await _submitFeedback();
                                    }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amethyst,
                            foregroundColor: AppColors.foxxWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.foxxWhite),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Submitting...',
                                      style:
                                          AppTextStyles.buttonOpenSans.copyWith(
                                        color: AppColors.foxxWhite,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Submit Feedback',
                                  style: AppTextStyles.buttonOpenSans.copyWith(
                                    color: AppColors.foxxWhite,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
