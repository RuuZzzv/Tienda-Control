// lib/features/products/models/product_extensions.dart - CORREGIDO
import 'product.dart';

extension ProductExtensions on Product {
  
  // ✅ CORREGIDO: Usar stockActual (getter) en lugar de stockActual (propiedad)
  
  /// Stock actual de forma segura (nunca null)
  int get stockActualSafe => stockActual; // Ahora es un getter, siempre retorna int
  
  /// Stock mínimo de forma segura (nunca null)
  int get stockMinimoSafe => stockMinimo ?? 0;
  
  /// Verifica si el producto tiene stock bajo
  bool get tieneStockBajo {
    final stock = stockActualSafe;
    final minimo = stockMinimoSafe;
    return stock > 0 && stock <= minimo;
  }
  
  /// Verifica si el producto está sin stock
  bool get sinStock => stockActualSafe <= 0;
  
  /// Verifica si el producto tiene stock suficiente
  bool get tieneStockSuficiente => stockActualSafe > stockMinimoSafe;
  
  /// Verifica si necesita reabastecimiento urgente (sin stock o muy bajo)
  bool get necesitaReabastecimientoUrgente {
    final stock = stockActualSafe;
    final minimo = stockMinimoSafe;
    return stock == 0 || (minimo > 0 && stock < (minimo * 0.5));
  }
  
  /// Código de barras o interno para mostrar
  String get codigoDisplay {
    if (codigoBarras != null && codigoBarras!.isNotEmpty) {
      return codigoBarras!;
    }
    if (codigoInterno != null && codigoInterno!.isNotEmpty) {
      return codigoInterno!;
    }
    return 'PROD-${id?.toString().padLeft(6, '0') ?? '000000'}';
  }
  
  /// Unidad de medida para mostrar
  String get unidadMedidaDisplay {
    if (unidadMedida == null || unidadMedida!.isEmpty) {
      return 'unidad';
    }
    
    // Mapeo de unidades a versiones cortas
    final Map<String, String> unidadMap = {
      'kilogramo': 'kg',
      'gramo': 'g',
      'litro': 'L',
      'mililitro': 'mL',
      'paquete': 'pqt',
      'caja': 'caja',
      'docena': 'dz',
      'unidad': 'und',
    };
    
    return unidadMap[unidadMedida!.toLowerCase()] ?? unidadMedida!;
  }
  
  /// Estado del stock como texto
  String get estadoStockTexto {
    if (sinStock) return 'Sin stock';
    if (tieneStockBajo) return 'Stock bajo';
    if (necesitaReabastecimientoUrgente) return 'Reabastecimiento urgente';
    return 'Stock normal';
  }
  
  /// Color del estado del stock
  String get estadoStockColor {
    if (sinStock) return 'error';
    if (tieneStockBajo) return 'warning';
    if (necesitaReabastecimientoUrgente) return 'warning';
    return 'success';
  }
  
  /// Margen de ganancia (si tiene precio de costo)
  double? get margenGanancia {
    if (precioCosto == null || precioCosto! <= 0) return null;
    return ((precioVenta - precioCosto!) / precioCosto!) * 100;
  }
  
  /// Margen de ganancia como texto
  String get margenGananciaTexto {
    final margen = margenGanancia;
    if (margen == null) return 'No calculado';
    return '${margen.toStringAsFixed(1)}%';
  }
  
  /// Valor total del inventario (stock * precio de venta)
  double get valorInventario => stockActualSafe * precioVenta;
  
  /// Valor total del inventario al costo (stock * precio de costo)
  double get valorInventarioCosto {
    if (precioCosto == null) return 0;
    return stockActualSafe * precioCosto!;
  }
  
  /// Información resumida del producto
  String get resumen {
    return '$nombre - Stock: $stockActualSafe $unidadMedidaDisplay - \$${precioVenta.toStringAsFixed(0)}';
  }
  
  /// Verifica si el producto está activo y disponible
  bool get estaDisponible => activo && stockActualSafe > 0;
  
  /// Días desde la última actualización
  int? get diasUltimaActualizacion {
    if (fechaActualizacion == null) return null;
    return DateTime.now().difference(fechaActualizacion!).inDays;
  }
  
  /// Verifica si el producto es nuevo (creado en los últimos 7 días)
  bool get esNuevo {
    if (fechaCreacion == null) return false;
    return DateTime.now().difference(fechaCreacion!).inDays <= 7;
  }
  
  /// Cantidad de lotes activos
  int get cantidadLotesActivos => lotes.where((lote) => lote.activo).length;
  
  /// Verifica si tiene lotes próximos a vencer (dentro de 7 días)
  bool get tieneLotesProximosVencer {
    final fechaLimite = DateTime.now().add(const Duration(days: 7));
    return lotes.any((lote) => 
      lote.activo && 
      lote.fechaVencimiento != null &&
      lote.fechaVencimiento!.isBefore(fechaLimite) &&
      lote.fechaVencimiento!.isAfter(DateTime.now())
    );
  }
  
  /// Verifica si tiene lotes vencidos
  bool get tieneLotesVencidos {
    final ahora = DateTime.now();
    return lotes.any((lote) => 
      lote.activo && 
      lote.fechaVencimiento != null &&
      lote.fechaVencimiento!.isBefore(ahora)
    );
  }
}