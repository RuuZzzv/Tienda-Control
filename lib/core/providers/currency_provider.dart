// lib/core/providers/currency_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider with ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  
  String _currentCurrency = 'USD'; // Default: Dólares
  SharedPreferences? _prefs;
  
  // Monedas disponibles
  static const Map<String, Map<String, String>> _availableCurrencies = {
    'USD': {
      'name': 'Dólar',
      'symbol': '\$',
      'code': 'USD',
      'locale': 'en_US',
    },
    'EUR': {
      'name': 'Euro',
      'symbol': '€',
      'code': 'EUR',
      'locale': 'es_ES',
    },
    'PEN': {
      'name': 'Sol',
      'symbol': 'S/.',
      'code': 'PEN',
      'locale': 'es_PE',
    },
  };

  String get currentCurrency => _currentCurrency;
  String get currencySymbol => _availableCurrencies[_currentCurrency]?['symbol'] ?? '\$';
  String get currencyName => _availableCurrencies[_currentCurrency]?['name'] ?? 'Dólar';
  String get currencyCode => _availableCurrencies[_currentCurrency]?['code'] ?? 'USD';
  String get currencyLocale => _availableCurrencies[_currentCurrency]?['locale'] ?? 'en_US';
  
  List<String> get availableCurrencies => _availableCurrencies.keys.toList();
  
  Map<String, String> getCurrencyInfo(String currencyCode) {
    return _availableCurrencies[currencyCode] ?? _availableCurrencies['USD']!;
  }

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedCurrency = _prefs?.getString(_currencyKey);
      
      if (savedCurrency != null && _availableCurrencies.containsKey(savedCurrency)) {
        _currentCurrency = savedCurrency;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading currency: $e');
    }
  }

  Future<void> setCurrency(String currencyCode) async {
    if (!_availableCurrencies.containsKey(currencyCode)) {
      print('Currency not supported: $currencyCode');
      return;
    }

    if (_currentCurrency != currencyCode) {
      _currentCurrency = currencyCode;
      
      try {
        await _prefs?.setString(_currencyKey, currencyCode);
      } catch (e) {
        print('Error saving currency: $e');
      }
      
      notifyListeners();
    }
  }

  // Formatear precio según la moneda seleccionada
  String formatPrice(double price) {
    switch (_currentCurrency) {
      case 'USD':
        return '\$${price.toStringAsFixed(2)}';
      case 'EUR':
        return '€${price.toStringAsFixed(2)}';
      case 'PEN':
        return 'S/.${price.toStringAsFixed(2)}';
      default:
        return '\$${price.toStringAsFixed(2)}';
    }
  }

  // Formatear precio sin decimales
  String formatPriceShort(double price) {
    switch (_currentCurrency) {
      case 'USD':
        return '\$${price.toStringAsFixed(0)}';
      case 'EUR':
        return '€${price.toStringAsFixed(0)}';
      case 'PEN':
        return 'S/.${price.toStringAsFixed(0)}';
      default:
        return '\$${price.toStringAsFixed(0)}';
    }
  }
}
