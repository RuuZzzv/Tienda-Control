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
    switch (this) {
      case TipoMovimiento.entrada:
        return 'Entrada';
      case TipoMovimiento.salida:
        return 'Salida';
      case TipoMovimiento.ajuste:
        return 'Ajuste';
      case TipoMovimiento.venta:
        return 'Venta';
      case TipoMovimiento.devolucion:
        return 'Devolución';
      case TipoMovimiento.perdida:
        return 'Pérdida';
      case TipoMovimiento.vencimiento:
        return 'Vencimiento';
    }
  }

  String get descripcion {
    switch (this) {
      case TipoMovimiento.entrada:
        return 'Ingreso de mercadería';
      case TipoMovimiento.salida:
        return 'Salida de mercadería';
      case TipoMovimiento.ajuste:
        return 'Ajuste de inventario';
      case TipoMovimiento.venta:
        return 'Venta realizada';
      case TipoMovimiento.devolucion:
        return 'Devolución de cliente';
      case TipoMovimiento.perdida:
        return 'Pérdida de producto';
      case TipoMovimiento.vencimiento:
        return 'Producto vencido';
    }
  }

  bool get esPositivo {
    switch (this) {
      case TipoMovimiento.entrada:
      case TipoMovimiento.devolucion:
        return true;
      case TipoMovimiento.salida:
      case TipoMovimiento.venta:
      case TipoMovimiento.perdida:
      case TipoMovimiento.vencimiento:
        return false;
      case TipoMovimiento.ajuste:
        return true; // Puede ser positivo o negativo según la cantidad
    }
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
  String? productoNombre;
  String? numeroLote;
  String? codigoLoteInterno;

  MovimientoInventario({
    this.id,
    required this.productoId,
    this.loteId,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.motivo,
    this.observaciones,
    DateTime? fechaMovimiento,
    this.usuarioId,
    this.costoUnitario,
    this.valorTotal,
    this.productoNombre,
    this.numeroLote,
    this.codigoLoteInterno,
  }) : fechaMovimiento = fechaMovimiento ?? DateTime.now();

  // Getters computados
  bool get esEntrada => tipoMovimiento.esPositivo;
  bool get esSalida => !tipoMovimiento.esPositivo;
  
  String get tipoMovimientoTexto => tipoMovimiento.nombre;
  String get descripcionMovimiento => tipoMovimiento.descripcion;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'lote_id': loteId,
      'tipo_movimiento': tipoMovimiento.index,
      'cantidad': cantidad,
      'motivo': motivo,
      'observaciones': observaciones,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      'usuario_id': usuarioId,
      'costo_unitario': costoUnitario,
      'valor_total': valorTotal,
    };
  }

  factory MovimientoInventario.fromMap(Map<String, dynamic> map) {
    return MovimientoInventario(
      id: map['id'],
      productoId: map['producto_id'] ?? 0,
      loteId: map['lote_id'],
      tipoMovimiento: TipoMovimiento.values[map['tipo_movimiento'] ?? 0],
      cantidad: map['cantidad'] ?? 0,
      motivo: map['motivo'] ?? '',
      observaciones: map['observaciones'],
      fechaMovimiento: map['fecha_movimiento'] != null
          ? DateTime.parse(map['fecha_movimiento'])
          : DateTime.now(),
      usuarioId: map['usuario_id'],
      costoUnitario: map['costo_unitario']?.toDouble(),
      valorTotal: map['valor_total']?.toDouble(),
      productoNombre: map['producto_nombre'],
      numeroLote: map['numero_lote'],
      codigoLoteInterno: map['codigo_lote_interno'],
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
    return 'MovimientoInventario{id: $id, productoId: $productoId, tipo: $tipoMovimiento, cantidad: $cantidad, fecha: $fechaMovimiento}';
  }
}