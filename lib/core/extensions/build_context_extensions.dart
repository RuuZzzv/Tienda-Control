  // lib/core/extensions/build_context_extensions.dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../providers/language_provider.dart';

  extension BuildContextExtensions on BuildContext {
    // Método de conveniencia para obtener traducciones
    String tr(String key) {
      return Provider.of<LanguageProvider>(this, listen: false).translate(key);
    }
    
    // Método de conveniencia para traducciones con parámetros
    String trParams(String key, Map<String, dynamic> params) {
      return Provider.of<LanguageProvider>(this, listen: false)
          .translateWithParams(key, params);
    }
    
    // Obtener el provider de idioma
    LanguageProvider get languageProvider {
      return Provider.of<LanguageProvider>(this, listen: false);
    }
    
    // Obtener el provider de idioma con escucha
    LanguageProvider get watchLanguageProvider {
      return Provider.of<LanguageProvider>(this, listen: true);
    }
    
    // Verificar si un idioma está activo
    bool isLanguageActive(String languageCode) {
      return languageProvider.isLanguageActive(languageCode);
    }
    
    // Obtener saludo según la hora
    String get currentGreeting {
      return languageProvider.getCurrentGreeting();
    }
    
    // Formatear fecha
    String formatDate(DateTime date) {
      return languageProvider.formatDate(date);
    }
    
    // Formatear hora
    String formatTime(DateTime time) {
      return languageProvider.formatTime(time);
    }
  }