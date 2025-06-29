// lib/features/inventory/widgets/inventory_stats_cards.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/language_provider.dart';

class InventoryStatsCards extends StatelessWidget {
  final Map<String, dynamic> stats;
  final LanguageProvider languageProvider;
  final Function(String)? onCardTap;

  const InventoryStatsCards({
    super.key,
    required this.stats,
    required this.languageProvider,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // VERSION OPTIMIZADA: Diseño más compacto y eficiente
    return Container(
      padding: const EdgeInsets.all(8), // Reducido de paddingM
      child: Column(
        mainAxisSize: MainAxisSize.min, // Importante para evitar espacio innecesario
        children: [
          // Título de sección compacto
          const Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 18),
              SizedBox(width: 4),
              Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Cards 2x2 con altura fija
          SizedBox(
            height: 166, // Altura total fija para evitar recálculos
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _CompactStatCard(
                          title: languageProvider.translate('products'),
                          value: stats['totalProductos'].toString(),
                          icon: Icons.inventory_2,
                          color: AppColors.info,
                          isGood: true,
                          onTap: onCardTap != null ? () => onCardTap!('productos') : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _CompactStatCard(
                          title: languageProvider.translate('low_stock'),
                          value: stats['productosStockBajo'].toString(),
                          icon: Icons.warning,
                          color: AppColors.warning,
                          isGood: stats['productosStockBajo'] == 0,
                          onTap: onCardTap != null ? () => onCardTap!('stock_bajo') : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _CompactStatCard(
                          title: 'Vencidos',
                          value: stats['lotesVencidos'].toString(),
                          icon: Icons.dangerous,
                          color: AppColors.error,
                          isGood: stats['lotesVencidos'] == 0,
                          onTap: onCardTap != null ? () => onCardTap!('vencidos') : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _CompactStatCard(
                          title: 'Por Vencer',
                          value: stats['lotesProximosVencer'].toString(),
                          icon: Icons.schedule,
                          color: AppColors.accent,
                          isGood: stats['lotesProximosVencer'] == 0,
                          onTap: onCardTap != null ? () => onCardTap!('por_vencer') : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget optimizado con altura fija y diseño simple
class _CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isGood;
  final VoidCallback? onTap;

  const _CompactStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isGood,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Reducido para mejor rendimiento
      margin: EdgeInsets.zero, // Sin margen extra
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6), // Padding mínimo
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fila con icono y flecha (si tiene onTap)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 18, color: color),
                  if (onTap != null)
                    const Icon(
                      Icons.arrow_forward_ios, 
                      size: 10, 
                      color: AppColors.textTertiary
                    ),
                ],
              ),
              // Valor - número grande
              Flexible(
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isGood ? AppColors.success : color,
                    ),
                  ),
                ),
              ),
              // Título - texto pequeño
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}