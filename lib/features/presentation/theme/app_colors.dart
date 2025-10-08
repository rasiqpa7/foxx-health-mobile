import 'package:flutter/material.dart';

class AppColors {
  // Primary color
  static const lightViolet = Color(0xffCEA2FD);
  static const background = Color(0xffF1EFF7);
  static const backgroundDefault = Color(0xffFEEFF1);
  static const disabledButton = Color(0xffCECECF);

  static const amethystViolet = Color(0xff805EC9);
  static const blue = Color(0xff007AFF);

  static const optionBG = Color(0xffF1EFF7);
  static const foxxwhite = Color(0xffFFFCFC);


// ============================
/// Primitive Colors
// ============================



  // Brand Colors
  static const davysGray = Color(0xFF5E5C6C); 
  static const amethyst = Color(0xFF805EC9);
  static const amethyst50 = Color(0xFFF1EFF7);
  static const mauve = Color(0xFFCEA2FD); 
  static const mauve50 = Color(0xFFDEBFFF);
  static const flax = Color(0xFFFEEE99);
  static const sunglow = Color(0xFFFFCA4B); 
  static const foxxWhite = Color(0xFFFFFCFC); 
  static const ombre20 = Color(0xFFFEEFF1);
  static const ombre10 = Color(0xFFFBE9D1);



  // Gray Colors
  static const gray900 = Color(0xFF3E3D4B);
  static const gray800 = Color(0xFF5E5C6C); 
  static const gray700 = Color(0xFF67646C);
  static const gray600 = Color(0xFF99989F);
  static const gray500 = Color(0xFFCECECF); 
  static const gray400 = Color(0xFFCECECF); 
  static const gray300 = Color(0xFFD9D9D9);
  static const gray200 = Color(0xFFEFEFF0);
  static const gray100 = Color(0xFFFFFCFC); // Same as foxxWhite
  static const grayWhite = Color(0xFFFFFFFF);

  // Level Colors
  static const darkRed = Color(0xFFBF0F0F);
  static const red = Color(0xFFEB3C3C);
  static const orange = Color(0xFFE7931D);
  static const yellow = Color(0xFFFFCD04);

  // Green Colors
  static const pineGreen = Color(0xFF01796F);

  // Insight Colors
  static const insightDarkRed = Color(0xFFBF0F0F);
  static const insightRed = Color(0xFFEB3C3C);
  static const insightOrange = Color(0xFFFF9F1C);
  static const insightYellow = Color(0xFFFFF156);
  static const insightTeal = Color(0xFF04BFDA);
  static const insightMidnightTeal = Color(0xFF046E7D);
  static const insightCoralPink = Color(0xFFFF6F61);
  static const insightSkyBlue = Color(0xFF4DC9F6);
  static const insightMintGreen = Color(0xFF4DD599);
  static const insightIceBlue = Color(0xFFA8E6FF);
  static const insightOliveGreen = Color(0xFFA3B18A);
  static const insightCoolNavy = Color(0xFF264653);
  static const insightPurple = Color(0xFF9966CC);
  static const insightGray = gray600;
  static const insightPeachPastel = Color(0xFFFFD3B6);
  static const insightBrickRed = Color(0xFFF30000);
  static const insightHotPink = Color(0xFFEC34DF);
  static const insightEmerald = Color(0xFF27AE60);
  static const insightLakeBlue = Color(0xFF2980B9);
  static const insightColumbiaBlue = Color(0xFF87AFC7);
  static const insightCamelBrown = Color(0xFFC19A6B);
  static const insightBrightBlue = Color(0xFF0F5BFF);
  static const insightBrightCayan = Color(0xFF21DEFF);
  static const insightBrown = Color(0xFF885920);
  static const insightBubblegumPink = Color(0xFFFF9EF8);
  static const insightPineGreen = Color(0xFF037720);
  static const insightLimeGreen = Color(0xFFBEE659);
  static const insightNeonGreen = Color(0xFF23FF36);
  static const insightSageGreen = Color(0xFF749C8D);
  static const insightMustard = Color(0xFFE0CC5F);



// ============================
/// Semantic Colors (from Figma)
// ============================


  static const primary01 = gray900;
  static const inputFieldDisabled = gray400;
  static const border01 = gray400;
  static const border02 = gray100;
  static const surface01 = grayWhite;
  static const surface02 = foxxWhite;
  static const surface03 = gray100;
  static const primaryTint = amethyst;
  static const primaryTint50 = amethyst50;
  static const programBase = flax;
  static const programBaseSolid = sunglow;
  static const backgroundHighlight = mauve;

  // Canonical text tokens (use these)
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray700;
  static const Color textBrand = amethyst;
  static const Color inputTextPlaceholder = gray600;
  static const Color textSuccess = pineGreen;
  static const Color textError = darkRed;

  // Progress and background tokens (non-button)
  static const Color progressBarBase = grayWhite;
  static const Color progressBarSelected = sunglow;
  static const Color backgroundHighlighted = mauve;

  // Canonical button text tokens
  static const Color buttonTextPrimary = foxxWhite;
  static const Color buttonTextOutline = amethyst;

  // all related colors to buttons should use a new class AppButtonColors - see at the end of this file

