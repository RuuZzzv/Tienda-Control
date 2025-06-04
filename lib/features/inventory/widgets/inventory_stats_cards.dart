// lib/features/inventory/widgets/inventory_stats_cards.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class InventoryStatsCards extends StatelessWidget {
  final Map<String, dynamic> stats;
  final LanguageProvider languageProvider;

  const InventoryStatsCards({
    super.key,
    required this.stats,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: languageProvider.translate('products'),
                  value: stats['totalProductos'].toString(),
                  icon: Icons.inventory_2,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _StatCard(
                  title: languageProvider.translate('low_stock'),
                  value: stats['productosStockBajo'].toString(),
                  icon: Icons.warning,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Lotes Vencidos',
                  value: stats['lotesVencidos'].toString(),
                  icon: Icons.dangerous,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: _StatCard(
                  title: 'Por Vencer',
                  value: stats['lotesProximosVencer'].toString(),
                  icon: Icons.schedule,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: AppSizes.iconL,
                  color: color,
                ),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingXS),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: AppSizes.iconS,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.textXXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}