// lib/features/products/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/extensions/build_context_extensions.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAddStock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onAddStock,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.tieneStockBajo;
    final isOutOfStock = product.sinStock;

    return Consumer2<CurrencyProvider, LanguageProvider>(
      builder: (context, currencyProvider, langProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutOfStock
                ? const BorderSide(color: AppColors.error, width: 1)
                : isLowStock
                    ? const BorderSide(color: AppColors.warning, width: 1)
                    : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono del producto
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppColors.error.withOpacity(0.1)
                          : isLowStock
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      size: 24,
                      color: isOutOfStock
                          ? AppColors.error
                          : isLowStock
                              ? AppColors.warning
                              : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Información del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${langProvider.translate('code')}: ${product.codigoDisplay}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${langProvider.translate('stock')}: ${product.stockActualSafe} ${product.unidadMedidaDisplay}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock
                                    ? AppColors.error
                                    : isLowStock
                                        ? AppColors.warning
                                        : AppColors.success,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              currencyProvider.formatPriceShort(product.precioVenta),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Acciones
                  if (onEdit != null || onAddStock != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'add_stock':
                            onAddStock?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 18),
                                const SizedBox(width: 8),
                                Text(langProvider.translate('edit')),
                              ],
                            ),
                          ),
                        if (onAddStock != null)
                          PopupMenuItem(
                            value: 'add_stock',
                            child: Row(
                              children: [
                                const Icon(Icons.add_box, size: 18),
                                const SizedBox(width: 8),
                                Text(langProvider.translate('add_stock')),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}