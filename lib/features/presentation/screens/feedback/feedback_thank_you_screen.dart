import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';

class FeedbackThankYouScreen extends StatelessWidget {
  const FeedbackThankYouScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.flax.withOpacity(0.3),
                AppColors.background,
                AppColors.gray100,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Thank you heading
                  Text(
                    'Thanks!',
                    style: AppHeadingTextStyles.h1.copyWith(
                      color: AppColors.primary01,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Thank you message
                  Text(
                    'Thanks for taking the time to tell us your thoughts, it means a lot to us.',
                    style: AppTextStyles.bodyOpenSans.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Checkmark icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.mauve,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.mauve,
                      size: 48,
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Back to home button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to home screen
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amethyst,
                        foregroundColor: AppColors.foxxWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Back to Home',
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
        ),
      ),
    );
  }
}
