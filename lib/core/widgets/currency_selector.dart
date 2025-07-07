// lib/core/widgets/currency_selector.dart - DISEÑO COMPACTO SIN OVERFLOW
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/currency_provider.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Card(
          elevation: 2,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE PARA EVITAR OVERFLOW
              children: [
                // ✅ HEADER MÁS COMPACTO
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // ✅ REDUCIDO DE 8 A 6
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6), // ✅ REDUCIDO DE 8 A 6
                      ),
                      child: Icon(
                        Icons.attach_money,
                        color: AppColors.success,
                        size: 18, // ✅ REDUCIDO DE 20 A 18
                      ),
                    ),
                    const SizedBox(width: 8), // ✅ REDUCIDO DE 12 A 8
                    const Expanded(
                      child: Text(
                        'Moneda',
                        style: TextStyle(
                          fontSize: 14, // ✅ REDUCIDO DE 16 A 14
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // ✅ REDUCIDO DE 12 A 8
                
                // ✅ DROPDOWN MÁS COMPACTO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // ✅ REDUCIDO PADDING
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6), // ✅ REDUCIDO DE 8 A 6
                    color: AppColors.background,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currencyProvider.currentCurrency,
                      isExpanded: true,
                      isDense: true, // ✅ HACER MÁS DENSO
                      icon: const Icon(
                        Icons.expand_more,
                        color: AppColors.textSecondary,
                        size: 18, // ✅ REDUCIDO DE 24 A 18
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13, // ✅ REDUCIDO DE 14 A 13
                      ),
                      items: currencyProvider.availableCurrencies.map((currencyCode) {
                        final currencyInfo = currencyProvider.getCurrencyInfo(currencyCode);
                        return DropdownMenuItem<String>(
                          value: currencyCode,
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // ✅ EVITAR OVERFLOW
                            children: [
                              // ✅ SÍMBOLO DE MONEDA
                              Container(
                                width: 24, // ✅ ANCHO FIJO PARA SÍMBOLO
                                child: Text(
                                  currencyInfo['symbol']!,
                                  style: const TextStyle(
                                    fontSize: 14, // ✅ REDUCIDO DE 16 A 14
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 6), // ✅ REDUCIDO DE 8 A 6
                              // ✅ NOMBRE EXPANDIDO CON OVERFLOW CONTROL
                              Expanded(
                                child: Text(
                                  currencyInfo['name']!,
                                  style: const TextStyle(
                                    fontSize: 13, // ✅ REDUCIDO DE 14 A 13
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis, // ✅ CONTROLAR OVERFLOW
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newCurrency) {
                        if (newCurrency != null) {
                          currencyProvider.setCurrency(newCurrency);
                          
                          // ✅ MENSAJE MÁS COMPACTO
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Moneda: ${currencyProvider.getCurrencyInfo(newCurrency)['name']}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6), // ✅ REDUCIDO DE 8 A 6
                
                // ✅ TEXTO DESCRIPTIVO MÁS CORTO
                Text(
                  'Precios en ${currencyProvider.currencyName}', // ✅ TEXTO MÁS CORTO
                  style: const TextStyle(
                    fontSize: 11, // ✅ REDUCIDO DE 12 A 11
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // ✅ CONTROLAR OVERFLOW
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}