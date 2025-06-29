// lib/features/inventory/models/movimiento_inventario.dart
enum TipoMovimiento {
  entrada,
  salida,
  ajuste,
  venta,
  devolucion,
  perdida,
  vencimiento
}

extension TipoMovimientoExtension on TipoMovimiento {
  String get nombre {
    // Usar const para strings estáticos
    const nombres = {
      TipoMovimiento.entrada: 'Entrada',
      TipoMovimiento.salida: 'Salida',
      TipoMovimiento.ajuste: 'Ajuste',
      TipoMovimiento.venta: 'Venta',
      TipoMovimiento.devolucion: 'Devolución',
      TipoMovimiento.perdida: 'Pérdida',
      TipoMovimiento.vencimiento: 'Vencimiento',
    };
    return nombres[this]!;
  }

  String get descripcion {
    // Usar const para strings estáticos
    const descripciones = {
      TipoMovimiento.entrada: 'Ingreso de mercadería',
      TipoMovimiento.salida: 'Salida de mercadería',
      TipoMovimiento.ajuste: 'Ajuste de inventario',
      TipoMovimiento.venta: 'Venta realizada',
      TipoMovimiento.devolucion: 'Devolución de cliente',
      TipoMovimiento.perdida: 'Pérdida de producto',
      TipoMovimiento.vencimiento: 'Producto vencido',
    };
    return descripciones[this]!;
  }

  bool get esPositivo {
    // Usar const set para búsquedas más rápidas
    const positivos = {
      TipoMovimiento.entrada,
      TipoMovimiento.devolucion,
      TipoMovimiento.ajuste, // Puede ser positivo o negativo
    };
    return positivos.contains(this);
  }
}

class MovimientoInventario {
  final int? id;
  final int productoId;
  final int? loteId;
  final TipoMovimiento tipoMovimiento;
  final int cantidad;
  final String motivo;
  final String? observaciones;
  final DateTime fechaMovimiento;
  final String? usuarioId;
  final double? costoUnitario;
  final double? valorTotal;

  // Propiedades relacionadas (se llenan con joins)
  final String? productoNombre;
  final String? numeroLote;
  final String? codigoLoteInterno;

  // Constructor const para mejor performance
  const MovimientoInventario({
    this.id,
    required this.productoId,
    this.loteId,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.motivo,
    this.observaciones,
    required this.fechaMovimiento,
    this.usuarioId,
    this.costoUnitario,
    this.valorTotal,
    this.productoNombre,
    this.numeroLote,
    this.codigoLoteInterno,
  });

  // Factory constructor para manejar fecha por defecto
  factory MovimientoInventario.create({
    int? id,
    required int productoId,
    int? loteId,
    required TipoMovimiento tipoMovimiento,
    required int cantidad,
    required String motivo,
    String? observaciones,
    DateTime? fechaMovimiento,
    String? usuarioId,
    double? costoUnitario,
    double? valorTotal,
    String? productoNombre,
    String? numeroLote,
    String? codigoLoteInterno,
  }) {
    return MovimientoInventario(
      id: id,
      productoId: productoId,
      loteId: loteId,
      tipoMovimiento: tipoMovimiento,
      cantidad: cantidad,
      motivo: motivo,
      observaciones: observaciones,
      fechaMovimiento: fechaMovimiento ?? DateTime.now(),
      usuarioId: usuarioId,
      costoUnitario: costoUnitario,
      valorTotal: valorTotal,
      productoNombre: productoNombre,
      numeroLote: numeroLote,
      codigoLoteInterno: codigoLoteInterno,
    );
  }

  // Getters computados
  bool get esEntrada => tipoMovimiento.esPositivo;
  bool get esSalida => !tipoMovimiento.esPositivo;
  
  String get tipoMovimientoTexto => tipoMovimiento.nombre;
  String get descripcionMovimiento => tipoMovimiento.descripcion;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'producto_id': productoId,
      if (loteId != null) 'lote_id': loteId,
      'tipo_movimiento': tipoMovimiento.index,
      'cantidad': cantidad,
      'motivo': motivo,
      if (observaciones != null) 'observaciones': observaciones,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (valorTotal != null) 'valor_total': valorTotal,
    };
  }

  factory MovimientoInventario.fromMap(Map<String, dynamic> map) {
    return MovimientoInventario(
      id: map['id'] as int?,
      productoId: (map['producto_id'] as int?) ?? 0,
      loteId: map['lote_id'] as int?,
      tipoMovimiento: TipoMovimiento.values[(map['tipo_movimiento'] as int?) ?? 0],
      cantidad: (map['cantidad'] as int?) ?? 0,
      motivo: (map['motivo'] as String?) ?? '',
      observaciones: map['observaciones'] as String?,
      fechaMovimiento: map['fecha_movimiento'] != null
          ? DateTime.parse(map['fecha_movimiento'] as String)
          : DateTime.now(),
      usuarioId: map['usuario_id'] as String?,
      costoUnitario: (map['costo_unitario'] as num?)?.toDouble(),
      valorTotal: (map['valor_total'] as num?)?.toDouble(),
      productoNombre: map['producto_nombre'] as String?,
      numeroLote: map['numero_lote'] as String?,
      codigoLoteInterno: map['codigo_lote_interno'] as String?,
    );
  }

  MovimientoInventario copyWith({
    int? id,
    int? productoId,
    int? loteId,
    TipoMovimiento? tipoMovimiento,
    int? cantidad,
    String? motivo,
    String? observaciones,
    DateTime? fechaMovimiento,
    String? usuarioId,
    double? costoUnitario,
    double? valorTotal,
    String? productoNombre,
    String? numeroLote,
    String? codigoLoteInterno,
  }) {
    return MovimientoInventario(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      loteId: loteId ?? this.loteId,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      cantidad: cantidad ?? this.cantidad,
      motivo: motivo ?? this.motivo,
      observaciones: observaciones ?? this.observaciones,
      fechaMovimiento: fechaMovimiento ?? this.fechaMovimiento,
      usuarioId: usuarioId ?? this.usuarioId,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      valorTotal: valorTotal ?? this.valorTotal,
      productoNombre: productoNombre ?? this.productoNombre,
      numeroLote: numeroLote ?? this.numeroLote,
      codigoLoteInterno: codigoLoteInterno ?? this.codigoLoteInterno,
    );
  }

  @override
  String toString() {
    return 'MovimientoInventario{id: $id, productoId: $productoId, tipo: ${tipoMovimiento.nombre}, cantidad: $cantidad, fecha: $fechaMovimiento}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MovimientoInventario &&
        other.id == id &&
        other.productoId == productoId &&
        other.loteId == loteId &&
        other.tipoMovimiento == tipoMovimiento &&
        other.cantidad == cantidad &&
        other.motivo == motivo &&
        other.fechaMovimiento == fechaMovimiento;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      productoId,
      loteId,
      tipoMovimiento,
      cantidad,
      motivo,
      fechaMovimiento,
    );
  }
}