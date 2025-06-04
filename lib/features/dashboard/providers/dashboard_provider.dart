// lib/features/dashboard/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../../../core/database/database_helper.dart';

class DashboardProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  bool _databaseRepaired = false;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final statsData = await _dbHelper.getDashboardStats();
      _stats = DashboardStats.fromMap(statsData);
      
      if (_stats!.totalProductos == 0 && !_databaseRepaired) {
        print('🔧 Datos inconsistentes detectados, verificando base de datos...');
        
        final repaired = await _dbHelper.verifyAndRepairDatabase();
        if (repaired) {
          _databaseRepaired = true;
          print('✅ Base de datos reparada, recargando datos...');
          
          final newStatsData = await _dbHelper.getDashboardStats();
          _stats = DashboardStats.fromMap(newStatsData);
        }
      }
      
      print('📊 Dashboard cargado: ${_stats!.totalProductos} productos, \$${_stats!.ventasHoy} en ventas');
      
    } catch (e) {
      print('❌ Error cargando dashboard: $e');
      
      if (e.toString().contains('no such column: recibo_enviado')) {
        print('🔧 Error de columna detectado, reparando automáticamente...');
        
        try {
          await _dbHelper.verifyAndRepairDatabase();
          _databaseRepaired = true;
          
          final statsData = await _dbHelper.getDashboardStats();
          _stats = DashboardStats.fromMap(statsData);
          print('✅ Dashboard reparado y cargado exitosamente');
          
        } catch (repairError) {
          _error = 'Error al reparar la base de datos: $repairError';
          _stats = DashboardStats.empty();
        }
      } else {
        _error = 'Error al cargar datos del dashboard: $e';
        _stats = DashboardStats.empty();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    print('🔄 Refrescando dashboard...');
    await loadDashboardData();
  }

  Future<void> forceReload() async {
    _databaseRepaired = false;
    await loadDashboardData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String get resumenVentas {
    if (_stats == null) return 'Sin datos';
    
    final ventas = _stats!.ventasHoy;
    final cantidad = _stats!.cantidadVentasHoy;
    
    if (cantidad == 0) return 'Sin ventas hoy';
    
    return '\$${ventas.toStringAsFixed(0)} en $cantidad ${cantidad == 1 ? 'venta' : 'ventas'}';
  }

  bool get tieneAlertas {
    return _stats?.productosStockBajo != null && _stats!.productosStockBajo > 0;
  }

  String get mensajeAlerta {
    if (!tieneAlertas) return '';
    
    final cantidad = _stats!.productosStockBajo;
    return '$cantidad ${cantidad == 1 ? 'producto tiene' : 'productos tienen'} stock bajo';
  }

  Map<String, dynamic> get debugInfo {
    return {
      'stats': _stats?.toString() ?? 'null',
      'isLoading': _isLoading,
      'error': _error ?? 'none',
      'databaseRepaired': _databaseRepaired,
    };
  }
}