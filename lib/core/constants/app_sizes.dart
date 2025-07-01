// lib/core/constants/app_sizes.dart
import 'package:flutter/material.dart';

class AppSizes {
  // Prevenir instanciación
  AppSizes._();

  // 📝 TIPOGRAFÍA MEJORADA
  static const double textXS = 11.0;
  static const double textS = 13.0;
  static const double textM = 15.0;
  static const double textL = 17.0;
  static const double textXL = 20.0;
  static const double textXXL = 24.0;
  static const double textDisplay = 32.0;
  static const double textHero = 40.0;
  
  // 📏 ESPACIADO MODERNO (más generoso)
  static const double paddingXS = 6.0;
  static const double paddingS = 12.0;
  static const double paddingM = 20.0;
  static const double paddingL = 28.0;
  static const double paddingXL = 36.0;
  static const double paddingXXL = 48.0;
  
  // 🎯 ESPACIADO ENTRE SECCIONES
  static const double sectionSpacing = 40.0;
  static const double componentSpacing = 24.0;
  
  // 🎨 ICONOS CON MEJOR ESCALA
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 56.0;
  static const double iconHero = 80.0;
  
  // 🔲 BOTONES MODERNOS
  static const double buttonHeight = 52.0;
  static const double buttonHeightLarge = 64.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonMinWidth = 140.0;
  static const double buttonRadius = 16.0;
  static const double buttonRadiusLarge = 20.0;
  static const double buttonRadiusSmall = 12.0;
  
  // 📋 INPUTS ELEGANTES
  static const double inputHeight = 56.0;
  static const double inputRadius = 16.0;
  static const double inputBorderWidth = 1.5;
  static const double inputFocusedBorderWidth = 2.5;
  
  // 🎴 CARDS Y CONTENEDORES
  static const double cardRadius = 20.0;
  static const double cardRadiusLarge = 24.0;
  static const double cardRadiusSmall = 16.0;
  static const double cardElevation = 4.0;
  static const double cardElevationHover = 8.0;
  static const double containerRadius = 16.0;
  static const double statCardHeight = 140.0;
  
  // 🏗️ APP BAR Y NAVEGACIÓN
  static const double appBarHeight = 64.0;
  static const double bottomNavHeight = 70.0;
  static const double tabBarHeight = 48.0;
  
  // 📱 RESPONSIVE BREAKPOINTS
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
  
  // 🎯 COMPONENTES ESPECÍFICOS
  static const double avatarRadius = 28.0;
  static const double avatarRadiusLarge = 40.0;
  static const double avatarRadiusSmall = 20.0;
  
  static const double listItemHeight = 64.0;
  static const double listItemMinHeight = 48.0;
  
  static const double fabSize = 64.0;
  static const double fabRadius = 20.0;
  
  // 📦 MÁRGENES Y CONTENEDORES
  static const double screenPadding = 20.0;
  static const double screenPaddingLarge = 32.0;
  static const double dialogPadding = 28.0;
  static const double modalPadding = 24.0;
  static const double snackBarPadding = 20.0;
  
  // 📏 DIMENSIONES ESPECÍFICAS
  static const double modalBottomSheetMaxHeight = 500.0;
  static const double drawerWidth = 300.0;
  static const double loadingIndicatorSize = 28.0;
  static const double progressIndicatorHeight = 6.0;
  static const double dividerThickness = 1.0;
  static const double borderWidth = 1.5;
  
  // 🌊 ANIMACIONES Y TRANSICIONES
  static const int animationFastMs = 200;
  static const int animationMediumMs = 300;
  static const int animationSlowMs = 500;
  
  // Getters para Duration (lazy loading)
  static Duration? _animationFast;
  static Duration get animationFast {
    _animationFast ??= Duration(milliseconds: animationFastMs);
    return _animationFast!;
  }
  
  static Duration? _animationMedium;
  static Duration get animationMedium {
    _animationMedium ??= Duration(milliseconds: animationMediumMs);
    return _animationMedium!;
  }
  
  static Duration? _animationSlow;
  static Duration get animationSlow {
    _animationSlow ??= Duration(milliseconds: animationSlowMs);
    return _animationSlow!;
  }
  
  // 🎭 SOMBRAS MODERNAS
  static const double shadowBlurRadius = 12.0;
  static const double shadowSpreadRadius = 0.0;
  static const double shadowOffsetX = 0.0;
  static const double shadowOffsetY = 4.0;
  
  static const double shadowBlurRadiusLarge = 20.0;
  static const double shadowOffsetXLarge = 0.0;
  static const double shadowOffsetYLarge = 8.0;
  
  // 📐 GRID Y LAYOUT
  static const double gridSpacing = 16.0;
  static const double gridAspectRatio = 1.0;
  static const double gridAspectRatioWide = 1.5;
  static const double gridAspectRatioTall = 0.75;
  
  // 🎯 MÉTODOS HELPER RESPONSIVE
  
