// lib/features/products/models/lote.dart
class Lote {
  final int? id;
  final int productoId;
  final String? numeroLote;
  final String? codigoLoteInterno;
  final DateTime? fechaVencimiento;
  final DateTime? fechaIngreso;
  final int cantidadInicial;
  final int cantidadActual;
  final double? precioCosto; // Renombrado de precioCompraLote para consistencia
  final bool activo;
  final String? observaciones; // Renombrado de notas para consistencia con el resto del código

  // Propiedades relacionadas (de joins)
  final String? productoNombre;
  final double? productoReferenciaPrecio; // Renombrado para claridad

  Lote({
    this.id,
    required this.productoId,
    this.numeroLote,
    this.codigoLoteInterno,
    this.fechaVencimiento,
    DateTime? fechaIngreso,
    required this.cantidadInicial,
    required this.cantidadActual,
    this.precioCosto,
    this.activo = true,
    this.observaciones,
    this.productoNombre,
    this.productoReferenciaPrecio,
  }) : fechaIngreso = fechaIngreso ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'numero_lote': numeroLote,
      'codigo_lote_interno': codigoLoteInterno,
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'fecha_ingreso': fechaIngreso?.toIso8601String(),
      'cantidad_inicial': cantidadInicial,
      'cantidad_actual': cantidadActual,
      'precio_costo': precioCosto,
      'activo': activo ? 1 : 0,
      'observaciones': observaciones,
    };
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'],
      productoId: map['producto_id'] ?? 0,
      numeroLote: map['numero_lote'],
      codigoLoteInterno: map['codigo_lote_interno'],
      fechaVencimiento: map['fecha_vencimiento'] != null 
          ? DateTime.parse(map['fecha_vencimiento']) 
          : null,
      fechaIngreso: map['fecha_ingreso'] != null
          ? DateTime.parse(map['fecha_ingreso'])
          : DateTime.now(),
      cantidadInicial: map['cantidad_inicial'] ?? 0,
      cantidadActual: map['cantidad_actual'] ?? 0,
      precioCosto: map['precio_costo'] != null 
          ? (map['precio_costo'] as num).toDouble() 
          : null,
      activo: map['activo'] == 1,
      observaciones: map['observaciones'] ?? map['notas'], // Compatibilidad con campo antiguo
      productoNombre: map['producto_nombre'],
      productoReferenciaPrecio: map['precio_venta'] != null 
          ? (map['precio_venta'] as num).toDouble() 
          : null,
    );
  }

  // Propiedades calculadas
  bool get tieneStock => cantidadActual > 0;
  bool get estaVencido => fechaVencimiento != null && DateTime.now().isAfter(fechaVencimiento!);
  bool get proximoAVencer => fechaVencimiento != null && 
      fechaVencimiento!.difference(DateTime.now()).inDays <= 7 && 
      cantidadActual > 0;
  int get diasParaVencer => fechaVencimiento != null 
      ? fechaVencimiento!.difference(DateTime.now()).inDays 
      : -1; // -1 si no hay fecha de vencimiento

  Lote copyWith({
    int? id,
    int? productoId,
    String? numeroLote,
    String? codigoLoteInterno,
    DateTime? fechaVencimiento,
    DateTime? fechaIngreso,
    int? cantidadInicial,
    int? cantidadActual,
    double? precioCosto,
    bool? activo,
    String? observaciones,
    String? productoNombre,
    double? productoReferenciaPrecio,
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
      precioCosto: precioCosto ?? this.precioCosto,
      activo: activo ?? this.activo,
      observaciones: observaciones ?? this.observaciones,
      productoNombre: productoNombre ?? this.productoNombre,
      productoReferenciaPrecio: productoReferenciaPrecio ?? this.productoReferenciaPrecio,
    );
  }

  @override
  String toString() {
    return 'Lote{id: $id, productoId: $productoId, cantidadActual: $cantidadActual, numeroLote: $numeroLote}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lote &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}