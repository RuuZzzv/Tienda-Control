// lib/features/products/widgets/products_empty_state.dart - REDISEÑADO
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ProductsEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onAddProduct;

  const ProductsEmptyState({
    super.key,
    required this.hasFilters,
    required this.onClearFilters,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono grande y amigable
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
              size: 100,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingXL * 2),
          
          // Título principal grande y claro
          Text(
            hasFilters 
                ? 'No se encontraron\nproductos'
                : 'No hay productos\nregistrados',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSizes.paddingL),
          
          // Mensaje descriptivo
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              hasFilters
                  ? 'Prueba cambiando los filtros\npara ver más productos'
                  : 'Agrega tu primer producto\npara empezar a gestionar\ntu inventario',
              style: TextStyle(
                fontSize: AppSizes.textL,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: AppSizes.paddingXL * 3),
          
          // Botón de acción principal
          if (hasFilters)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: Icon(Icons.clear_all, size: AppSizes.iconL),
                label: const Text(
                  'Limpiar Filtros',
                  style: TextStyle(
                    fontSize: AppSizes.textXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXL,
                    vertical: AppSizes.paddingL,
                  ),
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddProduct,
                icon: Icon(Icons.add_circle, size: AppSizes.iconXL),
                label: const Text(
                  'Agregar Primer\nProducto',
                  style: TextStyle(
                    fontSize: AppSizes.textXL,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXL,
                    vertical: AppSizes.paddingXL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }
}