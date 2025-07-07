// lib/core/utils/currency_utils.dart - ACTUALIZADO
import '../providers/currency_provider.dart';

class CurrencyUtils {
  // Formatear precio usando el provider
  static String formatPrice(double price, CurrencyProvider currencyProvider) {
    return currencyProvider.formatPrice(price);
  }

  // Formatear precio corto usando el provider
  static String formatPriceShort(double price, CurrencyProvider currencyProvider) {
    return currencyProvider.formatPriceShort(price);
  }

  // Obtener símbolo de moneda
  static String getCurrencySymbol(CurrencyProvider currencyProvider) {
    return currencyProvider.currencySymbol;
  }

  // Validar formato de precio según la moneda
  static bool isValidPrice(String priceText, CurrencyProvider currencyProvider) {
    if (priceText.isEmpty) return false;
    
    // Remover símbolo de moneda si está presente
    String cleanText = priceText
        .replaceAll(currencyProvider.currencySymbol, '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    
    final price = double.tryParse(cleanText);
    return price != null && price >= 0;
  }

  // Convertir texto a double removiendo símbolos de moneda
  static double? parsePrice(String priceText, CurrencyProvider currencyProvider) {
    if (priceText.isEmpty) return null;
    
    String cleanText = priceText
        .replaceAll(currencyProvider.currencySymbol, '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanText);
  }
}