import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:foxxhealth/features/presentation/widgets/page_control_dots.dart';
import 'package:foxxhealth/features/presentation/screens/loginScreen/login_screen.dart';
import 'package:foxxhealth/features/presentation/screens/background/foxxbackground.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/theme/app_spacing.dart';
import 'package:foxxhealth/features/presentation/widgets/foxx_buttons.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Foxxbackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.fullWidthButtonsHorizontal,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dots just above the buttons
                PageControlDots(count: 3, activeIndex: _currentPage),
                const SizedBox(height: 20),
                StackedButtons(
                  top: SecondaryButton(
                    label: 'Create An Account',
                    size: FoxxButtonSize.large,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(isSign: false),
                        ),
                      );
                    },
                  ),
                  bottom: OutlineButton(
                    label: 'Sign In',
                    size: FoxxButtonSize.large,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(isSign: true),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.textBoxHorizontal,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  
                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      'assets/svg/splash/Logo-Icon-Only.svg',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Welcome Text
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.textBoxHorizontal,
                  ),
                  child: Text(
                    'Welcome to FoXX',
                    style: AppTypography.heading2,
                    textAlign: TextAlign.center,
                  ),
                ),
                  
                  const SizedBox(height: 10),
                  
                  // Info Carousel: auto-plays every 2000ms
                  SizedBox(
                    height: 320,
                    child: _CarouselWithDots(
                      starburstBuilder: _buildStarburstSeparator,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarburstSeparator() {
    return Opacity(
      opacity: 0.3,
      child: SvgPicture.asset(
        'assets/svg/splash/Starburst.svg',
        width: 32,
        height: 32,
      ),
    );
  }
}

class _CarouselWithDots extends StatefulWidget {
  final Widget Function() starburstBuilder;
  final ValueChanged<int>? onPageChanged;
  const _CarouselWithDots({required this.starburstBuilder, this.onPageChanged});

  @override
  State<_CarouselWithDots> createState() => _CarouselWithDotsState();
}

class _CarouselWithDotsState extends State<_CarouselWithDots> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;
  bool _isResetting = false;
  int _currentActual = 0;

  static const int _pageCount = 3; // number of logical slides

  static const Duration _autoPlayInterval = Duration(milliseconds: 2000);
  static const Duration _transitionDuration = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(_autoPlayInterval, (timer) {
      if (!mounted) return;
      // Move forward; when at last logical page, animate to sentinel page (_pageCount)
      final actual = _controller.page?.round() ?? _currentActual;
      final nextPage = (actual == _pageCount - 1) ? _pageCount : actual + 1;
      _controller.animateToPage(
        nextPage,
        duration: _transitionDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
          controller: _controller,
          onPageChanged: (index) {
            _currentActual = index;
            // When reaching sentinel page, jump to 0 without animation and keep forward motion
            if (index == _pageCount) {
              if (!_isResetting) {
                _isResetting = true;
                setState(() => _currentPage = 0);
                widget.onPageChanged?.call(0);
                _controller.jumpToPage(0);
                _isResetting = false;
              }
              return;
            }
            setState(() => _currentPage = index);
            widget.onPageChanged?.call(index);
          },
          children: [
            // Slide 1
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.textBoxHorizontal,
                  ),
                  child: Text(
                    'FoXX exists because women deserve better. Better answers, better tools, and care that actually listens.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular),
                  ),
                ),
                const SizedBox(height: 10),
                widget.starburstBuilder(),
              ],
            ),
            // Slide 2
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.textBoxHorizontal,
                  ),
                  child: Text(
                    'We\'ll start with a few questions, and your answers help us give you support that\'s truly personal.\n\nEvery detail matters. Your story, your experience, and your body all deserve to be understood.\n\nWe\'ll keep what you share safe, and always use it with care.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular),
                  ),
                ),
                const SizedBox(height: 10),
                widget.starburstBuilder(),
              ],
            ),
            // Slide 3
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.textBoxHorizontal,
                  ),
                  child: Text(
                    'At the end of setup, you\'ll enter your payment details to begin your free trial. You\'re in control - no charge until it ends, and you can cancel anytime.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular),
                  ),
                ),
                const SizedBox(height: 10),
                widget.starburstBuilder(),
              ],
            ),
            // Sentinel: duplicate of slide 1 to enable forward wrap
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.textBoxHorizontal,
                  ),
                  child: Text(
                    'FoXX exists because women deserve better. Better answers, better tools, and care that actually listens.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(fontWeight: AppTypography.regular),
                  ),
                ),
                const SizedBox(height: 10),
                widget.starburstBuilder(),
              ],
            ),
          ],
        );
  }
}
