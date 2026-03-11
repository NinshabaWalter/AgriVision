import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double _smallScreenWidth = 360;
  static const double _mediumScreenWidth = 600;
  static const double _largeScreenWidth = 900;

  /// Check if the screen is small (phones)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _smallScreenWidth;
  }

  /// Check if the screen is medium (tablets)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _smallScreenWidth && width < _largeScreenWidth;
  }

  /// Check if the screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _largeScreenWidth;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double small = 12.0,
    double medium = 16.0,
    double large = 24.0,
  }) {
    if (isSmallScreen(context)) {
      return EdgeInsets.all(small);
    } else if (isMediumScreen(context)) {
      return EdgeInsets.all(medium);
    } else {
      return EdgeInsets.all(large);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double small = 8.0,
    double medium = 12.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) {
      return EdgeInsets.all(small);
    } else if (isMediumScreen(context)) {
      return EdgeInsets.all(medium);
    } else {
      return EdgeInsets.all(large);
    }
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, {
    double small = 12.0,
    double medium = 14.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive icon size based on screen size
  static double getResponsiveIconSize(BuildContext context, {
    double small = 20.0,
    double medium = 24.0,
    double large = 28.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, {
    double small = 8.0,
    double medium = 12.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive grid cross axis count
  static int getResponsiveGridCount(BuildContext context, {
    int small = 2,
    int medium = 3,
    int large = 4,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive card elevation
  static double getResponsiveElevation(BuildContext context, {
    double small = 2.0,
    double medium = 4.0,
    double large = 6.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context, {
    double small = 8.0,
    double medium = 12.0,
    double large = 16.0,
  }) {
    if (isSmallScreen(context)) {
      return BorderRadius.circular(small);
    } else if (isMediumScreen(context)) {
      return BorderRadius.circular(medium);
    } else {
      return BorderRadius.circular(large);
    }
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive text style based on screen size
  static TextStyle getResponsiveTextStyle(BuildContext context, {
    required TextStyle baseStyle,
    double? smallFontSize,
    double? mediumFontSize,
    double? largeFontSize,
  }) {
    double fontSize = baseStyle.fontSize ?? 14.0;
    
    if (isSmallScreen(context) && smallFontSize != null) {
      fontSize = smallFontSize;
    } else if (isMediumScreen(context) && mediumFontSize != null) {
      fontSize = mediumFontSize;
    } else if (isLargeScreen(context) && largeFontSize != null) {
      fontSize = largeFontSize;
    }

    return baseStyle.copyWith(fontSize: fontSize);
  }

  /// Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context, {
    double? maxWidth,
    double? maxHeight,
  }) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    return BoxConstraints(
      maxWidth: maxWidth ?? screenWidth * 0.9,
      maxHeight: maxHeight ?? screenHeight * 0.8,
    );
  }
}