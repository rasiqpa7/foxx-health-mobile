import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foxxhealth/features/presentation/widgets/navigation_buttons.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/theme/app_spacing.dart';
import 'package:foxxhealth/features/presentation/widgets/foxx_buttons.dart';
import 'package:foxxhealth/features/presentation/screens/appointment/view/appointment_flow.dart';
import 'package:foxxhealth/features/presentation/screens/main_navigation/main_navigation_screen.dart';

class CreateAppointmentIntroScreen extends StatelessWidget {
  final String? origin; // 'home' or 'myprep'
  const CreateAppointmentIntroScreen({super.key, this.origin});

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: FoxxBackButton(
            onPressed: () {
              // Prefer popping to preserve MainNavigation scaffolding
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                // Fallback: restore main nav if there's nothing to pop
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MainNavigationScreen(),
                  ),
                );
              }
            },
          ),
        ),
        body: SafeArea(top: false,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top icon above all copy
                    Center(
                      child: SvgPicture.asset(
                        'assets/svg/MyPrep_Appt_Companion/my-prep-100x100.svg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Let’s plan your visit together',
                            style: AppTypography.h2,
                            textAlign: TextAlign.center,

                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'These questions may take time, but they can reveal patterns and insights others often miss.',
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w400),
                            ),
                            WidgetSpan(
                              child: SizedBox(width: double.infinity, height: AppSpacing.paragraphSpacing),
                            ),
                            TextSpan(
                              text:
                                  'Your Appointment Companion uses your answers to:',
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w400),
                            ),
                            WidgetSpan(
                              child: SizedBox(width: double.infinity, height: AppSpacing.paragraphSpacing),
                            ),
                            WidgetSpan(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 8),
                                      Text('• ', style: AppTypography.bulletBodyMd),
                                      Expanded(
                                        child: Text(
                                          'See the full picture of your health',
                                          style: AppTypography.bulletBodyMd,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 8),
                                      Text('• ', style: AppTypography.bulletBodyMd),
                                      Expanded(
                                        child: Text(
                                          'Guide you toward the questions that really count',
                                          style: AppTypography.bulletBodyMd,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 8),
                                      Text('• ', style: AppTypography.bulletBodyMd),
                                      Expanded(
                                        child: Text(
                                          'Keep the focus on you',
                                          style: AppTypography.bulletBodyMd,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            WidgetSpan(
                              child: SizedBox(
                                width: double.infinity,
                                height: AppSpacing.paragraphSpacing,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Take your time. Pause if you need. What you share can shape the care you receive.',
                              style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 12,
                        left: 20,
                        right: 20,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.foxxWhite.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/MyPrep_Appt_Companion/security-icon.svg',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 320,
                            child: Text(
                              'Everything you tell us stays private and protected, always.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: AppSpacing.bottomBarPadding,
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Next',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppointmentFlow(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}