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
    _isInitialized = true;
    notifyListeners();
  }
  
  // Cargar idioma guardado con optimización
  Future<void> loadSavedLanguage() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final savedLanguage = _prefs!.getString(_languageKey);
      
      if (savedLanguage != null && AppLanguages.isSupported(savedLanguage)) {
        _currentLanguage = savedLanguage;
        // Precargar el idioma para mejor rendimiento
        AppLanguages.preloadLanguage(savedLanguage);
      } else {
        // Precargar idioma por defecto
        AppLanguages.preloadLanguage(_currentLanguage);
      }
    } catch (e) {
      debugPrint('Error cargando idioma guardado: $e');
      // Precargar idioma por defecto en caso de error
      AppLanguages.preloadLanguage(_currentLanguage);
    }
  }
  
  // Cambiar idioma con validación mejorada
  Future<bool> changeLanguage(String languageCode) async {
    // Validar que el idioma sea soportado y diferente al actual
    if (!AppLanguages.isSupported(languageCode) || _currentLanguage == languageCode) {
      return false;
    }
    
    try {
      // Precargar el nuevo idioma antes de cambiar
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
  
  // Obtener traducción optimizada
  String translate(String key) {
    return AppLanguages.translate(_currentLanguage, key);
  }
  
  // Método helper para traducciones con parámetros
  String translateWithParams(String key, Map<String, dynamic> params) {
    String translation = translate(key);
    
    // Reemplazar parámetros en la traducción
    params.forEach((paramKey, value) {
      translation = translation.replaceAll('{$paramKey}', value.toString());
    });
    
    return translation;
  }
  
  // Obtener lista de idiomas disponibles con estado
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
  
  // Obtener dirección del texto (útil para idiomas RTL en el futuro)
  TextDirection get textDirection {
    // Por ahora todos los idiomas son LTR
    // Pero esto permite fácil expansión para árabe, hebreo, etc.
    switch (_currentLanguage) {
      // case 'ar': // Árabe
      // case 'he': // Hebreo
      //   return TextDirection.rtl;
      default:
        return TextDirection.ltr;
    }
  }
  
  // Precargar todos los idiomas (útil para configuración)
  Future<void> preloadAllLanguages() async {
    AppLanguages.preloadAllLanguages();
  }
  
  // Limpiar cache de traducciones (útil para liberar memoria)
  void clearTranslationsCache() {
    AppLanguages.clearCache();
    // Recargar el idioma actual
    AppLanguages.preloadLanguage(_currentLanguage);
  }
  
  // Verificar traducciones faltantes (útil en desarrollo)
  Map<String, List<String>> checkMissingTranslations() {
    return AppLanguages.checkMissingTranslations();
  }
  
  // Obtener todas las keys de traducción (útil para testing)
  Set<String> getAllTranslationKeys() {
    return AppLanguages.getAllTranslationKeys();
  }
  
  @override
  void dispose() {
    // No es necesario limpiar el cache aquí ya que es estático
    // pero podría ser útil en algunos casos
    // AppLanguages.clearCache();
    super.dispose();
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
  
  // Método helper para crear una copia con nuevo estado de selección
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