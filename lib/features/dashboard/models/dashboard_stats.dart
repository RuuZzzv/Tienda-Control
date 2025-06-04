// lib/features/dashboard/models/dashboard_stats.dart
class DashboardStats {
  final double ventasHoy;
  final int cantidadVentasHoy;
  final int totalProductos;
  final int productosStockBajo;
  final List<VentaReciente> ventasRecientes;

  DashboardStats({
    required this.ventasHoy,
    required this.cantidadVentasHoy,
    required this.totalProductos,
    required this.productosStockBajo,
    required this.ventasRecientes,
  });

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      ventasHoy: (map['ventasHoy'] ?? 0).toDouble(),
      cantidadVentasHoy: map['cantidadVentasHoy'] ?? 0,
      totalProductos: map['totalProductos'] ?? 0,
      productosStockBajo: map['productosStockBajo'] ?? 0,
      ventasRecientes: (map['ventasRecientes'] as List<dynamic>? ?? [])
          .map((item) => VentaReciente.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(
      ventasHoy: 0,
      cantidadVentasHoy: 0,
      totalProductos: 0,
      productosStockBajo: 0,
      ventasRecientes: [],
    );
  }
}

class VentaReciente {
  final String numeroVenta;
  final double total;
  final DateTime fechaVenta;
  final bool reciboEnviado;

  VentaReciente({
    required this.numeroVenta,
    required this.total,
    required this.fechaVenta,
    required this.reciboEnviado,
  });

  factory VentaReciente.fromMap(Map<String, dynamic> map) {
    return VentaReciente(
      numeroVenta: map['numero_venta'] ?? 'N/A',
      total: (map['total'] ?? 0).toDouble(),
      fechaVenta: map['fecha_venta'] != null 
          ? DateTime.parse(map['fecha_venta']) 
          : DateTime.now(),
      reciboEnviado: (map['recibo_enviado'] ?? 0) == 1,
    );
  }
}