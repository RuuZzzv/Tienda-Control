// lib/features/dashboard/screens/dashboard_screen.dart - CON SELECTOR DE MONEDA
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
import '../../../core/providers/currency_provider.dart'; // ✅ NUEVO IMPORT
import '../../../core/widgets/language_selector.dart';
import '../../../core/widgets/currency_selector.dart'; // ✅ NUEVO IMPORT

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos después del primer frame para evitar rebuilds durante la construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardProvider>().loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usar Selector para evitar rebuilds innecesarios
    return Selector<LanguageProvider, String>(
      selector: (_, provider) => provider.currentLanguage,
      builder: (context, currentLanguage, child) {
        final languageProvider = context.read<LanguageProvider>();

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
          body: _DashboardBody(languageProvider: languageProvider),
        );
      },
    );
  }

  void _showNotifications(
      BuildContext context, LanguageProvider languageProvider) {
    final provider = context.read<DashboardProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) => _NotificationsSheet(
        languageProvider: languageProvider,
        dashboardProvider: provider,
      ),
    );
  }
}

// Separar el body en un widget para optimizar rebuilds
class _DashboardBody extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _DashboardBody({
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<DashboardProvider,
        ({bool isLoading, String? error, DashboardStats? stats})>(
      selector: (_, provider) => (
        isLoading: provider.isLoading,
        error: provider.error,
        stats: provider.stats,
      ),
      builder: (context, data, child) {
        if (data.isLoading) {
          return _LoadingWidget(languageProvider: languageProvider);
        }

        if (data.error != null) {
          return _ErrorWidget(
            error: data.error!,
            languageProvider: languageProvider,
          );
        }

        final stats = data.stats;
        if (stats == null) {
          return _NoDataWidget(languageProvider: languageProvider);
        }

        return RefreshIndicator(
          onRefresh: context.read<DashboardProvider>().refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SafeArea(
              bottom:
                  false, // No safe area en bottom para que el navbar se vea bien
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingCard(languageProvider: languageProvider),
                    const SizedBox(height: AppSizes.sectionSpacing),

                    // ✅ SELECTORES DE CONFIGURACIÓN
                    _ConfigurationSection(),
                    const SizedBox(height: AppSizes.sectionSpacing),

                    _StatsSection(
                        stats: stats, languageProvider: languageProvider),
                    const SizedBox(height: AppSizes.sectionSpacing),

                    QuickActionsWidget(languageProvider: languageProvider),
                    const SizedBox(height: AppSizes.sectionSpacing),

                    RecentSalesWidget(
                      ventasRecientes: stats.ventasRecientes,
                      languageProvider: languageProvider,
                    ),

                    // Espacio extra para el bottom navigation bar
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfigurationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),

        // ✅ LAYOUT RESPONSIVO BASADO EN EL ANCHO DE PANTALLA
        screenWidth > 400
            ? _buildRowLayout() // Dispositivos grandes: selectores lado a lado
            : _buildColumnLayout(), // Dispositivos pequeños: selectores apilados
      ],
    );
  }

  // ✅ LAYOUT EN FILA PARA PANTALLAS GRANDES
  Widget _buildRowLayout() {
    return IntrinsicHeight(
      // ✅ ASEGURAR MISMA ALTURA
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de idioma
          const Expanded(
            flex: 1,
            child: LanguageSelector(),
          ),
          const SizedBox(width: 8), // ✅ REDUCIDO ESPACIO ENTRE CARDS
          // Selector de moneda
          const Expanded(
            flex: 1,
            child: CurrencySelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnLayout() {
    return Column(
      children: [
        // Selector de idioma
        const SizedBox(
          width: double.infinity,
          child: LanguageSelector(),
        ),
        const SizedBox(height: 8),
        // Selector de moneda
        const SizedBox(
          width: double.infinity,
          child: CurrencySelector(),
        ),
      ],
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _LoadingWidget({
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
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
}

// Widget de error optimizado
class _ErrorWidget extends StatelessWidget {
  final String error;
  final LanguageProvider languageProvider;

  const _ErrorWidget({
    required this.error,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
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
              error,
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingL),
            ElevatedButton.icon(
              onPressed: () => context.read<DashboardProvider>().refresh(),
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
}

// Widget sin datos optimizado
class _NoDataWidget extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _NoDataWidget({
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => context.read<DashboardProvider>().forceReload(),
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
}

// Greeting card como widget separado
class _GreetingCard extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _GreetingCard({
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            Icon(
              _getGreetingIcon(hour),
              size: AppSizes.iconL,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageProvider.translate(greetingKey),
                    style: const TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: AppSizes.textM,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
}

class _StatsSection extends StatelessWidget {
  final DashboardStats stats;
  final LanguageProvider languageProvider;

  const _StatsSection({
    required this.stats,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('today_summary'),
          style: const TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),

        // ✅ USAR CONSUMER PARA CURRENCY PROVIDER
        Consumer<CurrencyProvider>(
          builder: (context, currencyProvider, child) {
            return Column(
              children: [
                // Primera fila de stats
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: languageProvider.translate('sales_today'),
                          // ✅ FORMATEAR PRECIO CON LA MONEDA SELECCIONADA
                          value: currencyProvider.formatPrice(stats.ventasHoy),
                          icon: Icons.point_of_sale,
                          color: AppColors.success,
                          subtitle:
                              '${stats.cantidadVentasHoy} ${languageProvider.translate('sales')}',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Módulo de ventas próximamente'),
                                  ],
                                ),
                                backgroundColor: AppColors.info,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: StatsCard(
                          title: languageProvider.translate('products'),
                          value: stats.totalProductos.toString(),
                          icon: Icons.inventory_2,
                          color: AppColors.info,
                          subtitle:
                              languageProvider.translate('active_products'),
                          onTap: () => context.go('/products'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),

                // Segunda fila de stats
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: languageProvider.translate('low_stock'),
                          value: stats.productosStockBajo.toString(),
                          icon: Icons.warning,
                          color: AppColors.warning,
                          subtitle:
                              languageProvider.translate('require_attention'),
                          onTap: () => context.go('/inventory'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Expanded(
                        child: StatsCard(
                          title: languageProvider.translate('reports'),
                          value: 'Ver',
                          icon: Icons.analytics,
                          color: AppColors.accent,
                          subtitle:
                              languageProvider.translate('detailed_analysis'),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Módulo de reportes próximamente'),
                                  ],
                                ),
                                backgroundColor: AppColors.info,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// Sheet de notificaciones como widget separado
class _NotificationsSheet extends StatelessWidget {
  final LanguageProvider languageProvider;
  final DashboardProvider dashboardProvider;

  const _NotificationsSheet({
    required this.languageProvider,
    required this.dashboardProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
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
          if (dashboardProvider.tieneAlertas) ...[
            ListTile(
              leading: const Icon(Icons.warning, color: AppColors.warning),
              title: Text(languageProvider.translate('low_stock')),
              subtitle: Text(dashboardProvider.mensajeAlerta),
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
    );
  }
}
