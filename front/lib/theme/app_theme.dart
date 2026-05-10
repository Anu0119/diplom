import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand palette ──────────────────────────────────────────────
  static const Color primary      = Color(0xFF6C63FF);
  static const Color primaryDark  = Color(0xFF4B44CC);
  static const Color secondary    = Color(0xFF00D4AA);
  static const Color accent       = Color(0xFFFF6B9D);
  static const Color warning      = Color(0xFFFFB547);
  static const Color danger       = Color(0xFFFF5252);
  static const Color success      = Color(0xFF00D4AA);

  static const Color bgDark       = Color(0xFF0F0E17);
  static const Color bgCard       = Color(0xFF1A1A2E);
  static const Color bgCard2      = Color(0xFF16213E);
  static const Color surface      = Color(0xFF1F1F35);
  static const Color surfaceLight = Color(0xFF2A2A45);

  static const Color textPrimary   = Color(0xFFF5F5FF);
  static const Color textSecondary = Color(0xFF9898B8);
  static const Color textMuted     = Color(0xFF5A5A7A);

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59FF)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F0E17), Color(0xFF1A1A2E), Color(0xFF0D1B4B)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00A8CC)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFFFB547), Color(0xFFFF8C00)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ── Category colors for clubs/events ──────────────────────────
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF6C63FF), Color(0xFF9B59FF)],
    [Color(0xFF00D4AA), Color(0xFF00A8CC)],
    [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
    [Color(0xFFFFB547), Color(0xFFFF8C00)],
    [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
  ];

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bgDark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),
    fontFamily: 'Nunito',
    textTheme: const TextTheme(
      displayLarge : TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1),
      headlineLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -.5),
      headlineMedium:TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: textPrimary),
      titleLarge   : TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium  : TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge    : TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, color: textPrimary),
      bodyMedium   : TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w400, color: textSecondary),
      labelSmall   : TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, color: textMuted, letterSpacing: .5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w800,
        color: textPrimary, fontSize: 20,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      contentTextStyle: const TextStyle(color: textPrimary, fontFamily: 'Nunito'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  const GlassCard({super.key, required this.child, this.padding, this.radius = 20, this.gradient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double? width;
  final double height;
  final double radius;
  final Widget? leading;
  final bool isLoading;
  const GradientButton({
    super.key, required this.text, this.onTap, this.gradient,
    this.width, this.height = 54, this.radius = 16, this.leading, this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient ?? AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(.35),
              blurRadius: 20, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[leading!, const SizedBox(width: 8)],
                    Text(text, style: const TextStyle(
                      color: Colors.white, fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: .3,
                    )),
                  ],
                ),
        ),
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final Gradient? gradient;
  const AppTag({super.key, required this.label, this.color, this.textColor, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppTheme.primary.withOpacity(.15),
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: TextStyle(
        color: textColor ?? AppTheme.primary,
        fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 11,
      )),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(
            fontFamily: 'Nunito', fontWeight: FontWeight.w800,
            fontSize: 18, color: AppTheme.textPrimary,
          )),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                fontSize: 13, color: AppTheme.primary,
              )),
            ),
        ],
      ),
    );
  }
}

class CategoryAvatar extends StatelessWidget {
  final int index;
  final IconData icon;
  final double size;
  const CategoryAvatar({super.key, required this.index, required this.icon, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.categoryGradients[index % AppTheme.categoryGradients.length];
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size * .3),
      ),
      child: Icon(icon, color: Colors.white, size: size * .5),
    );
  }
}