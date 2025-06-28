// lib/features/inventory/widgets/product_inventory_card.dart
import 'package:flutter/material.dart';
import '../../products/models/product.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

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
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: _getStockActual() <= _getStockMinimo()
                ? Border.all(color: AppColors.warning, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono del producto con estado
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: _getStockStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                    ),
                    child: Icon(
                      _getStockStatusIcon(),
                      size: AppSizes.iconL,
                      color: _getStockStatusColor(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),

                  // Información del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.nombre,
                                style: const TextStyle(
                                  fontSize: AppSizes.textL,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_getStockActual() <= _getStockMinimo())
                              Container(
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
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        Text(
                          'Código: ${_getCodigoDisplay()}',
                          style: const TextStyle(
                            fontSize: AppSizes.textM,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (product.descripcion != null && product.descripcion!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.paddingXS),
                          Text(
                            product.descripcion!,
                            style: const TextStyle(
                              fontSize: AppSizes.textS,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Stock actual
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: _getStockStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                          border: Border.all(
                            color: _getStockStatusColor().withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${_getStockActual()}',
                          style: TextStyle(
                            fontSize: AppSizes.textXL,
                            fontWeight: FontWeight.bold,
                            color: _getStockStatusColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      Text(
                        _getUnidadMedida(),
                        style: const TextStyle(
                          fontSize: AppSizes.textS,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.paddingM),
              
              // Información adicional y acciones
              Row(
                children: [
                  // Stock mínimo
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_down,
                          size: AppSizes.iconS,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSizes.paddingXS),
                        Text(
                          'Mín: ${_getStockMinimo()}',
                          style: const TextStyle(
                            fontSize: AppSizes.textS,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Precio de venta si existe
                  ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                    ),
                    child: Text(
                      '\$${product.precioVenta.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: AppSizes.textS,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                ],
                  
                  // Botón agregar lote
                  if (onAddLote != null)
                    IconButton(
                      onPressed: onAddLote,
                      icon: const Icon(Icons.add_box),
                      color: AppColors.primary,
                      tooltip: 'Agregar Lote',
                    ),
                  
                  // Indicador de que se puede tocar
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: AppSizes.iconS,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos helper para manejar valores nulos
  int _getStockActual() => product.stockActual ?? 0;
  int _getStockMinimo() => product.stockMinimo ?? 0;
  String _getUnidadMedida() => product.unidadMedida ?? 'unidades';
  
  String _getCodigoDisplay() {
    if (product.codigoBarras != null && product.codigoBarras!.isNotEmpty) {
      return product.codigoBarras!;
    }
    return 'ID-${product.id}';
  }

  Color _getStockStatusColor() {
    final stockActual = _getStockActual();
    final stockMinimo = _getStockMinimo();
    
    if (stockActual <= 0) return AppColors.error;
    if (stockActual <= stockMinimo) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStockStatusIcon() {
    final stockActual = _getStockActual();
    final stockMinimo = _getStockMinimo();
    
    if (stockActual <= 0) return Icons.remove_circle;
    if (stockActual <= stockMinimo) return Icons.warning;
    return Icons.inventory_2;
  }
}