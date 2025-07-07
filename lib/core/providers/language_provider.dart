// lib/core/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_languages.dart';

class LanguageProvider extends ChangeNotifier {
  // Estado privado
  String _currentLanguage = AppLanguages.defaultLanguage;
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  // Constantes
  static const String _languageKey = 'app_language';
  
  // Getters
  String get currentLanguage => _currentLanguage;
  bool get isInitialized => _isInitialized;
  
  // Obtener información del idioma actual
  String get currentLanguageName {
    return AppLanguages.getLanguageInfo(_currentLanguage)?.name ?? 'Español';
  }
  
  String get currentLanguageFlag {
    return AppLanguages.getLanguageInfo(_currentLanguage)?.flag ?? '🇪🇸';
  }
  
  // Constructor
  LanguageProvider() {
    _initialize();
  }
  
  // Inicialización asíncrona
  Future<void> _initialize() async {
    await loadSavedLanguage();
    // Precargar todas las traducciones
    AppLanguages.preloadAllLanguages();
    _isInitialized = true;
    notifyListeners();
  }
  
  // Cargar idioma guardado
  Future<void> loadSavedLanguage() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final savedLanguage = _prefs!.getString(_languageKey);
      
      if (savedLanguage != null && AppLanguages.isSupported(savedLanguage)) {
        _currentLanguage = savedLanguage;
      }
    } catch (e) {
      debugPrint('Error cargando idioma guardado: $e');
    }
  }
  
  // Cambiar idioma
  Future<bool> changeLanguage(String languageCode) async {
    if (!AppLanguages.isSupported(languageCode) || _currentLanguage == languageCode) {
      return false;
    }
    
    try {
      // Precargar el nuevo idioma
      AppLanguages.preloadLanguage(languageCode);
      
      // Actualizar estado
      _currentLanguage = languageCode;
      
      // Guardar en preferencias
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_languageKey, languageCode);
      
      // Notificar cambios
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error guardando idioma: $e');
      return false;
    }
  }
  
  // Obtener traducción
  String translate(String key) {
    return AppLanguages.translate(_currentLanguage, key);
  }
  
  // Método para traducciones con parámetros
  String translateWithParams(String key, Map<String, dynamic> params) {
    String translation = translate(key);
    
    // Reemplazar parámetros en la traducción
    params.forEach((paramKey, value) {
      translation = translation.replaceAll('{$paramKey}', value.toString());
    });
    
    return translation;
  }
  
  // Obtener lista de idiomas disponibles
  List<LanguageOption> get availableLanguages {
    return AppLanguages.supportedLanguages.map((code) {
      final info = AppLanguages.getLanguageInfo(code);
      return LanguageOption(
        code: code,
        name: info?.name ?? code,
        flag: info?.flag ?? '🏳️',
        isSelected: _currentLanguage == code,
      );
    }).toList();
  }
  
  // Verificar si un idioma está activo
  bool isLanguageActive(String languageCode) {
    return _currentLanguage == languageCode;
  }
  
  // Obtener dirección del texto
  TextDirection get textDirection => TextDirection.ltr;
  
  // Métodos de utilidad
  String get appName => translate('app_name');
  String get welcomeMessage => translate('welcome');
  String getCurrentGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return translate('good_morning');
    } else if (hour < 18) {
      return translate('good_afternoon');
    } else {
      return translate('good_evening');
    }
  }
  
  // Formatear fecha según el idioma
  String formatDate(DateTime date) {
    // Implementar formateo de fecha según el idioma seleccionado
    switch (_currentLanguage) {
      case 'es':
        return '${date.day}/${date.month}/${date.year}';
      case 'en':
        return '${date.month}/${date.day}/${date.year}';
      case 'it':
        return '${date.day}/${date.month}/${date.year}';
      default:
        return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  // Formatear hora según el idioma
  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    
    switch (_currentLanguage) {
      case 'en':
        // Formato 12 horas para inglés
        final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final period = hour < 12 ? 'AM' : 'PM';
        return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      default:
        // Formato 24 horas para español e italiano
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
  }
}

// Modelo para opciones de idioma
class LanguageOption {
  final String code;
  final String name;
  final String flag;
  final bool isSelected;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
    required this.isSelected,
  });
  
  LanguageOption copyWith({bool? isSelected}) {
    return LanguageOption(
      code: code,
      name: name,
      flag: flag,
      isSelected: isSelected ?? this.isSelected,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageOption &&
          runtimeType == other.runtimeType &&
          code == other.code;
  
  @override
  int get hashCode => code.hashCode;
}
