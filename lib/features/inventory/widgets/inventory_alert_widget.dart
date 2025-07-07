// lib/features/inventory/widgets/inventory_alert_widget.dart - SIMPLIFICADO PARA ADULTOS MAYORES
import 'package:flutter/material.dart';
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../products/models/product_extensions.dart';
import '../../products/models/lote_extensions.dart';
import '../../../core/constants/app_colors.dart';

class InventoryAlertWidget extends StatelessWidget {
  final List<Product> lowStockProducts;
  final List<Lote> expiredLotes;
  final List<Lote> expiringLotes;
  final VoidCallback? onViewInventory;
  final Function(Product)? onProductTap;
  final Function(Lote)? onLoteTap;

  const InventoryAlertWidget({
    super.key,
    this.lowStockProducts = const [],
    this.expiredLotes = const [],
    this.expiringLotes = const [],
    this.onViewInventory,
    this.onProductTap,
    this.onLoteTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular total de alertas
    final totalAlerts = lowStockProducts.length + 
                       expiredLotes.length + 
                       expiringLotes.length;
    
    // Si no hay alertas, no mostrar nada
    if (totalAlerts == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.warning, width: 2),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y título
              _buildHeader(totalAlerts),
              
              const SizedBox(height: 20),
              
              // Alertas de stock bajo
              if (lowStockProducts.isNotEmpty)
                _buildLowStockSection(),
              
              // Alertas de productos vencidos
              if (expiredLotes.isNotEmpty) ...[
                if (lowStockProducts.isNotEmpty) const SizedBox(height: 16),
                _buildExpiredSection(),
              ],
              
              // Alertas de productos por vencer
              if (expiringLotes.isNotEmpty) ...[
                if (lowStockProducts.isNotEmpty || expiredLotes.isNotEmpty) 
                  const SizedBox(height: 16),
                _buildExpiringSection(),
              ],
              
              const SizedBox(height: 20),
              
              // Botón para ver inventario completo
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int totalAlerts) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.warning,
            color: AppColors.warning,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¡Atención Requerida!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalAlerts ${totalAlerts == 1 ? 'producto necesita' : 'productos necesitan'} tu atención',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockSection() {
    return _AlertSection(
      title: 'Stock Bajo',
      subtitle: '${lowStockProducts.length} ${lowStockProducts.length == 1 ? 'producto' : 'productos'}',
      icon: Icons.trending_down,
      color: AppColors.warning,
      items: lowStockProducts.take(3).map((product) => 
        _AlertItem(
          title: product.nombre,
          subtitle: 'Stock: ${product.stockActualSafe} (mín: ${product.stockMinimoSafe})',
          onTap: onProductTap != null ? () => onProductTap!(product) : null,
        ),
      ).toList(),
      showMoreCount: lowStockProducts.length > 3 ? lowStockProducts.length - 3 : 0,
    );
  }

  Widget _buildExpiredSection() {
    return _AlertSection(
      title: 'Productos Vencidos',
      subtitle: '${expiredLotes.length} ${expiredLotes.length == 1 ? 'lote vencido' : 'lotes vencidos'}',
      icon: Icons.dangerous,
      color: AppColors.error,
      items: expiredLotes.take(3).map((lote) => 
        _AlertItem(
          title: lote.productoNombre ?? 'Producto',
          subtitle: 'Lote: ${lote.numeroLoteDisplay} - ${lote.cantidadActual} unidades',
          onTap: onLoteTap != null ? () => onLoteTap!(lote) : null,
        ),
      ).toList(),
      showMoreCount: expiredLotes.length > 3 ? expiredLotes.length - 3 : 0,
    );
  }

  Widget _buildExpiringSection() {
    return _AlertSection(
      title: 'Por Vencer Pronto',
      subtitle: '${expiringLotes.length} ${expiringLotes.length == 1 ? 'lote vence' : 'lotes vencen'} en 7 días',
      icon: Icons.schedule,
      color: AppColors.accent,
      items: expiringLotes.take(3).map((lote) => 
        _AlertItem(
          title: lote.productoNombre ?? 'Producto',
          subtitle: 'Lote: ${lote.numeroLoteDisplay} - ${lote.estadoVencimientoTexto}',
          onTap: onLoteTap != null ? () => onLoteTap!(lote) : null,
        ),
      ).toList(),
      showMoreCount: expiringLotes.length > 3 ? expiringLotes.length - 3 : 0,
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onViewInventory,
        icon: const Icon(Icons.inventory, size: 24),
        label: const Text(
          'Ver Mi Inventario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Widget para cada sección de alertas
class _AlertSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> items;
  final int showMoreCount;

  const _AlertSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.items,
    this.showMoreCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...items,
          ],
          
          // Mostrar contador de items adicionales
          if (showMoreCount > 0) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Y $showMoreCount más...',
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget para cada item de alerta
class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
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
                    size: 16,
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

// Widget para mostrar en el dashboard principal
class InventoryDashboardAlert extends StatelessWidget {
  final int lowStockCount;
  final int expiredCount;
  final int expiringCount;
  final VoidCallback? onTap;

  const InventoryDashboardAlert({
    super.key,
    required this.lowStockCount,
    required this.expiredCount,
    required this.expiringCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalAlerts = lowStockCount + expiredCount + expiringCount;
    
    if (totalAlerts == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.warning, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning,
                  color: AppColors.warning,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventario Necesita Atención',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildAlertText(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildAlertText() {
    final alerts = <String>[];
    
    if (lowStockCount > 0) {
      alerts.add('$lowStockCount stock bajo');
    }
    if (expiredCount > 0) {
      alerts.add('$expiredCount vencidos');
    }
    if (expiringCount > 0) {
      alerts.add('$expiringCount por vencer');
    }
    
    return alerts.join(', ');
  }
}