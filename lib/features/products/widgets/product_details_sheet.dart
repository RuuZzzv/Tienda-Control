// lib/features/products/widgets/product_details_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
import '../providers/products_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class ProductDetailsSheet extends StatelessWidget {
  final Product product;
  final LanguageProvider languageProvider;

  const ProductDetailsSheet({
    super.key,
    required this.product,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.cardRadius * 2),
            topRight: Radius.circular(AppSizes.cardRadius * 2),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppSizes.paddingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(),
                    const SizedBox(height: AppSizes.paddingL),
                    _buildStockSection(),
                    const SizedBox(height: AppSizes.paddingL),
                    _buildLotesSection(context),
                    const SizedBox(height: AppSizes.paddingL),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final stockStatus = _getStockStatus();
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: stockStatus.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadius * 2),
          topRight: Radius.circular(AppSizes.cardRadius * 2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.containerRadius),
            ),
            child: Icon(
              Icons.inventory_2,
              size: AppSizes.iconXL,
              color: stockStatus.iconColor,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nombre,
                  style: const TextStyle(
                    fontSize: AppSizes.textXL,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: AppSizes.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                  ),
                  child: Text(
                    stockStatus.statusText,
                    style: const TextStyle(
                      fontSize: AppSizes.textS,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(languageProvider.translate('product_information')),
            const SizedBox(height: AppSizes.paddingM),
            _buildInfoRow(
              Icons.qr_code,
              languageProvider.translate('code'),
              product.codigoDisplay,
            ),
            if (product.codigoBarras != null)
              _buildInfoRow(
                Icons.barcode_reader,
                languageProvider.translate('barcode'),
                product.codigoBarras!,
              ),
            if (product.categoriaNombre != null)
              _buildInfoRow(
                Icons.category,
                languageProvider.translate('category'),
                product.categoriaNombre!,
              ),
            _buildInfoRow(
              Icons.attach_money,
              languageProvider.translate('sale_price'),
              currencyFormat.format(product.precioVenta),
              valueColor: AppColors.success,
            ),
            if (product.precioCompra > 0)
              _buildInfoRow(
                Icons.shopping_cart,
                languageProvider.translate('purchase_price'),
                currencyFormat.format(product.precioCompra),
              ),
            if (product.descripcion != null && product.descripcion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('description'),
                      style: const TextStyle(
                        fontSize: AppSizes.textM,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      product.descripcion!,
                      style: const TextStyle(
                        fontSize: AppSizes.textM,
                        color: AppColors.textPrimary,
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

  Widget _buildStockSection() {
    final stockStatus = _getStockStatus();
    
    return Card(
      color: stockStatus.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stockStatus.stockIcon,
                  color: stockStatus.iconColor,
                  size: AppSizes.iconL,
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Text(
                    languageProvider.translate('stock_information'),
                    style: const TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStockItem(
                  languageProvider.translate('current_stock'),
                  '${product.stockActualSafe}',
                  product.unidadMedidaDisplay,
                  stockStatus.stockColor,
                ),
                _buildStockItem(
                  languageProvider.translate('minimum_stock'),
                  '${product.stockMinimoSafe}',
                  product.unidadMedidaDisplay,
                  AppColors.textSecondary,
                ),
              ],
            ),
            if (product.tieneStockBajo) ...[
              const SizedBox(height: AppSizes.paddingM),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: AppColors.warning,
                      size: AppSizes.iconM,
                    ),
                    const SizedBox(width: AppSizes.paddingS),
                    Expanded(
                      child: Text(
                        languageProvider.translate('low_stock_warning'),
                        style: const TextStyle(
                          fontSize: AppSizes.textM,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLotesSection(BuildContext context) {
    return FutureBuilder(
      future: context.read<ProductsProvider>().getLotesForProduct(product.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingL),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final lotes = snapshot.data ?? [];
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(languageProvider.translate('batches')),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/add-lote', extra: product);
                      },
                      icon: const Icon(Icons.add, size: AppSizes.iconS),
                      label: Text(languageProvider.translate('add')),
                    ),
                  ],
                ),
                if (lotes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: AppSizes.iconXL,
                            color: AppColors.textTertiary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            languageProvider.translate('no_batches'),
                            style: const TextStyle(
                              fontSize: AppSizes.textM,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...lotes.map((lote) => _buildLoteItem(lote)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoteItem(dynamic lote) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lote.numeroLote ?? lote.codigoLoteInterno,
                style: const TextStyle(
                  fontSize: AppSizes.textM,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: lote.cantidadActual > 0 
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                ),
                child: Text(
                  '${lote.cantidadActual} ${product.unidadMedidaDisplay}',
                  style: TextStyle(
                    fontSize: AppSizes.textS,
                    color: lote.cantidadActual > 0 
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (lote.fechaVencimiento != null) ...[
            const SizedBox(height: AppSizes.paddingS),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: AppSizes.iconS,
                  color: lote.estaVencido 
                      ? AppColors.error
                      : lote.proximoAVencer 
                          ? AppColors.warning
                          : AppColors.textTertiary,
                ),
                const SizedBox(width: AppSizes.paddingXS),
                Text(
                  '${languageProvider.translate('expires')}: ${dateFormat.format(lote.fechaVencimiento)}',
                  style: TextStyle(
                    fontSize: AppSizes.textS,
                    color: lote.estaVencido 
                        ? AppColors.error
                        : lote.proximoAVencer 
                            ? AppColors.warning
                            : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/edit-product', extra: product);
            },
            icon: const Icon(Icons.edit),
            label: Text(languageProvider.translate('edit')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/add-lote', extra: product);
            },
            icon: const Icon(Icons.add_box),
            label: Text(languageProvider.translate('add_stock')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppSizes.textL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconM, color: AppColors.textTertiary),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppSizes.textM,
                    color: AppColors.textSecondary,
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      color: valueColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.textS,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.textXL,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: AppSizes.textS,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  _StockStatus _getStockStatus() {
    if (product.stockActualSafe == 0) {
      return _StockStatus(
        backgroundColor: AppColors.error,
        iconColor: AppColors.error,
        statusText: languageProvider.translate('out_of_stock'),
        stockIcon: Icons.remove_circle,
        stockColor: AppColors.error,
        cardColor: AppColors.error.withOpacity(0.05),
      );
    } else if (product.tieneStockBajo) {
      return _StockStatus(
        backgroundColor: AppColors.warning,
        iconColor: AppColors.warning,
        statusText: languageProvider.translate('low_stock'),
        stockIcon: Icons.warning,
        stockColor: AppColors.warning,
        cardColor: AppColors.warning.withOpacity(0.05),
      );
    } else {
      return _StockStatus(
        backgroundColor: AppColors.success,
        iconColor: AppColors.success,
        statusText: languageProvider.translate('stock_ok'),
        stockIcon: Icons.check_circle,
        stockColor: AppColors.success,
        cardColor: AppColors.success.withOpacity(0.05),
      );
    }
  }
}

class _StockStatus {
  final Color backgroundColor;
  final Color iconColor;
  final String statusText;
  final IconData stockIcon;
  final Color stockColor;
  final Color cardColor;

  _StockStatus({
    required this.backgroundColor,
    required this.iconColor,
    required this.statusText,
    required this.stockIcon,
    required this.stockColor,
    required this.cardColor,
  });
}