// lib/features/inventory/widgets/stock_alert.dart
import 'package:flutter/material.dart';
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart'; // Agregar esta importación
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class StockAlert extends StatelessWidget {
  final List<Product> lowStockProducts;
  final List<Lote> expiredLotes;
  final List<Lote> expiringLotes;
  final VoidCallback? onViewAll;
  final Function(Product)? onProductTap;
  final Function(Lote)? onLoteTap;

  const StockAlert({
    super.key,
    this.lowStockProducts = const [],
    this.expiredLotes = const [],
    this.expiringLotes = const [],
    this.onViewAll,
    this.onProductTap,
    this.onLoteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay alertas, no mostrar nada
    if (lowStockProducts.isEmpty && expiredLotes.isEmpty && expiringLotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      color: AppColors.warning.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y botón ver todo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: AppColors.warning,
                    size: AppSizes.iconM,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                const Expanded(
                  child: Text(
                    'Alertas de Inventario',
                    style: TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text(
                      'Ver Todo',
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingM),

            // Productos con stock bajo
            if (lowStockProducts.isNotEmpty) ...[
              _buildAlertSection(
                title: 'Productos con Stock Bajo',
                icon: Icons.trending_down,
                color: AppColors.warning,
                count: lowStockProducts.length,
                items: lowStockProducts.take(3).map((product) => 
                  _AlertItem(
                    title: product.nombre,
                    subtitle: 'Stock actual: ${product.stockActual ?? 0} (mín: ${product.stockMinimo ?? 0})',
                    icon: Icons.inventory_2,
                    color: AppColors.warning,
                    onTap: () => onProductTap?.call(product),
                  )
                ).toList(),
              ),
              const SizedBox(height: AppSizes.paddingM),
            ],

            // Lotes vencidos
            if (expiredLotes.isNotEmpty) ...[
              _buildAlertSection(
                title: 'Lotes Vencidos',
                icon: Icons.dangerous,
                color: AppColors.error,
                count: expiredLotes.length,
                items: expiredLotes.take(3).map((lote) => 
                  _AlertItem(
                    title: lote.productoNombre ?? 'Producto',
                    subtitle: 'Lote: ${lote.numeroLoteDisplay} - Stock: ${lote.cantidadActual}',
                    icon: Icons.batch_prediction,
                    color: AppColors.error,
                    onTap: () => onLoteTap?.call(lote),
                  )
                ).toList(),
              ),
              const SizedBox(height: AppSizes.paddingM),
            ],

            // Lotes próximos a vencer
            if (expiringLotes.isNotEmpty) ...[
              _buildAlertSection(
                title: 'Lotes por Vencer (7 días)',
                icon: Icons.schedule,
                color: AppColors.accent,
                count: expiringLotes.length,
                items: expiringLotes.take(3).map((lote) => 
                  _AlertItem(
                    title: lote.productoNombre ?? 'Producto',
                    subtitle: 'Lote: ${lote.numeroLoteDisplay} - Vence en ${lote.diasParaVencer} días',
                    icon: Icons.batch_prediction,
                    color: AppColors.accent,
                    onTap: () => onLoteTap?.call(lote),
                  )
                ).toList(),
              ),
            ],

            // Resumen total si hay más elementos
            if (_getTotalAlerts() > 9) ...[
              const SizedBox(height: AppSizes.paddingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                ),
                child: Text(
                  'Y ${_getTotalAlerts() - 9} alertas más...',
                  style: const TextStyle(
                    fontSize: AppSizes.textM,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: AppSizes.iconM),
            const SizedBox(width: AppSizes.paddingS),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.textM,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: AppSizes.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizes.containerRadius),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: AppSizes.textS,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        ...items,
      ],
    );
  }

  int _getTotalAlerts() {
    return lowStockProducts.length + expiredLotes.length + expiringLotes.length;
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppSizes.textM,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: AppSizes.textS,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.iconS,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}