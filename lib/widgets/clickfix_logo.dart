import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clickfix/theme.dart';

class ClickFixLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final bool vertical;
  final bool isDarkBackground;

  const ClickFixLogo({
    super.key,
    this.iconSize = 48,
    this.fontSize = 24,
    this.vertical = true,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkBackground ? Colors.white : ClickFixTheme.textDark;
    
    Widget logoIcon = Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: ClickFixTheme.primaryAmber,
        borderRadius: BorderRadius.circular(iconSize * 0.28),
        boxShadow: [
          BoxShadow(
            color: ClickFixTheme.primaryAmber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background house outline subtly
          Icon(
            Icons.home_outlined,
            size: iconSize * 0.7,
            color: ClickFixTheme.primaryDark.withOpacity(0.15),
          ),
          // Main tool icon
          Icon(
            Icons.build_rounded,
            size: iconSize * 0.45,
            color: ClickFixTheme.primaryDark,
          ),
          // Clicking cursor/pointer symbol at bottom-right
          Positioned(
            bottom: iconSize * 0.1,
            right: iconSize * 0.1,
            child: Icon(
              Icons.touch_app_rounded,
              size: iconSize * 0.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    Widget logoText = RichText(
      textAlign: vertical ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
        children: [
          TextSpan(
            text: 'CLICK',
            style: TextStyle(color: textColor),
          ),
          const TextSpan(
            text: ' ',
          ),
          const TextSpan(
            text: 'FIX',
            style: TextStyle(color: ClickFixTheme.primaryAmber),
          ),
        ],
      ),
    );

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          SizedBox(height: iconSize * 0.3),
          logoText,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          const SizedBox(width: 12),
          logoText,
        ],
      );
    }
  }
}
