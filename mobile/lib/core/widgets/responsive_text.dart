import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

/// A responsive text widget that automatically handles overflow and adapts to screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;
  final double? textScaleFactor;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  
  // Responsive font size options
  final double? smallFontSize;
  final double? mediumFontSize;
  final double? largeFontSize;
  
  // Auto-adjust for small screens
  final bool autoAdjustForSmallScreens;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.smallFontSize,
    this.mediumFontSize,
    this.largeFontSize,
    this.autoAdjustForSmallScreens = true,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? effectiveStyle = style;
    int? effectiveMaxLines = maxLines;
    TextOverflow? effectiveOverflow = overflow;

    // Auto-adjust for small screens
    if (autoAdjustForSmallScreens && ResponsiveUtils.isSmallScreen(context)) {
      // Increase max lines for small screens to prevent overflow
      effectiveMaxLines ??= 2;
      effectiveOverflow ??= TextOverflow.ellipsis;
      
      // Adjust font size if responsive sizes are provided
      if (smallFontSize != null || mediumFontSize != null || largeFontSize != null) {
        final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(
          context,
          small: smallFontSize ?? style?.fontSize ?? 14.0,
          medium: mediumFontSize ?? style?.fontSize ?? 14.0,
          large: largeFontSize ?? style?.fontSize ?? 14.0,
        );
        
        effectiveStyle = (style ?? const TextStyle()).copyWith(
          fontSize: responsiveFontSize,
        );
      }
    } else {
      // Default overflow handling for larger screens
      effectiveOverflow ??= TextOverflow.ellipsis;
    }

    return Text(
      text,
      style: effectiveStyle,
      maxLines: effectiveMaxLines,
      overflow: effectiveOverflow,
      textAlign: textAlign,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

/// A responsive text widget specifically for titles
class ResponsiveTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;

  const ResponsiveTitle(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveText(
      text,
      style: style ?? theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
      ),
      maxLines: maxLines ?? (ResponsiveUtils.isSmallScreen(context) ? 2 : 1),
      textAlign: textAlign ?? TextAlign.start,
      smallFontSize: 16,
      mediumFontSize: 18,
      largeFontSize: 20,
    );
  }
}

/// A responsive text widget specifically for subtitles
class ResponsiveSubtitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;

  const ResponsiveSubtitle(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveText(
      text,
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: color ?? theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      maxLines: maxLines ?? (ResponsiveUtils.isSmallScreen(context) ? 3 : 2),
      textAlign: textAlign ?? TextAlign.start,
      smallFontSize: 12,
      mediumFontSize: 14,
      largeFontSize: 16,
    );
  }
}

/// A responsive text widget specifically for body text
class ResponsiveBodyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;

  const ResponsiveBodyText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveText(
      text,
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: color,
      ),
      maxLines: maxLines,
      textAlign: textAlign ?? TextAlign.start,
      smallFontSize: 14,
      mediumFontSize: 16,
      largeFontSize: 18,
    );
  }
}

/// A responsive text widget specifically for captions
class ResponsiveCaption extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;

  const ResponsiveCaption(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ResponsiveText(
      text,
      style: style ?? theme.textTheme.bodySmall?.copyWith(
        color: color ?? theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      maxLines: maxLines ?? (ResponsiveUtils.isSmallScreen(context) ? 2 : 1),
      textAlign: textAlign ?? TextAlign.start,
      smallFontSize: 10,
      mediumFontSize: 12,
      largeFontSize: 14,
    );
  }
}