  // Deprecated legacy tokens (backward compatibility)
  // Prefer canonical names above. Keep these for existing code paths only.
  static const Color primaryTxt = textPrimary; // DEPRECATED: use textPrimary
  static const Color secondaryTxt = textSecondary; // DEPRECATED: use textSecondary
  static const Color brandTxt = textBrand; // DEPRECATED: use textBrand
  static const Color inputTxtPlaceholder = inputTextPlaceholder; // DEPRECATED: use inputTextPlaceholder
  static const Color primaryBtnTxt = buttonTextPrimary; // DEPRECATED: prefer AppButtonColors.buttonPrimaryTextEnabled
  static const Color secondaryBtnTxt = amethyst; // DEPRECATED: prefer AppButtonColors.buttonSecondaryTextEnabled
  static const Color tertiaryBtnTxt = buttonTextOutline; // DEPRECATED: prefer AppButtonColors.buttonOutlineTextEnabled
  static const Color textInputPlaceholder = inputTextPlaceholder; // DEPRECATED: use inputTextPlaceholder
  static const Color buttonBorderOutlineEnabled = amethyst; // DEPRECATED: prefer AppButtonColors.buttonOutlineBorderEnabled
  static const Color buttonBorderOutlineDisabled = gray400; // DEPRECATED: prefer AppButtonColors.buttonOutlineBorderDisabled
  static const Color brandText = textBrand; // DEPRECATED: use textBrand
  static const Color optionBg = optionBG;

  // Surface
  static const crossGlassBase = grayWhite;
  static const crossGlassSelected = foxxWhite;
  static const sandRadioBase = gray200;
  static const sandRadioSelected = flax;
  static const sandRadioHover = gray100;
  static const overlay = Color(0x33000000); // 20% black
  static const overlaySoft = Color(0x1A000000); // 10% black
  static const overlayLight = Color(0x0D000000); // 5% black
  static const onSurfaceSubtle = Color(0xCCFEEFF1); // 80% ombre20

  // Kits
  static const kitLevel0 = gray400;
  static const kitLevel1 = yellow;
  static const kitLevel2 = sunglow;
  static const kitLevel3 = orange;
  static const kitLevel4 = red;
  static const kitPrimaryEnabled = mauve;
  static const kitDisabled = gray400;
  static const kitTertiaryBase = gray100;
  static const kitTertiarySolidSelected = grayWhite;
  static const kitLogoDefault = amethyst50;
  static const kitLogoDefaultSolid = amethyst;
  static const kitStrokeAlert = red;

  // Input Fields
  static const inputBg = red; 
  static const inputBgPrimary = grayWhite;
  static const inputBgActive = red; 
  static const inputField = gray400;
  static const inputOutline = red; 
  static const inputOutlineSelected = amethyst;

  // Icon
  static const iconPrimaryEnabled = amethyst;
  static const iconPrimaryDisabled = mauve;
  static const iconSecondaryEnabled = gray400;

  /// Primary background gradient using brand Mauve and Sunglow
  static  LinearGradient primaryBackgroundGradient = LinearGradient(
    begin: Alignment(1.01, 0.99),
    end: Alignment(0.21, -0.13),
    colors: [
       // color-brand-Mauve
      AppColors.mauve.withOpacity(0.45),
      AppColors.sunglow.withOpacity(0.45), // color-brand-Sunglow
    ],
  );

  /// Glass card treatment for home cards 
  // static final BoxDecoration glassCardDecoration = BoxDecoration(
  //   color: AppColors.crossGlassBase.withOpacity(0.28),
  //   borderRadius: BorderRadius.circular(20),
  //   border: Border.all(
  //     color: AppColors.gray200.withOpacity(0.9),
  //     width: 1.2,
  //   ),

  //   boxShadow: [
  //     BoxShadow(
  //       color: AppColors.gray400.withOpacity(0.08),
  //       blurRadius: 12,
  //       offset: Offset(0, 2),
  //     ),
  //   ],
  // );

  /// Inner shadow decoration for glass cards
  static final BoxDecoration glassCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white.withOpacity(0.28),

  );
   static final BoxDecoration glassCardDecoration2 = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    color: Colors.white.withOpacity(0.48),

  );

  static LinearGradient gradient45 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFE6B2).withOpacity(0.45),
      Color(0xFFE6D6FF).withOpacity(0.45),
    ],
  );
}

/// Structured button color tokens for clearer references across variants.
/// Uses existing AppColors primitives and keeps legacy AppColors tokens intact.
class AppButtonColors {
  // ----------------------------
  // Primary Button
  // ----------------------------
  // Backgrounds
  static const Color buttonPrimaryBackgroundEnabled = AppColors.amethyst;
  static const Color buttonPrimaryBackgroundDisabled = AppColors.gray500;

  // Text
  static const Color buttonPrimaryTextEnabled = AppColors.foxxWhite;
  static const Color buttonPrimaryTextDisabled = AppColors.gray500;

  // Border (usually same as background for primary buttons)
  static const Color buttonPrimaryBorderEnabled = AppColors.amethyst;
  static const Color buttonPrimaryBorderDisabled = AppColors.gray500;

  // ----------------------------
  // Secondary Button
  // ----------------------------
  // Backgrounds
  static const Color buttonSecondaryBackgroundEnabled = AppColors.foxxWhite;
  static const Color buttonSecondaryBackgroundDisabled = AppColors.gray500;

  // Text
  static const Color buttonSecondaryTextEnabled = AppColors.amethyst;
  static const Color buttonSecondaryTextDisabled = AppColors.gray500;

  // Border (if applicable, usually subtle)
  static const Color buttonSecondaryBorderEnabled = AppColors.foxxWhite;
  static const Color buttonSecondaryBorderDisabled = AppColors.gray500;

  // ----------------------------
  // Outline Button
  // ----------------------------
  // Backgrounds
  static const Color buttonOutlineBackgroundEnabled = Colors.transparent;
  static const Color buttonOutlineBackgroundDisabled = Colors.transparent;

  // Text
  static const Color buttonOutlineTextEnabled = AppColors.amethyst;
  static const Color buttonOutlineTextDisabled = AppColors.gray400;

  // Border
  static const Color buttonOutlineBorderEnabled = AppColors.amethyst;
  static const Color buttonOutlineBorderDisabled = AppColors.gray500;
}
