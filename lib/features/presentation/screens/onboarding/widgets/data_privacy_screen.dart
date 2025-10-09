import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';

class DataPrivacyScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(bool)? onDataUpdate;
  
  const DataPrivacyScreen({super.key, this.onNext, this.onDataUpdate});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(
                    Icons.star,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 50),
           Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),

            ),
             child: Column(
              children: [
                   Text(
                  'Caring for your data like we care for you',
                  style: AppHeadingTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'What you share with us stays safe, always. We treat your health info with the same care we\'d want for ourselves: private, respectful, and only ever used to support you.',
                  style: AppOSTextStyles.osMd
              .copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                
              ],
             ),
           ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FoxxNextButton(
                    isEnabled: true,
                    onPressed: () {
                      // Data privacy is accepted when user proceeds from this screen
                      widget.onDataUpdate?.call(true);
                      // Close keyboard
                      FocusScope.of(context).unfocus();
                      widget.onNext?.call();
                    },
                    text: 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}