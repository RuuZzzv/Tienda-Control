// lib/features/products/models/product.dart
import 'lote.dart';

class Product {
  final int? id;
  final String nombre;
  final String? descripcion;
  final int? categoriaId;
  final String? codigoInterno;
  final String? codigoBarras;
  final double precioCompra;
  final double precioVenta;
  final int stockMinimo;
  final String unidadMedida;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  // Propiedades calculadas
  String? categoriaNombre;
  int stockActual;
  List<Lote> lotes;

  Product({
    this.id,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.codigoInterno,
    this.codigoBarras,
    this.precioCompra = 0,
    required this.precioVenta,
    this.stockMinimo = 0,
    this.unidadMedida = 'unidad',
    this.activo = true,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.categoriaNombre,
    this.stockActual = 0,
    this.lotes = const [],
  });

  bool get tieneStockBajo => stockActual <= stockMinimo;
  
  String get codigoDisplay => codigoInterno ?? codigoBarras ?? 'SIN-CÓDIGO';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria_id': categoriaId,
      'codigo_interno': codigoInterno,
      'codigo_barras': codigoBarras,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'stock_minimo': stockMinimo,
      'unidad_medida': unidadMedida,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      categoriaId: map['categoria_id'],
      codigoInterno: map['codigo_interno'],
      codigoBarras: map['codigo_barras'],
      precioCompra: (map['precio_compra'] ?? 0).toDouble(),
      precioVenta: (map['precio_venta'] ?? 0).toDouble(),
      stockMinimo: map['stock_minimo'] ?? 0,
      unidadMedida: map['unidad_medida'] ?? 'unidad',
      activo: map['activo'] == 1,
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion']) 
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null 
          ? DateTime.parse(map['fecha_actualizacion']) 
          : null,
      categoriaNombre: map['categoria_nombre'],
      stockActual: map['stock_actual'] ?? 0,
    );
  }

  Product copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    int? categoriaId,
    String? codigoInterno,
    String? codigoBarras,
    double? precioCompra,
    double? precioVenta,
    int? stockMinimo,
    String? unidadMedida,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? categoriaNombre,
    int? stockActual,
    List<Lote>? lotes,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoriaId: categoriaId ?? this.categoriaId,
      codigoInterno: codigoInterno ?? this.codigoInterno,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      stockActual: stockActual ?? this.stockActual,
      lotes: lotes ?? this.lotes,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, nombre: $nombre, precioVenta: $precioVenta, stockActual: $stockActual}';
  }
}
