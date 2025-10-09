import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foxxhealth/features/presentation/theme/app_colors.dart';




// ============================
/// Design tokens for typography
// ============================


class AppTypography {
  // ====== Font Families ======
  static const String fontMw = 'Merriweather';
  static const String fontOs = 'Open Sans';

  // ====== Font Weights ======
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ====== Sizes ======
  static const double size2xs = 11;
  static const double sizeXs = 12;
  static const double sizeSm = 14;
  static const double sizeMd = 16;
  static const double sizeLg = 18;
  static const double sizeXl = 20;
  static const double size2xl = 24;
  static const double size3xl = 28;
  static const double size4xl = 32;

  // ====== Line Heights ======
  static const double lh2xs = 16;
  static const double lhXs = 20;
  static const double lhSm = 24;
  static const double lhMd = 28;
  static const double lhLg = 32;
  static const double lhXl = 36;
  static const double lh2xl = 40;

  // ====== Letter Spacing ======
  static const double lsXl = 0.25;
  static const double lsLg = 0.1;
  static const double lsBase = 0;
  static const double lsSm = -0.1;

  // ====== Default Text Color Token ======
  static const Color textPrimary = AppColors.gray900;

  // ==========================
  // BODY TEXT (Hybrid)
  // ==========================
  static TextStyle bodyLg = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeLg,
    height: AppTypography.lhMd / AppTypography.sizeLg,
    letterSpacing: AppTypography.lsLg,
    color: AppTypography.textPrimary,
  );
  static TextStyle bodyLgSemibold = bodyLg.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle bodyLgBold = bodyLg.copyWith(fontWeight: AppTypography.bold);

  static TextStyle bodyMd = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeMd,
    height: AppTypography.lhSm / AppTypography.sizeMd,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );
  static TextStyle bodyMdSemibold = bodyMd.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle bodyMdBold = bodyMd.copyWith(fontWeight: AppTypography.bold);
  // Bullet body style: regular weight variant of bodyMd for list items
  static TextStyle bulletBodyMd = bodyMd.copyWith(fontWeight: AppTypography.regular);

  static TextStyle bodySm = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeSm,
    height: AppTypography.lhXs / AppTypography.sizeSm,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );
  static TextStyle bodySmSemibold = bodySm.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle bodySmBold = bodySm.copyWith(fontWeight: AppTypography.bold);

  static TextStyle bodyXs = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeXs,
    height: AppTypography.lhXs / AppTypography.sizeXs,
    letterSpacing: AppTypography.lsSm,
    color: AppTypography.textPrimary,
  );
  static TextStyle bodyXsSemibold = bodyXs.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle bodyXsBold = bodyXs.copyWith(fontWeight: AppTypography.bold);

  // ==========================
  // HEADINGS (Hybrid)
  // ==========================
  static TextStyle h1 = GoogleFonts.merriweather(
    fontWeight: AppTypography.bold,
    fontSize: AppTypography.size4xl,
    height: AppTypography.lh2xl / AppTypography.size4xl,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );

  static TextStyle h2 = GoogleFonts.merriweather(
    fontWeight: AppTypography.bold,
    fontSize: AppTypography.size3xl,
    height: AppTypography.lhXl / AppTypography.size3xl,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );

  static TextStyle h3 = GoogleFonts.merriweather(
    fontWeight: AppTypography.bold,
    fontSize: AppTypography.size2xl,
    height: AppTypography.lhLg / AppTypography.size2xl,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );

  // Legacy alias for backward compatibility with older references
  static TextStyle heading2 = h2;

  static TextStyle h4 = GoogleFonts.merriweather(
    fontWeight: AppTypography.bold,
    fontSize: AppTypography.sizeXl,
    height: AppTypography.lhMd / AppTypography.sizeXl,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );

  // ==========================
  // LABELS (Hybrid)
  // ==========================
  static TextStyle labelLg = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeLg,
    height: AppTypography.lhSm / AppTypography.sizeLg,
    letterSpacing: AppTypography.lsLg,
    color: AppTypography.textPrimary,
  );
  static TextStyle labelLgSemibold = labelLg.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle labelLgBold = labelLg.copyWith(fontWeight: AppTypography.bold);
  static TextStyle labelLgLink = labelLg.copyWith(decoration: TextDecoration.underline);

  static TextStyle labelMd = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeMd,
    height: AppTypography.lhSm / AppTypography.sizeMd,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );
  static TextStyle labelMdSemibold = labelMd.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle labelMdBold = labelMd.copyWith(fontWeight: AppTypography.bold);
  static TextStyle labelMdLink = labelMd.copyWith(decoration: TextDecoration.underline);

  static TextStyle labelSm = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeSm,
    height: AppTypography.lh2xs / AppTypography.sizeSm,
    letterSpacing: AppTypography.lsSm,
    color: AppTypography.textPrimary,
  );
  static TextStyle labelSmSemibold = labelSm.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle labelSmBold = labelSm.copyWith(fontWeight: AppTypography.bold);
  static TextStyle labelSmLink = labelSm.copyWith(decoration: TextDecoration.underline);

  static TextStyle labelXs = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeXs,
    height: AppTypography.lh2xs / AppTypography.sizeXs,
    letterSpacing: AppTypography.lsSm,
    color: AppTypography.textPrimary,
  );
  static TextStyle labelXsSemibold = labelXs.copyWith(fontWeight: AppTypography.semibold);
  static TextStyle labelXsBold = labelXs.copyWith(fontWeight: AppTypography.bold);
  static TextStyle labelXsLink = labelXs.copyWith(decoration: TextDecoration.underline);

  // ==========================
  // TITLES (Hybrid)
  // ==========================
  static TextStyle titleXl = GoogleFonts.merriweather(
    fontWeight: AppTypography.bold,
    fontSize: AppTypography.sizeXl,
    height: AppTypography.lhSm / AppTypography.sizeXl,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );

  static TextStyle titleMd = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeMd,
    height: AppTypography.lhSm / AppTypography.sizeMd,
    letterSpacing: AppTypography.lsBase,
    color: AppTypography.textPrimary,
  );

  static TextStyle titleSm = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.sizeSm,
    height: AppTypography.lhSm / AppTypography.sizeSm,
    letterSpacing: AppTypography.lsSm,
    color: AppTypography.textPrimary,
  );

  static TextStyle title2Xs = TextStyle(
    fontFamily: AppTypography.fontOs,
    fontWeight: AppTypography.semibold,
    fontSize: AppTypography.size2xs,
    height: AppTypography.lh2xs / AppTypography.size2xs,
    letterSpacing: AppTypography.lsSm,
    color: AppTypography.textPrimary,
  );




  // ==========================
  // Original Code --- DO NOT DELETE
  // ==========================
}