  /// Obtiene el tipo de dispositivo basado en el ancho
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Obtiene padding responsive según el dispositivo
  static double getResponsivePadding(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return screenPadding;
      case DeviceType.tablet:
        return screenPadding * 1.5;
      case DeviceType.desktop:
        return screenPaddingLarge;
    }
  }
  
  /// Obtiene el tamaño de texto responsive
  static double getResponsiveText(BuildContext context, TextSize size) {
    final scaleFactor = getDeviceType(context) == DeviceType.desktop ? 1.2 : 1.0;
    
    switch (size) {
      case TextSize.xs:
        return textXS * scaleFactor;
      case TextSize.s:
        return textS * scaleFactor;
      case TextSize.m:
        return textM * scaleFactor;
      case TextSize.l:
        return textL * scaleFactor;
      case TextSize.xl:
        return textXL * scaleFactor;
      case TextSize.xxl:
        return textXXL * scaleFactor;
      case TextSize.display:
        return textDisplay * scaleFactor;
      case TextSize.hero:
        return textHero * scaleFactor;
    }
  }
  
  /// Obtiene columnas para grid responsive
  static int getResponsiveColumns(BuildContext context, {int baseColumns = 2}) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return baseColumns;
      case DeviceType.tablet:
        return (baseColumns * 1.5).round();
      case DeviceType.desktop:
        return baseColumns * 2;
    }
  }
  
  /// Verifica si es pantalla pequeña
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Verifica si es pantalla grande
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // 🎨 EDGE INSETS PREDEFINIDOS (lazy loading)
  
  static EdgeInsets? _paddingAllXS;
  static EdgeInsets get paddingAllXS {
    _paddingAllXS ??= const EdgeInsets.all(paddingXS);
    return _paddingAllXS!;
  }
  
  static EdgeInsets? _paddingAllS;
  static EdgeInsets get paddingAllS {
    _paddingAllS ??= const EdgeInsets.all(paddingS);
    return _paddingAllS!;
  }
  
  static EdgeInsets? _paddingAllM;
  static EdgeInsets get paddingAllM {
    _paddingAllM ??= const EdgeInsets.all(paddingM);
    return _paddingAllM!;
  }
  
  static EdgeInsets? _paddingAllL;
  static EdgeInsets get paddingAllL {
    _paddingAllL ??= const EdgeInsets.all(paddingL);
    return _paddingAllL!;
  }
  
  static EdgeInsets? _paddingHorizontalM;
  static EdgeInsets get paddingHorizontalM {
    _paddingHorizontalM ??= const EdgeInsets.symmetric(horizontal: paddingM);
    return _paddingHorizontalM!;
  }
  
  static EdgeInsets? _paddingVerticalM;
  static EdgeInsets get paddingVerticalM {
    _paddingVerticalM ??= const EdgeInsets.symmetric(vertical: paddingM);
    return _paddingVerticalM!;
  }
  
  // 🎯 BORDER RADIUS PREDEFINIDOS (lazy loading)
  
  static BorderRadius? _radiusS;
  static BorderRadius get radiusS {
    _radiusS ??= BorderRadius.circular(buttonRadiusSmall);
    return _radiusS!;
  }
  
  static BorderRadius? _radiusM;
  static BorderRadius get radiusM {
    _radiusM ??= BorderRadius.circular(buttonRadius);
    return _radiusM!;
  }
  
  static BorderRadius? _radiusL;
  static BorderRadius get radiusL {
    _radiusL ??= BorderRadius.circular(buttonRadiusLarge);
    return _radiusL!;
  }
  
  static BorderRadius? _radiusCard;
  static BorderRadius get radiusCard {
    _radiusCard ??= BorderRadius.circular(cardRadius);
    return _radiusCard!;
  }
  
  // 🎨 SIZEDBOX PREDEFINIDOS (lazy loading)
  
  static const SizedBox gapXS = SizedBox(height: paddingXS, width: paddingXS);
  static const SizedBox gapS = SizedBox(height: paddingS, width: paddingS);
  static const SizedBox gapM = SizedBox(height: paddingM, width: paddingM);
  static const SizedBox gapL = SizedBox(height: paddingL, width: paddingL);
  static const SizedBox gapXL = SizedBox(height: paddingXL, width: paddingXL);
  
  // Gaps verticales
  static const SizedBox vGapXS = SizedBox(height: paddingXS);
  static const SizedBox vGapS = SizedBox(height: paddingS);
  static const SizedBox vGapM = SizedBox(height: paddingM);
  static const SizedBox vGapL = SizedBox(height: paddingL);
  static const SizedBox vGapXL = SizedBox(height: paddingXL);
  
  // Gaps horizontales
  static const SizedBox hGapXS = SizedBox(width: paddingXS);
  static const SizedBox hGapS = SizedBox(width: paddingS);
  static const SizedBox hGapM = SizedBox(width: paddingM);
  static const SizedBox hGapL = SizedBox(width: paddingL);
  static const SizedBox hGapXL = SizedBox(width: paddingXL);
}

// Enums para mejor type safety
enum DeviceType { mobile, tablet, desktop }

enum TextSize { xs, s, m, l, xl, xxl, display, hero }