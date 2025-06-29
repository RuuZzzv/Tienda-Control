// lib/features/products/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAddStock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onAddStock,
  });

  @override
  Widget build(BuildContext context) {
    final stockStatus = _getStockStatus();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(
          color: stockStatus.borderColor,
          width: stockStatus.hasBorder ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            children: [
              Row(
                children: [
                  // Icono del producto
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: stockStatus.iconBackgroundColor,
                      borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      size: AppSizes.iconL,
                      color: stockStatus.iconColor,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),

                  // Información del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.nombre,
                                style: const TextStyle(
                                  fontSize: AppSizes.textL,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (stockStatus.showBadge)
                              Container(
                                margin: const EdgeInsets.only(left: AppSizes.paddingS),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingS,
                                  vertical: AppSizes.paddingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: stockStatus.badgeColor,
                                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                                ),
                                child: Text(
                                  stockStatus.badgeText,
                                  style: const TextStyle(
                                    fontSize: AppSizes.textS,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        
                        // Código y categoría
                        Row(
                          children: [
                            const Icon(
                              Icons.qr_code,
                              size: AppSizes.iconS,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSizes.paddingXS),
                            Text(
                              product.codigoDisplay,
                              style: const TextStyle(
                                fontSize: AppSizes.textS,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (product.categoriaNombre != null) ...[
                              const SizedBox(width: AppSizes.paddingM),
                              const Icon(
                                Icons.category,
                                size: AppSizes.iconS,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: AppSizes.paddingXS),
                              Expanded(
                                child: Text(
                                  product.categoriaNombre!,
                                  style: const TextStyle(
                                    fontSize: AppSizes.textS,
                                    color: AppColors.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        
                        // Stock y precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  stockStatus.stockIcon,
                                  size: AppSizes.iconM,
                                  color: stockStatus.stockColor,
                                ),
                                const SizedBox(width: AppSizes.paddingXS),
                                Text(
                                  'Stock: ${product.stockActualSafe} ${product.unidadMedidaDisplay}',
                                  style: TextStyle(
                                    fontSize: AppSizes.textM,
                                    color: stockStatus.stockColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'es_CO',
                                symbol: '\$',
                              ).format(product.precioVenta),
                              style: const TextStyle(
                                fontSize: AppSizes.textL,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Acciones rápidas
              const Divider(height: AppSizes.paddingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAction(
                    icon: Icons.visibility,
                    label: 'Ver',
                    onTap: onTap,
                    color: AppColors.primary,
                  ),
                  _QuickAction(
                    icon: Icons.edit,
                    label: 'Editar',
                    onTap: onEdit,
                    color: AppColors.accent,
                  ),
                  _QuickAction(
                    icon: Icons.add_box,
                    label: 'Stock',
                    onTap: onAddStock,
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StockStatus _getStockStatus() {
    if (product.stockActualSafe == 0) {
      return _StockStatus(
        iconColor: AppColors.error,
        iconBackgroundColor: AppColors.error.withOpacity(0.1),
        borderColor: AppColors.error,
        hasBorder: true,
        stockColor: AppColors.error,
        stockIcon: Icons.remove_circle,
        showBadge: true,
        badgeColor: AppColors.error,
        badgeText: 'Sin Stock',
      );
    } else if (product.tieneStockBajo) {
      return _StockStatus(
        iconColor: AppColors.warning,
        iconBackgroundColor: AppColors.warning.withOpacity(0.1),
        borderColor: AppColors.warning,
        hasBorder: true,
        stockColor: AppColors.warning,
        stockIcon: Icons.warning,
        showBadge: true,
        badgeColor: AppColors.warning,
        badgeText: 'Stock Bajo',
      );
    } else {
      return _StockStatus(
        iconColor: AppColors.primary,
        iconBackgroundColor: AppColors.primary.withOpacity(0.1),
        borderColor: Colors.transparent,
        hasBorder: false,
        stockColor: AppColors.success,
        stockIcon: Icons.check_circle,
        showBadge: false,
        badgeColor: Colors.transparent,
        badgeText: '',
      );
    }
  }
}

class _StockStatus {
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color borderColor;
  final bool hasBorder;
  final Color stockColor;
  final IconData stockIcon;
  final bool showBadge;
  final Color badgeColor;
  final String badgeText;

  _StockStatus({
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.borderColor,
    required this.hasBorder,
    required this.stockColor,
    required this.stockIcon,
    required this.showBadge,
    required this.badgeColor,
    required this.badgeText,
  });
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: AppSizes.iconM),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.textS,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}