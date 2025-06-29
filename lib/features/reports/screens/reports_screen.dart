// lib/features/reports/screens/reports_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

// Datos estáticos de los reportes para evitar recrearlos
class _ReportData {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  
  const _ReportData({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  
  // Lista estática de reportes disponibles
  static const List<_ReportData> _reports = [
    _ReportData(
      title: 'Ventas',
      icon: Icons.trending_up,
      color: AppColors.success,
      description: 'Reportes diarios y mensuales',
    ),
    _ReportData(
      title: 'Inventario',
      icon: Icons.inventory_2,
      color: AppColors.warning,
      description: 'Stock y rotación',
    ),
    _ReportData(
      title: 'Financiero',
      icon: Icons.account_balance_wallet,
      color: AppColors.info,
      description: 'Ganancias y análisis',
    ),
    _ReportData(
      title: 'Productos',
      icon: Icons.bar_chart,
      color: AppColors.primary,
      description: 'Análisis de categorías',
    ),
  ];

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
            onPressed: () => _showExportMessage(context),
            tooltip: 'Exportar reportes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header optimizado
          const _ReportsHeader(),
          
          const SizedBox(height: AppSizes.paddingL),
          
          // Grid optimizado con builder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.paddingM,
                  mainAxisSpacing: AppSizes.paddingM,
                  childAspectRatio: 1.0,
                ),
                padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final report = _reports[index];
                  return _ReportCard(
                    key: ValueKey(report.title),
                    data: report,
                    onTap: () => _showComingSoon(context, 'Reportes de ${report.title}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: $feature'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        ),
      ),
    );
  }

  static void _showExportMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Exportar reportes'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSizes.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.inputRadius)),
        ),
      ),
    );
  }
}

// Header separado y optimizado
class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingM,
        AppSizes.paddingM,
        AppSizes.paddingM,
        0,
      ),
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              // Icono container
              _HeaderIcon(),
              SizedBox(width: AppSizes.paddingM),
              // Textos
              Expanded(
                child: _HeaderContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Icono del header como widget constante
class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// Contenido del header como widget constante
class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

// Card de reporte optimizada
class _ReportCard extends StatelessWidget {
  final _ReportData data;
  final VoidCallback onTap;

  const _ReportCard({
    super.key,
    required this.data,
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono
              _CardIcon(color: data.color, icon: data.icon),
              const SizedBox(height: 10),
              // Título
              _CardTitle(title: data.title),
              const SizedBox(height: 6),
              // Descripción
              Flexible(
                child: _CardDescription(description: data.description),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Icono de la card como widget separado
class _CardIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _CardIcon({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: Icon(
        icon,
        size: 28,
        color: color,
      ),
    );
  }
}

// Título de la card
class _CardTitle extends StatelessWidget {
  final String title;

  const _CardTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// Descripción de la card
class _CardDescription extends StatelessWidget {
  final String description;

  const _CardDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}