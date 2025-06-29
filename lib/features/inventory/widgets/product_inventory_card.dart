// lib/features/inventory/widgets/product_inventory_card.dart
import 'package:flutter/material.dart';
import '../../products/models/product.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

// Widget optimizado con pre-cálculo de valores
class ProductInventoryCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddLote;

  const ProductInventoryCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddLote,
  });

  @override
  Widget build(BuildContext context) {
    // Pre-calcular todos los valores necesarios una sola vez
    final stockActual = product.stockActual ?? 0;
    final stockMinimo = product.stockMinimo ?? 0;
    final isLowStock = stockActual <= stockMinimo;
    final stockStatusColor = _calculateStockStatusColor(stockActual, stockMinimo);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: isLowStock
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.warning, width: 2),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Optimización de espacio
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila principal con información del producto
              _buildMainRow(
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                stockStatusColor: stockStatusColor,
                isLowStock: isLowStock,
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              // Fila de información adicional y acciones
              _buildActionsRow(stockMinimo: stockMinimo),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para la fila principal
  Widget _buildMainRow({
    required int stockActual,
    required int stockMinimo,
    required Color stockStatusColor,
    required bool isLowStock,
  }) {
    return Row(
      children: [
        // Icono del producto
        _ProductIcon(
          color: stockStatusColor,
          icon: _calculateStockStatusIcon(stockActual, stockMinimo),
        ),
        const SizedBox(width: AppSizes.paddingM),

        // Información del producto
        Expanded(
          child: _ProductInfo(
            name: product.nombre,
            code: _getCodigoDisplay(),
            description: product.descripcion,
            isLowStock: isLowStock,
          ),
        ),

        // Display de stock
        _StockDisplay(
          stockActual: stockActual,
          unidadMedida: product.unidadMedida ?? 'unidades',
          color: stockStatusColor,
        ),
      ],
    );
  }

  // Widget para la fila de acciones
  Widget _buildActionsRow({required int stockMinimo}) {
    return Row(
      children: [
        // Stock mínimo
        Expanded(
          child: _MinStockInfo(stockMinimo: stockMinimo),
        ),
        
        // Precio de venta
        _PriceTag(price: product.precioVenta),
        const SizedBox(width: AppSizes.paddingS),
        
        // Botón agregar lote
        if (onAddLote != null)
          IconButton(
            onPressed: onAddLote,
            icon: const Icon(Icons.add_box),
            color: AppColors.primary,
            tooltip: 'Agregar Lote',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        
        // Indicador de navegación
        const Icon(
          Icons.arrow_forward_ios,
          size: AppSizes.iconS,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  // Método helper optimizado para código
  String _getCodigoDisplay() {
    return product.codigoBarras?.isNotEmpty == true 
        ? product.codigoBarras! 
        : 'ID-${product.id}';
  }

  // Cálculo estático del color del stock
  static Color _calculateStockStatusColor(int stockActual, int stockMinimo) {
    if (stockActual <= 0) return AppColors.error;
    if (stockActual <= stockMinimo) return AppColors.warning;
    return AppColors.success;
  }

  // Cálculo estático del icono del stock
  static IconData _calculateStockStatusIcon(int stockActual, int stockMinimo) {
    if (stockActual <= 0) return Icons.remove_circle;
    if (stockActual <= stockMinimo) return Icons.warning;
    return Icons.inventory_2;
  }
}

// Widget separado para el icono del producto
class _ProductIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _ProductIcon({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: Icon(
        icon,
        size: AppSizes.iconL,
        color: color,
      ),
    );
  }
}

// Widget separado para la información del producto
class _ProductInfo extends StatelessWidget {
  final String name;
  final String code;
  final String? description;
  final bool isLowStock;

  const _ProductInfo({
    required this.name,
    required this.code,
    required this.description,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: AppSizes.textL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isLowStock) const _LowStockBadge(),
          ],
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          'Código: $code',
          style: const TextStyle(
            fontSize: AppSizes.textM,
            color: AppColors.textSecondary,
          ),
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            description!,
            style: const TextStyle(
              fontSize: AppSizes.textS,
              color: AppColors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// Widget constante para el badge de stock bajo
class _LowStockBadge extends StatelessWidget {
  const _LowStockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: const Text(
        'STOCK BAJO',
        style: TextStyle(
          fontSize: AppSizes.textXS,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget separado para mostrar el stock
class _StockDisplay extends StatelessWidget {
  final int stockActual;
  final String unidadMedida;
  final Color color;

  const _StockDisplay({
    required this.stockActual,
    required this.unidadMedida,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.containerRadius),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Text(
            '$stockActual',
            style: TextStyle(
              fontSize: AppSizes.textXL,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          unidadMedida,
          style: const TextStyle(
            fontSize: AppSizes.textS,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// Widget separado para información de stock mínimo
class _MinStockInfo extends StatelessWidget {
  final int stockMinimo;

  const _MinStockInfo({required this.stockMinimo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.trending_down,
          size: AppSizes.iconS,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: AppSizes.paddingXS),
        Text(
          'Mín: $stockMinimo',
          style: const TextStyle(
            fontSize: AppSizes.textS,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// Widget separado para el precio
class _PriceTag extends StatelessWidget {
  final double price;

  const _PriceTag({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: AppSizes.textS,
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}