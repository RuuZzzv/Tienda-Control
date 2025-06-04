// lib/features/products/models/lote.dart
class Lote {
  final int? id;
  final int productoId;
  final String? numeroLote;
  final String codigoLoteInterno;
  final DateTime? fechaVencimiento;
  final DateTime fechaIngreso;
  final int cantidadInicial;
  final int cantidadActual;
  final double? precioCompraLote;
  final bool activo;
  final String? notas;

  // Propiedades relacionadas
  String? productoNombre;
  double? precioVenta;

  Lote({
    this.id,
    required this.productoId,
    this.numeroLote,
    this.codigoLoteInterno = '',
    this.fechaVencimiento,
    DateTime? fechaIngreso,
    required this.cantidadInicial,
    required this.cantidadActual,
    this.precioCompraLote,
    this.activo = true,
    this.notas,
    this.productoNombre,
    this.precioVenta,
  }) : fechaIngreso = fechaIngreso ?? DateTime.now();

  bool get estaVencido => fechaVencimiento != null && 
      fechaVencimiento!.isBefore(DateTime.now());
  
  bool get proximoAVencer => fechaVencimiento != null && 
      fechaVencimiento!.difference(DateTime.now()).inDays <= 7;
  
  int get diasParaVencer => fechaVencimiento?.difference(DateTime.now()).inDays ?? -1;
  
  bool get tieneStock => cantidadActual > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'numero_lote': numeroLote,
      'codigo_lote_interno': codigoLoteInterno,
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'fecha_ingreso': fechaIngreso.toIso8601String(),
      'cantidad_inicial': cantidadInicial,
      'cantidad_actual': cantidadActual,
      'precio_compra_lote': precioCompraLote,
      'activo': activo ? 1 : 0,
      'notas': notas,
    };
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'],
      productoId: map['producto_id'] ?? 0,
      numeroLote: map['numero_lote'],
      codigoLoteInterno: map['codigo_lote_interno'] ?? '',
      fechaVencimiento: map['fecha_vencimiento'] != null 
          ? DateTime.parse(map['fecha_vencimiento']) 
          : null,
      fechaIngreso: map['fecha_ingreso'] != null
          ? DateTime.parse(map['fecha_ingreso'])
          : DateTime.now(),
      cantidadInicial: map['cantidad_inicial'] ?? 0,
      cantidadActual: map['cantidad_actual'] ?? 0,
      precioCompraLote: map['precio_compra_lote']?.toDouble(),
      activo: map['activo'] == 1,
      notas: map['notas'],
      productoNombre: map['producto_nombre'],
      precioVenta: map['precio_venta']?.toDouble(),
    );
  }

  Lote copyWith({
    int? id,
    int? productoId,
    String? numeroLote,
    String? codigoLoteInterno,
    DateTime? fechaVencimiento,
    DateTime? fechaIngreso,
    int? cantidadInicial,
    int? cantidadActual,
    double? precioCompraLote,
    bool? activo,
    String? notas,
    String? productoNombre,
    double? precioVenta,
  }) {
    return Lote(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      numeroLote: numeroLote ?? this.numeroLote,
      codigoLoteInterno: codigoLoteInterno ?? this.codigoLoteInterno,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      cantidadInicial: cantidadInicial ?? this.cantidadInicial,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      precioCompraLote: precioCompraLote ?? this.precioCompraLote,
      activo: activo ?? this.activo,
      notas: notas ?? this.notas,
      productoNombre: productoNombre ?? this.productoNombre,
      precioVenta: precioVenta ?? this.precioVenta,
    );
  }

  @override
  String toString() {
    return 'Lote{id: $id, productoId: $productoId, cantidadActual: $cantidadActual, codigoLoteInterno: $codigoLoteInterno}';
  }
}