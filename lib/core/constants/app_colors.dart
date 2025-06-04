// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
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
  
  // 🌟 GRADIENTES
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF1E3A8A),
    ],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFFDBA74),
    ],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF047857),
    ],
  );
  
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
}