// lib/features/reports/screens/reports_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reportes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Exportar reportes'),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // Header con estadística rápida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        size: AppSizes.iconXL,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reportes y Análisis',
                            style: TextStyle(
                              fontSize: AppSizes.textXL,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppSizes.paddingXS),
                          Text(
                            'Analiza el rendimiento de tu negocio',
                            style: TextStyle(
                              fontSize: AppSizes.textM,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            
            // Grid de tipos de reportes - OPTIMIZADO
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.paddingM,
                mainAxisSpacing: AppSizes.paddingM,
                childAspectRatio: 1.0, // Más espacio vertical
                children: [
                  _ReportCard(
                    title: 'Ventas',
                    icon: Icons.trending_up,
                    color: AppColors.success,
                    description: 'Reportes diarios y mensuales',
                    onTap: () => _showComingSoon(context, 'Reportes de Ventas'),
                  ),
                  _ReportCard(
                    title: 'Inventario',
                    icon: Icons.inventory_2,
                    color: AppColors.warning,
                    description: 'Stock y rotación',
                    onTap: () => _showComingSoon(context, 'Reportes de Inventario'),
                  ),
                  _ReportCard(
                    title: 'Financiero',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.info,
                    description: 'Ganancias y análisis',
                    onTap: () => _showComingSoon(context, 'Reportes Financieros'),
                  ),
                  _ReportCard(
                    title: 'Productos',
                    icon: Icons.bar_chart,
                    color: AppColors.primary,
                    description: 'Análisis de categorías',
                    onTap: () => _showComingSoon(context, 'Reportes de Productos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: $feature'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reducido de AppSizes.paddingM
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Importante para evitar overflow
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reducido
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                ),
                child: Icon(
                  icon,
                  size: 28, // Reducido de AppSizes.iconL
                  color: color,
                ),
              ),
              const SizedBox(height: 10), // Reducido
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Tamaño fijo más pequeño
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6), // Reducido
              Flexible(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12, // Más pequeño
                    color: AppColors.textSecondary,
                    height: 1.2, // Interlineado compacto
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}