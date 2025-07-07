// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Prevenir instanciación
  AppColors._();

  // 🟡 PALETA PRINCIPAL CON AMARILLO
  static const Color primary = Color(0xFF1E3A8A);        // Azul marino profundo
  static const Color primaryLight = Color(0xFF3B82F6);   // Azul brillante
  static const Color primaryDark = Color(0xFF1E2A78);    // Azul marino oscuro
  
  // ⭐ AMARILLO COMO ACCENT
  static const Color accent = Color(0xFFFDBA74);         // Amarillo dorado suave
  static const Color accentBright = Color(0xFFFBBF24);   // Amarillo vibrante
  static const Color accentLight = Color(0xFFFEF3C7);    // Amarillo muy claro
  static const Color accentDark = Color(0xFFD97706);     // Naranja dorado
  
  // 🎨 COLORES SECUNDARIOS ARMONIOSOS
  static const Color secondary = Color(0xFF6366F1);      // Índigo moderno
  static const Color secondaryLight = Color(0xFF818CF8); // Índigo claro
  
  // 🌈 SUPERFICIES Y FONDOS
  static const Color background = Color(0xFFFAFAFA);     // Gris muy claro
  static const Color surface = Color(0xFFFFFFFF);        // Blanco puro
  static const Color surfaceLight = Color(0xFFF8FAFC);   // Blanco azulado
  static const Color cardBackground = Color(0xFFFFFFFF);  // Blanco para cards
  
  // 📝 TEXTOS CON MEJOR CONTRASTE
  static const Color textPrimary = Color(0xFF1F2937);    // Gris muy oscuro
  static const Color textSecondary = Color(0xFF6B7280);  // Gris medio
  static const Color textTertiary = Color(0xFF9CA3AF);   // Gris claro
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // Blanco
  static const Color textOnAccent = Color(0xFF1F2937);   // Oscuro para amarillo
  
  // ✅ ESTADOS SEMÁNTICOS
  static const Color success = Color(0xFF10B981);        // Verde esmeralda
  static const Color successLight = Color(0xFF6EE7B7);   // Verde claro
  static const Color successDark = Color(0xFF047857);    // Verde oscuro
  
  static const Color warning = Color(0xFFF59E0B);        // Naranja cálido
  static const Color warningLight = Color(0xFFFDE68A);   // Naranja claro
  static const Color warningDark = Color(0xFFD97706);    // Naranja oscuro
  
  static const Color error = Color(0xFFEF4444);          // Rojo coral
  static const Color errorLight = Color(0xFFFECACA);     // Rojo claro
  static const Color errorDark = Color(0xFFDC2626);      // Rojo oscuro
  
  static const Color info = Color(0xFF3B82F6);           // Azul información
  static const Color infoLight = Color(0xFFBFDBFE);      // Azul claro
  static const Color infoDark = Color(0xFF1D4ED8);       // Azul oscuro
  
  // 🎯 ELEMENTOS DE UI
  static const Color divider = Color(0xFFE5E7EB);        // Divisor sutil
  static const Color border = Color(0xFFD1D5DB);         // Bordes
  static const Color shadow = Color(0x1A000000);         // Sombra suave
  static const Color overlay = Color(0x80000000);        // Overlay modal
  
  // 🌟 GRADIENTES - Lazy loading para mejorar rendimiento
  static LinearGradient? _primaryGradient;
  static LinearGradient get primaryGradient {
    _primaryGradient ??= const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
    );
    return _primaryGradient!;
  }
  
  static LinearGradient? _accentGradient;
  static LinearGradient get accentGradient {
    _accentGradient ??= const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFBBF24), Color(0xFFFDBA74)],
    );
    return _accentGradient!;
  }
  
  static LinearGradient? _successGradient;
  static LinearGradient get successGradient {
    _successGradient ??= const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF10B981), Color(0xFF047857)],
    );
    return _successGradient!;
  }
  
  // 🎨 PALETA PARA GRÁFICOS Y CHARTS
  static const List<Color> chartColors = [
    Color(0xFFFBBF24), // Amarillo
    Color(0xFF3B82F6), // Azul
    Color(0xFF10B981), // Verde
    Color(0xFFF59E0B), // Naranja
    Color(0xFF6366F1), // Índigo
    Color(0xFFEF4444), // Rojo
    Color(0xFF8B5CF6), // Violeta
    Color(0xFF06B6D4), // Cyan
  ];
  
  // 🌙 MODO OSCURO (para futuro)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  
  // 🎨 MATERIAL COLOR SWATCH - Lazy loading para temas
  static MaterialColor? _primarySwatch;
  static MaterialColor get primarySwatch {
    _primarySwatch ??= MaterialColor(
      primary.value,
      const {
        50: Color(0xFFE7F0FF),
        100: Color(0xFFC3D9FE),
        200: Color(0xFF93BBFD),
        300: Color(0xFF629DFC),
        400: Color(0xFF3B82F6),
        500: Color(0xFF1E3A8A),
        600: Color(0xFF1A2F6F),
        700: Color(0xFF162558),
        800: Color(0xFF111B42),
        900: Color(0xFF0D1430),
      },
    );
    return _primarySwatch!;
  }

  static MaterialColor? _accentSwatch;
  static MaterialColor get accentSwatch {
    _accentSwatch ??= MaterialColor(
      accent.value,
      const {
        50: Color(0xFFFFFBEB),
        100: Color(0xFFFEF3C7),
        200: Color(0xFFFDE68A),
        300: Color(0xFFFCD34D),
        400: Color(0xFFFBBF24),
        500: Color(0xFFFDBA74),
        600: Color(0xFFD97706),
        700: Color(0xFFB45309),
        800: Color(0xFF92400E),
        900: Color(0xFF78350F),
      },
    );
    return _accentSwatch!;
  }

  // 🎯 MÉTODOS HELPER para facilitar el uso
  
  /// Obtiene un color con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Determina si un color es claro u oscuro
  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// Obtiene el color de texto apropiado para un fondo
  static Color getTextColorFor(Color backgroundColor) {
    return isLight(backgroundColor) ? textPrimary : textOnPrimary;
  }

  /// Obtiene el color de estado según la condición
  static Color getStatusColor({
    required bool isOk,
    required bool isWarning,
    required bool isError,
  }) {
    if (isError) return error;
    if (isWarning) return warning;
    if (isOk) return success;
    return info;
  }

  // 🎨 SOMBRAS PREDEFINIDAS - Lazy loading
  static List<BoxShadow>? _cardShadow;
  static List<BoxShadow> get cardShadow {
    _cardShadow ??= [
      const BoxShadow(
        color: shadow,
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ];
    return _cardShadow!;
  }

  static List<BoxShadow>? _elevatedShadow;
  static List<BoxShadow> get elevatedShadow {
    _elevatedShadow ??= [
      const BoxShadow(
        color: shadow,
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: shadow.withOpacity(0.08),
        offset: const Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ];
    return _elevatedShadow!;
  }

  // 🎨 THEME DATA HELPER - Para configuración rápida de temas
  static ThemeData? _lightTheme;
  static ThemeData get lightTheme {
    _lightTheme ??= ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: primarySwatch,
        accentColor: accent,
        backgroundColor: background,
        errorColor: error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      cardColor: cardBackground,
      dividerColor: divider,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
    return _lightTheme!;
  }
}