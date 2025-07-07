// lib/features/dashboard/widgets/recent_sales.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_stats.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class RecentSalesWidget extends StatelessWidget {
  final List<VentaReciente> ventasRecientes;
  final LanguageProvider languageProvider;

  const RecentSalesWidget({
    super.key,
    required this.ventasRecientes,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: AppSizes.paddingM),
        
        if (ventasRecientes.isEmpty)
          _buildEmptyState()
        else
          _buildSalesList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          languageProvider.translate('recent_sales'),
          style: const TextStyle(
            fontSize: AppSizes.textXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (ventasRecientes.isNotEmpty)
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Historial de ventas'),
                ),
              );
            },
            child: Text(
              languageProvider.translate('view_all'),
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: AppSizes.iconXXL,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              languageProvider.translate('no_sales_recorded'),
              style: const TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              languageProvider.translate('sales_will_appear'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesList() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ventasRecientes.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) => _SaleItem(
          venta: ventasRecientes[index],
          languageProvider: languageProvider,
        ),
      ),
    );
  }
}

class _SaleItem extends StatelessWidget {
  final VentaReciente venta;
  final LanguageProvider languageProvider;

  const _SaleItem({
    required this.venta,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          // Icono con RepaintBoundary
          RepaintBoundary(
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.containerRadius),
              ),
              child: const Icon(
                Icons.point_of_sale,
                size: AppSizes.iconM,
                color: AppColors.success,
              ),
            ),
          ),
          
          const SizedBox(width: AppSizes.paddingM),
          
          // Información principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venta.numeroVenta,
                  style: const TextStyle(
                    fontSize: AppSizes.textL,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  _formatFecha(venta.fechaVenta),
                  style: const TextStyle(
                    fontSize: AppSizes.textS,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Información de precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(venta.total),
                style: const TextStyle(
                  fontSize: AppSizes.textL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXS),
              if (venta.reciboEnviado)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: AppSizes.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                  ),
                  child: Text(
                    languageProvider.translate('sent'),
                    style: const TextStyle(
                      fontSize: AppSizes.textXS,
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
    ).format(amount);
  }

  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inDays == 0) {
      return '${languageProvider.translate('today')} ${DateFormat('HH:mm').format(fecha)}';
    } else if (diferencia.inDays == 1) {
      return '${languageProvider.translate('yesterday')} ${DateFormat('HH:mm').format(fecha)}';
    } else if (diferencia.inDays < 7) {
      return '${diferencia.inDays} ${languageProvider.translate('days')} ${DateFormat('HH:mm').format(fecha)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    }
  }
}