import 'package:flutter/material.dart';
import 'package:foxxhealth/features/presentation/theme/app_text_styles.dart';
import 'package:foxxhealth/features/presentation/theme/app_spacing.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';
 
enum FoxxButtonSize { large }

double _heightForSize(FoxxButtonSize size) {
  switch (size) {
    case FoxxButtonSize.large:
      return 44;
  }
}

double _radiusForSize(FoxxButtonSize size) {
  switch (size) {
    case FoxxButtonSize.large:
      return 22;
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isEnabled;
  final FoxxButtonSize size;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.borderRadius,
    this.isEnabled = true,
    this.size = FoxxButtonSize.large,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _heightForSize(size);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(_radiusForSize(size));
    return SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppButtonColors.buttonPrimaryBackgroundEnabled
              : AppButtonColors.buttonPrimaryBackgroundDisabled,
          side: BorderSide(
            color: isEnabled
                ? AppButtonColors.buttonPrimaryBorderEnabled
                : AppButtonColors.buttonPrimaryBorderDisabled,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveRadius,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          elevation: MaterialStateProperty.all(0),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          label,
          style: AppTypography.labelMdSemibold.copyWith(
            color: isEnabled
                ? AppButtonColors.buttonPrimaryTextEnabled
                : AppButtonColors.buttonPrimaryTextDisabled,
            height: 20 / AppTypography.sizeMd, // override line-height to 20px
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isEnabled;
  final FoxxButtonSize size;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.borderRadius,
    this.isEnabled = true,
    this.size = FoxxButtonSize.large,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _heightForSize(size);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(_radiusForSize(size));
    return SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppButtonColors.buttonSecondaryBackgroundEnabled
              : AppButtonColors.buttonSecondaryBackgroundDisabled,
          side: BorderSide(
            color: isEnabled
                ? AppButtonColors.buttonSecondaryBorderEnabled
                : AppButtonColors.buttonSecondaryBorderDisabled,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveRadius,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          elevation: MaterialStateProperty.all(0),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          label,
          style: AppTypography.labelMdSemibold.copyWith(
            color: isEnabled
                ? AppButtonColors.buttonSecondaryTextEnabled
                : AppButtonColors.buttonSecondaryTextDisabled,
            height: 20 / AppTypography.sizeMd,
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isEnabled;
  final FoxxButtonSize size;

  const OutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.borderRadius,
    this.isEnabled = true,
    this.size = FoxxButtonSize.large,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _heightForSize(size);
    final effectiveRadius = borderRadius ?? BorderRadius.circular(_radiusForSize(size));
    return SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppButtonColors.buttonOutlineBackgroundEnabled
              : AppButtonColors.buttonOutlineBackgroundDisabled,
          side: BorderSide(
            color: isEnabled
                ? AppButtonColors.buttonOutlineBorderEnabled
                : AppButtonColors.buttonOutlineBorderDisabled,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: effectiveRadius,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          elevation: MaterialStateProperty.all(0),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(
          label,
          style: AppTypography.labelMdSemibold.copyWith(
            color: isEnabled
                ? AppButtonColors.buttonOutlineTextEnabled
                : AppButtonColors.buttonOutlineTextDisabled,
            height: 20 / AppTypography.sizeMd, // override line-height to 20px
          ),
        ),
      ),
    );
  }
}

/// Convenience widget to stack two buttons with standard spacing.
class StackedButtons extends StatelessWidget {
  final Widget top;
  final Widget bottom;

  const StackedButtons({super.key, required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        top,
        SizedBox(height: AppSpacing.stackedButtons),
        bottom,
      ],
    );
  }
}