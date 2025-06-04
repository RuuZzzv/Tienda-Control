// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_stats.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_sales.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/language_selector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(languageProvider.translate('dashboard')),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, size: AppSizes.iconL),
                onPressed: () {
                  context.read<DashboardProvider>().refresh();
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications, size: AppSizes.iconL),
                onPressed: () => _showNotifications(context, languageProvider),
              ),
            ],
          ),
          body: Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 6,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        languageProvider.translate('loading_data'),
                        style: const TextStyle(
                          fontSize: AppSizes.textL,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: AppSizes.iconXXL,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          languageProvider.translate('error_loading_data'),
                          style: const TextStyle(
                            fontSize: AppSizes.textXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          provider.error!,
                          style: const TextStyle(
                            fontSize: AppSizes.textM,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.paddingL),
                        ElevatedButton.icon(
                          onPressed: () => provider.refresh(),
                          icon: const Icon(Icons.refresh),
                          label: Text(languageProvider.translate('retry')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final stats = provider.stats;
              if (stats == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        size: AppSizes.iconXXL,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        languageProvider.translate('no_data_available'),
                        style: const TextStyle(
                          fontSize: AppSizes.textXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        languageProvider.translate('try_refresh'),
                        style: const TextStyle(
                          fontSize: AppSizes.textM,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingL),
                      ElevatedButton.icon(
                        onPressed: () => provider.forceReload(),
                        icon: const Icon(Icons.refresh),
                        label: Text(languageProvider.translate('reload')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: provider.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(languageProvider),
                      const SizedBox(height: AppSizes.sectionSpacing),

                      const LanguageSelector(),
                      const SizedBox(height: AppSizes.sectionSpacing),

                      _buildStatsSection(stats, languageProvider),
                      const SizedBox(height: AppSizes.sectionSpacing),

                      QuickActionsWidget(languageProvider: languageProvider),
                      const SizedBox(height: AppSizes.sectionSpacing),

                      RecentSalesWidget(
                        ventasRecientes: stats.ventasRecientes,
                        languageProvider: languageProvider,
                      ),
                      
                      const SizedBox(height: AppSizes.paddingXL),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGreeting(LanguageProvider languageProvider) {
    final hour = DateTime.now().hour;
    String greetingKey;

    if (hour < 12) {
      greetingKey = 'good_morning';
    } else if (hour < 18) {
      greetingKey = 'good_afternoon';
    } else {
      greetingKey = 'good_evening';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Row(
          children: [
            Icon(
              _getGreetingIcon(hour),
              size: AppSizes.iconXL,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate(greetingKey),
                    style: const TextStyle(
                      fontSize: AppSizes.textXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
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
    );
  }

  IconData _getGreetingIcon(int hour) {
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 18) return Icons.wb_sunny_outlined;
    return Icons.nights_stay;
  }

  Widget _buildStatsSection(DashboardStats stats, LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('today_summary'),
          style: const TextStyle(
            fontSize: AppSizes.textXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: languageProvider.translate('sales_today'),
                value: NumberFormat.currency(
                  locale: 'es_CO',
                  symbol: '\$',
                ).format(stats.ventasHoy),
                icon: Icons.point_of_sale,
                color: AppColors.success,
                subtitle: '${stats.cantidadVentasHoy} ${languageProvider.translate('sales')}',
                onTap: () => context.go('/pos'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: StatsCard(
                title: languageProvider.translate('products'),
                value: stats.totalProductos.toString(),
                icon: Icons.inventory_2,
                color: AppColors.info,
                subtitle: languageProvider.translate('active_products'),
                onTap: () => context.go('/products'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: languageProvider.translate('low_stock'),
                value: stats.productosStockBajo.toString(),
                icon: Icons.warning,
                color: AppColors.warning,
                subtitle: languageProvider.translate('require_attention'),
                onTap: () => context.go('/inventory'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: StatsCard(
                title: languageProvider.translate('reports'),
                value: 'Ver',
                icon: Icons.analytics,
                color: AppColors.accent,
                subtitle: languageProvider.translate('detailed_analysis'),
                onTap: () => context.go('/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context, LanguageProvider languageProvider) {
    final provider = context.read<DashboardProvider>();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  languageProvider.translate('notifications'),
                  style: const TextStyle(
                    fontSize: AppSizes.textXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            
            if (provider.tieneAlertas) ...[
              ListTile(
                leading: const Icon(Icons.warning, color: AppColors.warning),
                title: Text(languageProvider.translate('low_stock')),
                subtitle: Text(provider.mensajeAlerta),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/inventory');
                },
              ),
            ],
            
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppColors.success),
              title: Text(languageProvider.translate('system_working')),
              subtitle: Text(languageProvider.translate('store_ready')),
            ),
            
            const SizedBox(height: AppSizes.paddingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(languageProvider.translate('close')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}