// lib/core/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_languages.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'es'; // Español por defecto
  final Map<String, Map<String, String>> _translations = AppLanguages.translations;

  String get currentLanguage => _currentLanguage;
  
  // Obtener el nombre del idioma actual
  String get currentLanguageName {
    switch (_currentLanguage) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'it':
        return 'Italiano';
      default:
        return 'Español';
    }
  }

  // Obtener bandera del idioma actual
  String get currentLanguageFlag {
    switch (_currentLanguage) {
      case 'es':
        return '🇪🇸';
      case 'en':
        return '🇺🇸';
      case 'it':
        return '🇮🇹';
      default:
        return '🇪🇸';
    }
  }

  // Cargar idioma guardado
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('app_language');
      if (savedLanguage != null && _translations.containsKey(savedLanguage)) {
        _currentLanguage = savedLanguage;
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando idioma guardado: $e');
    }
  }

  // Cambiar idioma
  Future<void> changeLanguage(String languageCode) async {
    if (_translations.containsKey(languageCode) && _currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app_language', languageCode);
      } catch (e) {
        print('Error guardando idioma: $e');
      }
      
      notifyListeners();
    }
  }

  // Obtener traducción
  String translate(String key) {
    final languageMap = _translations[_currentLanguage];
    if (languageMap != null && languageMap.containsKey(key)) {
      return languageMap[key]!;
    }
    
    // Fallback al español si no existe la traducción
    final fallbackMap = _translations['es'];
    if (fallbackMap != null && fallbackMap.containsKey(key)) {
      return fallbackMap[key]!;
    }
    
    // Si no existe en ningún lado, devolver la key
    return key;
  }

  // Obtener lista de idiomas disponibles
  List<LanguageOption> get availableLanguages {
    return [
      LanguageOption(
        code: 'es',
        name: 'Español',
        flag: '🇪🇸',
        isSelected: _currentLanguage == 'es',
      ),
      LanguageOption(
        code: 'en',
        name: 'English',
        flag: '🇺🇸',
        isSelected: _currentLanguage == 'en',
      ),
      LanguageOption(
        code: 'it',
        name: 'Italiano',
        flag: '🇮🇹',
        isSelected: _currentLanguage == 'it',
      ),
    ];
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  final bool isSelected;

  LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
    required this.isSelected,
  });
}