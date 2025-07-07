// lib/features/products/models/product.dart - CORREGIDO SIN STOCK_ACTUAL
import 'lote.dart';

class Product {
  final int? id;
  final String nombre;
  final String? descripcion;
  final int? categoriaId;
  final String? codigoInterno;
  final String? codigoBarras;
  final double? precioCosto;
  final double precioVenta;
  final int? stockMinimo;
  final String? unidadMedida;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  // Propiedades relacionadas (de joins) - ✅ CALCULADAS, NO ALMACENADAS
  final String? categoriaNombre;
  final List<Lote> lotes;
  final int? _stockActualFromQuery; // ✅ SOLO para cuando viene de query JOIN

  Product({
    this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.codigoInterno,
    this.codigoBarras,
    this.precioCosto,
    required this.precioVenta,
    this.stockMinimo,
    this.unidadMedida,
    this.activo = true,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.categoriaNombre,
    this.lotes = const [],
    int? stockActualFromQuery, // ✅ SOLO para queries
  }) : _stockActualFromQuery = stockActualFromQuery;

  // ✅ MÉTODO CORREGIDO: toMap SIN stock_actual
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'codigo_interno': codigoInterno,
      'codigo_barras': codigoBarras,
      'precio_costo': precioCosto,
      'precio_venta': precioVenta,
      'stock_minimo': stockMinimo,
      // ❌ REMOVIDO: 'stock_actual': stockActual,
      'unidad_medida': unidadMedida,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  // ✅ MÉTODO CORREGIDO: fromMap manejando stock_actual de queries
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      categoriaId: map['categoria_id'],
      codigoInterno: map['codigo_interno'],
      codigoBarras: map['codigo_barras'],
      precioCosto: map['precio_costo'] != null 
          ? (map['precio_costo'] as num).toDouble() 
          : null,
      precioVenta: (map['precio_venta'] ?? 0).toDouble(),
      stockMinimo: map['stock_minimo'],
      unidadMedida: map['unidad_medida'],
      activo: map['activo'] == 1,
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion']) 
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null 
          ? DateTime.parse(map['fecha_actualizacion']) 
          : null,
      categoriaNombre: map['categoria_nombre'],
      // ✅ SOLO cuando viene de query JOIN
      stockActualFromQuery: map['stock_actual'] != null 
          ? (map['stock_actual'] as num).toInt() 
          : null,
    );
  }

  // ✅ GETTER: Stock actual calculado
  int get stockActual {
    // Si viene de query JOIN, usar ese valor
    if (_stockActualFromQuery != null) {
      return _stockActualFromQuery!;
    }
    
    // Si no, calcular desde los lotes
    if (lotes.isEmpty) return 0;
    
    return lotes
        .where((lote) => lote.activo)
        .fold(0, (sum, lote) => sum + lote.cantidadActual);
  }

  // ✅ MÉTODO CORREGIDO: copyWith SIN stock_actual
  Product copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    int? categoriaId,
    String? codigoInterno,
    String? codigoBarras,
    double? precioCosto,
    double? precioVenta,
    int? stockMinimo,
    String? unidadMedida,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? categoriaNombre,
    List<Lote>? lotes,
    int? stockActualFromQuery,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaId: categoriaId ?? this.categoriaId,
      codigoInterno: codigoInterno ?? this.codigoInterno,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      precioCosto: precioCosto ?? this.precioCosto,
      precioVenta: precioVenta ?? this.precioVenta,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      lotes: lotes ?? this.lotes,
      stockActualFromQuery: stockActualFromQuery ?? this._stockActualFromQuery,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, nombre: $nombre, precioVenta: $precioVenta, stockActual: $stockActual}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}