// lib/features/inventory/widgets/stock_alert.dart
import 'package:flutter/material.dart';
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

// Widget optimizado con cálculos memoizados
class StockAlert extends StatelessWidget {
  final List<Product> lowStockProducts;
  final List<Lote> expiredLotes;
  final List<Lote> expiringLotes;
  final VoidCallback? onViewAll;
  final Function(Product)? onProductTap;
  final Function(Lote)? onLoteTap;

  // Constantes para optimización
  static const int _maxItemsPerSection = 3;
  static const int _maxVisibleItems = 9;

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
    // Pre-calcular totales
    final totalAlerts = lowStockProducts.length + 
                       expiredLotes.length + 
                       expiringLotes.length;
    
    // Si no hay alertas, retornar widget vacío inmediatamente
    if (totalAlerts == 0) {
      return const SizedBox.shrink();
    }

    // Pre-calcular si mostrar el resumen
    final showSummary = totalAlerts > _maxVisibleItems;
    final remainingAlerts = totalAlerts - _maxVisibleItems;

    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      color: AppColors.warning.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Optimización de espacio
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header optimizado
            _AlertHeader(onViewAll: onViewAll),
            const SizedBox(height: AppSizes.paddingM),

            // Secciones de alertas construidas eficientemente
            ..._buildAlertSections(),

            // Resumen condicional
            if (showSummary)
              _AlertSummary(remainingCount: remainingAlerts),
          ],
        ),
      ),
    );
  }

  // Construir secciones de forma eficiente
  List<Widget> _buildAlertSections() {
    final sections = <Widget>[];

    // Productos con stock bajo
    if (lowStockProducts.isNotEmpty) {
      sections.add(
        _AlertSection(
          title: 'Productos con Stock Bajo',
          icon: Icons.trending_down,
          color: AppColors.warning,
          count: lowStockProducts.length,
          items: _buildProductItems(lowStockProducts.take(_maxItemsPerSection)),
        ),
      );
      sections.add(const SizedBox(height: AppSizes.paddingM));
    }

    // Lotes vencidos
    if (expiredLotes.isNotEmpty) {
      sections.add(
        _AlertSection(
          title: 'Lotes Vencidos',
          icon: Icons.dangerous,
          color: AppColors.error,
          count: expiredLotes.length,
          items: _buildExpiredLoteItems(expiredLotes.take(_maxItemsPerSection)),
        ),
      );
      sections.add(const SizedBox(height: AppSizes.paddingM));
    }

    // Lotes próximos a vencer
    if (expiringLotes.isNotEmpty) {
      sections.add(
        _AlertSection(
          title: 'Lotes por Vencer (7 días)',
          icon: Icons.schedule,
          color: AppColors.accent,
          count: expiringLotes.length,
          items: _buildExpiringLoteItems(expiringLotes.take(_maxItemsPerSection)),
        ),
      );
    }

    // Remover el último espaciador si existe
    if (sections.isNotEmpty && sections.last is SizedBox) {
      sections.removeLast();
    }

    return sections;
  }

  // Builders especializados para cada tipo de item
  List<Widget> _buildProductItems(Iterable<Product> products) {
    return products.map((product) => _AlertItem(
      key: ValueKey('product-${product.id}'),
      title: product.nombre,
      subtitle: 'Stock: ${product.stockActual ?? 0} (mín: ${product.stockMinimo ?? 0})',
      icon: Icons.inventory_2,
      color: AppColors.warning,
      onTap: onProductTap != null ? () => onProductTap!(product) : null,
    )).toList();
  }

  List<Widget> _buildExpiredLoteItems(Iterable<Lote> lotes) {
    return lotes.map((lote) => _AlertItem(
      key: ValueKey('expired-${lote.id}'),
      title: lote.productoNombre ?? 'Producto',
      subtitle: 'Lote: ${lote.numeroLoteDisplay} - Stock: ${lote.cantidadActual}',
      icon: Icons.batch_prediction,
      color: AppColors.error,
      onTap: onLoteTap != null ? () => onLoteTap!(lote) : null,
    )).toList();
  }

  List<Widget> _buildExpiringLoteItems(Iterable<Lote> lotes) {
    return lotes.map((lote) => _AlertItem(
      key: ValueKey('expiring-${lote.id}'),
      title: lote.productoNombre ?? 'Producto',
      subtitle: 'Lote: ${lote.numeroLoteDisplay} - Vence en ${lote.diasParaVencer} días',
      icon: Icons.batch_prediction,
      color: AppColors.accent,
      onTap: onLoteTap != null ? () => onLoteTap!(lote) : null,
    )).toList();
  }
}

// Header optimizado como widget separado
class _AlertHeader extends StatelessWidget {
  final VoidCallback? onViewAll;

  const _AlertHeader({this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
            ),
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
    );
  }
}

// Sección de alerta optimizada
class _AlertSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final List<Widget> items;

  const _AlertSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección
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
            _CountBadge(count: count, color: color),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        // Items de la sección
        ...items,
      ],
    );
  }
}

// Badge de conteo reutilizable
class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// Item de alerta optimizado con key para mejor rendimiento en listas
class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _AlertItem({
    super.key,
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
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: AppSizes.iconM),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: _ItemContent(title: title, subtitle: subtitle),
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
      ),
    );
  }
}

// Contenido del item separado para optimización
class _ItemContent extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ItemContent({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

// Widget para el resumen de alertas
class _AlertSummary extends StatelessWidget {
  final int remainingCount;

  const _AlertSummary({required this.remainingCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingM),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        ),
        child: Text(
          'Y $remainingCount alertas más...',
          style: const TextStyle(
            fontSize: AppSizes.textM,
            color: AppColors.info,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}