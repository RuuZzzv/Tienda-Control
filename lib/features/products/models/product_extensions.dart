// lib/features/products/models/product_extensions.dart
import 'product.dart';

extension ProductInventoryExtensions on Product {
  /// Código para mostrar (usa código de barras o ID)
  String get codigoDisplay {
    if (codigoBarras != null && codigoBarras!.isNotEmpty) {
      return codigoBarras!;
    }
    return 'ID-$id';
  }
  
  /// Stock actual (valor por defecto si es null)
  int get stockActualSafe => stockActual;
  
  /// Stock mínimo (valor por defecto si es null)
  int get stockMinimoSafe => stockMinimo;
  
  /// Verifica si el producto tiene stock bajo
  bool get tieneStockBajo => stockActualSafe <= stockMinimoSafe;
  
  /// Unidad de medida para mostrar
  String get unidadMedidaDisplay => unidadMedida ?? 'unidades';
  
  /// Color del estado del stock
  String get stockStatusColor {
    if (stockActualSafe <= 0) return 'error';
    if (tieneStockBajo) return 'warning';
    return 'success';
  }
  
  /// Icono del estado del stock
  String get stockStatusIcon {
    if (stockActualSafe <= 0) return 'remove_circle';
    if (tieneStockBajo) return 'warning';
    return 'inventory_2';
  }
}