class AppTextStyles {
 
  static const _fontFamily = 'Merriweather';
  static const _fontFamilyOpenSans = 'Opensans';

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle body2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle labelOpensans = TextStyle(
    fontFamily: _fontFamilyOpenSans,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  // OpenSans styles
  static const TextStyle bodyOpenSans = TextStyle(
    fontFamily: _fontFamilyOpenSans,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle body2OpenSans = TextStyle(
    fontFamily: _fontFamilyOpenSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionOpenSans = TextStyle(
    fontFamily: _fontFamilyOpenSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
   

  );

  static const TextStyle buttonOpenSans = TextStyle(
    fontFamily: _fontFamilyOpenSans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppHeadingTextStyles {
  // Uses Merriweather-VariableFont_opsz,wdth,wght.ttf as defined in pubspec.yaml
  static const String _fontFamily = 'Merriweather';

  // h1-mw-bold
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 40, // 4xl
    height: 1.2,  // 2xl line height (approximate)
    letterSpacing: 0.0, // base
  );

  // h2-mw-bold
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 32, // 3xl
    height: 1.2,  // xl line height (approximate)
    letterSpacing: 0.0, // base
  );

  // h3-mw-bold
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 24, // 2xl
    height: 1.15, // lg line height (approximate)
    letterSpacing: 0.0, // base
  );

  // h4-mw-bold
  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 18, // xl
    height: 1.1,  // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
}

class AppOSTextStyles {
  static const String _fontFamily = 'OpenSans';

  // --- Title Styles ---
  static const TextStyle osXl = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400, // regular
    fontSize: 24, // xl
    height: 1.5, // xl line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osXlSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 24, // xl
    height: 1.5, // xl line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osLgSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 20, // lg
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.15, // lg
  );
  static const TextStyle osMdSemiboldTitle = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 16, // md
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.15, // lg
  );
  static const TextStyle osMdBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 16, // md
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.15, // lg
  );

  // --- Body Styles ---
  static const TextStyle osLg = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400, // regular
    fontSize: 20, // lg
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osMd = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400, 
    // regular
    fontSize: 16, // md
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osMdSemiboldBody = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 16, // md
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osSmSemiboldBody = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 14, // sm
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );

  // --- Label Styles ---
  static const TextStyle osSbBold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 12, // sb
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osSbSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 12, // sb
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osSmSingleLine = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 14, // sm
    height: 1.0, // single line
    letterSpacing: 0.0, // base
  );
  static const TextStyle osMdSemiboldLabel = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 16, // md
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osMdSemiboldLink = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 16, // md
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
    decoration: TextDecoration.underline,
  );
  static const TextStyle osSmSemiboldLabel = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 14, // sm
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle osXsSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 10, // xs
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
  static const TextStyle os2XsSemibold = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w600, // semibold
    fontSize: 8, // 2xs
    height: 1.2, // sm line height (approximate)
    letterSpacing: 0.0, // base
  );
}
