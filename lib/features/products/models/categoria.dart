// lib/features/products/models/categoria.dart
class Categoria {
  final int? id;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime? fechaCreacion;

  Categoria({
    this.id,
    required this.nombre,
    this.descripcion,
    this.activo = true,
    this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo ? 1 : 0,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      activo: map['activo'] == 1,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, nombre: $nombre}';
  }
}