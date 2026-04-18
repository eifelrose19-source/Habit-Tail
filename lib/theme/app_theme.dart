import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // COLOUR PALETTE
  // ─────────────────────────────────────────────
  /// Primary — Soft Iris: headers, backgrounds, parent/admin buttons
  static const Color softIris     = Color(0xFFD0BFFF);
 
  /// Secondary — Blush Pink: kid "Complete" buttons, child actions
  static const Color blushPink    = Color(0xFFFFADBC);
 
  /// Accent — Electric Sky: alerts, pet profiles, input stroke, nav pills
  static const Color electricSky  = Color(0xFF98E4FF);
 
  /// Surface — Pure White: card backgrounds, input fills
  static const Color surface      = Color(0xFFFFFFFF);
 
  /// Deep Text — Midnight Plum: all readable text
  static const Color midnightPlum = Color(0xFF3F2E5A);
 
  /// Beige — Family / Tasks dashboard body ✅ Figma fill panel
  static const Color beigeBackground = Color(0xFFF0EAD6);
 
  // Gold
  static const Color goldText = Color(0xFFFFD700);
  // Status colours
  static const Color statusPending   = Color(0xFFFF9800);
  static const Color statusCompleted = Color(0xFF4CAF50);
  static const Color statusRejected  = Color(0xFFF44336);
  static const Color cardLight = Color(0xFFCFB8F5);

  // ─────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────

  /// Auth / onboarding / AppBar — softIris → midnightPlum, top to bottom 
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [softIris, midnightPlum],
    ),
  );

  /// Parent dashboard — softIris 49% → midnightPlum 100% 
  static const BoxDecoration parentDashboardBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.49, 1.0],
      colors: [softIris, midnightPlum],
    ),
  );

  /// Child dashboard 
  static const BoxDecoration childDashboardBackground = BoxDecoration(
    color: softIris,
  );

  /// Family / Tasks dashboard 
  static const BoxDecoration familyDashboardBackground = BoxDecoration(
    color: beigeBackground,
  );

  // ─────────────────────────────────────────────
  // TYPOGRAPHY
  // ─────────────────────────────────────────────

  /// H1 — 32px Bold. Splash / welcome titles.
  static TextStyle h1({Color color = midnightPlum}) => GoogleFonts.quicksand(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// H2 — 24px SemiBold.
  static TextStyle h2({Color color = midnightPlum}) => GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Body — 16px Medium. Input text & descriptions.
  static TextStyle body({Color color = midnightPlum}) => GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  /// Button — 16px Bold. All primary buttons. 
  static TextStyle buttonText({Color color = midnightPlum}) =>
      GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Caption — 14px Medium. Footer links, secondary labels. 
  static TextStyle caption({Color color = midnightPlum}) =>
      GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // ── Shared custom styles ──

  /// Gold coin amount — header only
  static TextStyle goldAmount() => GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: goldText,
      );

  /// Section heading inside cards — 18px Bold
  static TextStyle sectionHeading() => GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: midnightPlum,
      );

  /// AppBar "Welcome, Name!" — sectionHeading on dark bg
  static TextStyle headerTitle() =>
      sectionHeading().copyWith(color: surface);

  /// Link / underlined action
  static TextStyle linkText({Color color = midnightPlum}) =>
      caption(color: color).copyWith(decoration: TextDecoration.underline);

  /// Input hint
  static TextStyle inputHint() => GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: midnightPlum.withAlpha(120),
      );

  /// Pet name below avatar — used on child dashboard & pet dashboard
  static TextStyle petName() => GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: midnightPlum,
      );

  // ─────────────────────────────────────────────
  // BORDER RADII  
  // ─────────────────────────────────────────────

  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;  // buttons & inputs 
  static const double radiusLarge  = 16.0;  // cards
  static const double radiusXL     = 20.0;  // panels
  static const double radiusFull   = 100.0; // pill buttons

  // ─────────────────────────────────────────────
  // SPACING  20px margins, 10px gap 
  // ─────────────────────────────────────────────

  static const double spacingXS  = 4.0;
  static const double spacingS   = 8.0;
  static const double spacingM   = 12.0;
  static const double spacingL   = 16.0;
  static const double spacingXL  = 20.0;  // = horizontal screen padding
  static const double spacingXXL = 24.0;
  static const double itemGap    = 10.0;  // layout gap 

  // ─────────────────────────────────────────────
  // COMPONENT SIZES  
  // ─────────────────────────────────────────────

  /// 52px — buttons, inputs, task rows 
  static const double tappableHeight = 52.0;
  static const double petAvatarSize  = 72.0;
  static const double appBarHeight   = 64.0;

  // ─────────────────────────────────────────────
  // BOX DECORATIONS
  // ─────────────────────────────────────────────

  /// Standard card — configurable colour and radius
  static BoxDecoration cardDecoration({
    Color color = cardLight,
    double radius = radiusLarge,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: midnightPlum.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// Pill decoration — streak badge, nav buttons
  static BoxDecoration pillDecoration({Color color = electricSky}) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radiusFull),
      );

  // ─────────────────────────────────────────────
  // BUTTON STYLES
  // ─────────────────────────────────────────────

  /// Primary — electricSky, 52px, 12px radius 
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: electricSky,
    foregroundColor: midnightPlum,
    elevation: 0,
    minimumSize: const Size(double.infinity, tappableHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );

  /// Secondary — blushPink, kid actions / "Complete" 
  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: blushPink,
    foregroundColor: midnightPlum,
    elevation: 0,
    minimumSize: const Size(double.infinity, tappableHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );

  /// Outline — white fill, electricSky stroke 1.5px
  static final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: midnightPlum,
    backgroundColor: surface,
    minimumSize: const Size(double.infinity, tappableHeight),
    side: const BorderSide(color: electricSky, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );

  /// Pill — nav buttons ("Back", "Shop")
  static final ButtonStyle pillButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: electricSky,
    foregroundColor: midnightPlum,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusFull),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
  );

  /// sign-out
  static final ButtonStyle destructiveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cardLight,
    foregroundColor: midnightPlum,
    elevation: 0,
    minimumSize: const Size(double.infinity, tappableHeight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );

  // ─────────────────────────────────────────────
  // INPUT DECORATION 52px, 12px radius
  // ─────────────────────────────────────────────

  static InputDecoration textFieldDecoration({
    required String hint,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: inputHint(),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        constraints: const BoxConstraints(minHeight: tappableHeight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: electricSky, width: 1.5),
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      );

  // ─────────────────────────────────────────────
  // REUSABLE WIDGETS
  // ─────────────────────────────────────────────

  /// Primary full-width button
  static Widget buildButton({
    required String label,
    required VoidCallback onTap,
    ButtonStyle? style,
  }) =>
      ElevatedButton(
        onPressed: onTap,
        style: style ?? elevatedButtonStyle,
        child: Text(label, style: buttonText()),
      );

  /// Secondary full-width button (blushPink — kid actions)
  static Widget buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
  }) =>
      ElevatedButton(
        onPressed: onTap,
        style: secondaryButtonStyle,
        child: Text(label, style: buttonText()),
      );

  /// Pill nav button ("Back", "Shop", "3 Day Streak!")
  static Widget buildPillButton({
    required String label,
    required VoidCallback onTap,
    Color bgColor = electricSky,
  }) =>
      ElevatedButton(
        onPressed: onTap,
        style: pillButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(bgColor),
        ),
        child: Text(label, style: buttonText()),
      );

  // ─────────────────────────────────────────────
  // SCREEN WRAPPERS
  // ─────────────────────────────────────────────

  static Widget screenWrapper({required Widget child}) =>
      _buildWrapper(decoration: backgroundGradient, child: child, pad: true);

  static Widget childScreenWrapper({required Widget child}) =>
      _buildWrapper(decoration: childDashboardBackground, child: child);

  static Widget parentScreenWrapper({required Widget child}) =>
      _buildWrapper(decoration: parentDashboardBackground, child: child);

  static Widget familyScreenWrapper({required Widget child}) =>
      _buildWrapper(decoration: familyDashboardBackground, child: child);

  static Widget _buildWrapper({
    required BoxDecoration decoration,
    required Widget child,
    bool pad = false,
  }) =>
      Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: decoration,
          child: SafeArea(
            child: pad
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: spacingXL),
                    child: child,
                  )
                : child,
          ),
        ),
      );
}

