// lib/features/products/widgets/products_empty_state.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';
import 'package:provider/provider.dart';

class ProductsEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onAddProduct;

  const ProductsEmptyState({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
              size: 120,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              hasFilters 
                  ? languageProvider.translate('no_products_found')
                  : languageProvider.translate('no_products_registered'),
              style: const TextStyle(
                fontSize: AppSizes.textXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              hasFilters
                  ? languageProvider.translate('try_different_filters')
                  : languageProvider.translate('add_first_product_message'),
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXL),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: Text(languageProvider.translate('clear_filters')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add_circle),
                label: Text(languageProvider.translate('add_first_product')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXL,
                    vertical: AppSizes.paddingL,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}