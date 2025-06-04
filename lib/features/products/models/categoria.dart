// lib/features/products/models/categoria.dart
class Categoria {
  final int? id;
  final String nombre;
  final String? descripcion;
  final DateTime? fechaCreacion;

  Categoria({
    this.id,
    required this.nombre,
    this.descripcion,
    this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'],
      fechaCreacion: map['fecha_creacion'] != null 
          ? DateTime.parse(map['fecha_creacion']) 
          : null,
    );
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaCreacion,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return 'Categoria{id: $id, nombre: $nombre}';
  }
}