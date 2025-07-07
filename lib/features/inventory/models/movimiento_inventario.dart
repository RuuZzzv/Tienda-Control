// lib/features/inventory/models/movimiento_inventario.dart
enum TipoMovimiento {
  entrada,
  salida,
  ajuste,
  vencimiento,
  devolucion,
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
  final int? usuarioId;

  // Propiedades relacionadas (de joins)
  final String? productoNombre;
  final String? numeroLote;
  final String? codigoLoteInterno;

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
    this.productoNombre,
    this.numeroLote,
    this.codigoLoteInterno,
  }) : fechaMovimiento = fechaMovimiento ?? DateTime.now();

  // Constructor factory para crear movimientos nuevos
  factory MovimientoInventario.create({
    required int productoId,
    int? loteId,
    required TipoMovimiento tipoMovimiento,
    required int cantidad,
    required String motivo,
    String? observaciones,
    int? usuarioId,
  }) {
    return MovimientoInventario(
      productoId: productoId,
      loteId: loteId,
      tipoMovimiento: tipoMovimiento,
      cantidad: cantidad,
      motivo: motivo,
      observaciones: observaciones,
      usuarioId: usuarioId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'lote_id': loteId,
      'tipo_movimiento': tipoMovimiento.name,
      'cantidad': cantidad,
      'motivo': motivo,
      'observaciones': observaciones,
      'fecha_movimiento': fechaMovimiento.toIso8601String(),
      'usuario_id': usuarioId,
    };
  }

  factory MovimientoInventario.fromMap(Map<String, dynamic> map) {
    return MovimientoInventario(
      id: map['id'],
      productoId: map['producto_id'] ?? 0,
      loteId: map['lote_id'],
      tipoMovimiento: TipoMovimiento.values.firstWhere(
        (e) => e.name == map['tipo_movimiento'],
        orElse: () => TipoMovimiento.ajuste,
      ),
      cantidad: map['cantidad'] ?? 0,
      motivo: map['motivo'] ?? '',
      observaciones: map['observaciones'],
      fechaMovimiento: map['fecha_movimiento'] != null
          ? DateTime.parse(map['fecha_movimiento'])
          : DateTime.now(),
      usuarioId: map['usuario_id'],
      productoNombre: map['producto_nombre'],
      numeroLote: map['numero_lote'],
      codigoLoteInterno: map['codigo_lote_interno'],
    );
  }

  String get tipoMovimientoTexto {
    switch (tipoMovimiento) {
      case TipoMovimiento.entrada:
        return 'Entrada';
      case TipoMovimiento.salida:
        return 'Salida';
      case TipoMovimiento.ajuste:
        return 'Ajuste';
      case TipoMovimiento.vencimiento:
        return 'Vencimiento';
      case TipoMovimiento.devolucion:
        return 'Devolución';
    }
  }

  @override
  String toString() {
    return 'MovimientoInventario{id: $id, tipo: $tipoMovimiento, cantidad: $cantidad}';
  }
}