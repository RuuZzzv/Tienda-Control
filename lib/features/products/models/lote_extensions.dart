// lib/features/products/models/lote_extensions.dart
import 'lote.dart';

extension LoteInventoryExtensions on Lote {
  /// Verifica si el lote tiene stock disponible
  bool get tieneStock => cantidadActual > 0;
  
  /// Verifica si el lote está vencido
  bool get estaVencido {
    if (fechaVencimiento == null) return false;
    return DateTime.now().isAfter(fechaVencimiento!);
  }
  
  /// Verifica si el lote está próximo a vencer (7 días o menos)
  bool get proximoAVencer {
    if (fechaVencimiento == null) return false;
    if (estaVencido) return false;
    
    final diasParaVencer = this.diasParaVencer;
    return diasParaVencer <= 7;
  }
  
  /// Calcula los días que faltan para que venza el lote
  int get diasParaVencer {
    if (fechaVencimiento == null) return 999999;
    if (estaVencido) return 0;
    
    final diferencia = fechaVencimiento!.difference(DateTime.now());
    return diferencia.inDays;
  }
  
  /// Fecha de ingreso (usa la fecha actual como fallback)
  DateTime get fechaIngreso {
    // Si tu modelo tiene fechaCreacion, usa esa línea en su lugar:
    // return fechaCreacion ?? DateTime.now();
    return DateTime.now();
  }
  
  /// Número de lote para mostrar
  String get numeroLoteDisplay => numeroLote ?? codigoLoteInterno ?? 'SIN-NUMERO';
  
  /// Nombre del producto (para usar con datos de join)
  String? get productoNombre {
    // Esta propiedad se llena cuando se hace join con la tabla productos
    // Retorna null si no está disponible
    try {
      return (this as dynamic).productoNombre;
    } catch (e) {
      return null;
    }
  }
  
  /// Porcentaje de stock restante
  double get porcentajeStockRestante {
    if (cantidadInicial <= 0) return 0.0;
    return (cantidadActual / cantidadInicial) * 100;
  }
  
  /// Texto descriptivo del estado de vencimiento
  String get estadoVencimientoTexto {
    if (fechaVencimiento == null) {
      return 'Sin fecha de vencimiento';
    }
    
    if (estaVencido) {
      return 'Vencido';
    }
    
    if (proximoAVencer) {
      final dias = diasParaVencer;
      if (dias == 0) return 'Vence hoy';
      if (dias == 1) return 'Vence mañana';
      return 'Vence en $dias días';
    }
    
    return 'Vigente';
  }
  
  /// Determina si el lote necesita atención urgente
  bool get necesitaAtencion => (estaVencido || proximoAVencer) && tieneStock;
  
  /// Prioridad del lote (0 = normal, 1 = atención, 2 = urgente)
  int get prioridad {
    if (estaVencido && tieneStock) return 2; // Urgente
    if (proximoAVencer && tieneStock) return 1; // Atención
    return 0; // Normal
  }
}
