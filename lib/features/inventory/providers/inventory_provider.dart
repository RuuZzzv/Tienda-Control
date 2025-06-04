// lib/features/inventory/providers/inventory_provider.dart
import 'package:flutter/material.dart';
import '../models/movimiento_inventario.dart';
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../../core/database/database_helper.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Product> _products = [];
  List<Lote> _lotes = [];
  List<MovimientoInventario> _movimientos = [];
  bool _isLoading = false;
  String? _error;

  // Filtros
  bool _showLowStockOnly = false;
  bool _showExpiredOnly = false;
  bool _showExpiringOnly = false;
  int? _selectedCategoryId;

  // Getters
  List<Product> get products => _products;
  List<Lote> get lotes => _lotes;
  List<MovimientoInventario> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showLowStockOnly => _showLowStockOnly;
  bool get showExpiredOnly => _showExpiredOnly;
  bool get showExpiringOnly => _showExpiringOnly;
  int? get selectedCategoryId => _selectedCategoryId;

  // Cargar datos de inventario
  Future<void> loadInventoryData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadProducts(),
        loadLotes(),
      ]);
      
      // Intentar cargar movimientos sin fallar si hay error
      try {
        await loadMovimientos();
      } catch (e) {
        print('Warning: No se pudieron cargar movimientos: $e');
        // No falla la carga general, solo no carga movimientos
      }
      
    } catch (e) {
      _error = 'Error al cargar datos de inventario: $e';
      print('Inventory error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar productos con información de stock
  Future<void> loadProducts() async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.nombre as categoria_nombre,
          COALESCE(SUM(l.cantidad_actual), 0) as stock_actual,
          COUNT(l.id) as total_lotes,
          SUM(CASE WHEN l.fecha_vencimiento IS NOT NULL AND l.fecha_vencimiento <= date('now', '+7 days') AND l.cantidad_actual > 0 THEN 1 ELSE 0 END) as lotes_proximos_vencer,
          SUM(CASE WHEN l.fecha_vencimiento IS NOT NULL AND l.fecha_vencimiento < date('now') AND l.cantidad_actual > 0 THEN 1 ELSE 0 END) as lotes_vencidos
        FROM productos p
        LEFT JOIN categorias c ON p.categoria_id = c.id
        LEFT JOIN lotes l ON p.id = l.producto_id AND l.activo = 1
        WHERE p.activo = 1
        GROUP BY p.id, p.nombre, c.nombre
        ORDER BY p.nombre
      ''');

      _products = result.map((map) => Product.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando productos: $e');
      _products = [];
    }
  }

  // Cargar lotes
  Future<void> loadLotes() async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.rawQuery('''
        SELECT 
          l.*,
          p.nombre as producto_nombre,
          p.precio_venta
        FROM lotes l
        INNER JOIN productos p ON l.producto_id = p.id
        WHERE l.activo = 1 AND p.activo = 1
        ORDER BY 
          l.fecha_vencimiento ASC,
          p.nombre ASC
      ''');

      _lotes = result.map((map) => Lote.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando lotes: $e');
      _lotes = [];
    }
  }

  // Cargar movimientos de inventario - con manejo de errores mejorado
  Future<void> loadMovimientos() async {
    try {
      final db = await _dbHelper.database;
      
      // Primero verificar si la tabla existe
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='movimientos_inventario'"
      );
      
      if (tables.isEmpty) {
        print('Warning: Tabla movimientos_inventario no existe');
        _movimientos = [];
        return;
      }
      
      // Verificar las columnas de la tabla
      final columns = await db.rawQuery('PRAGMA table_info(movimientos_inventario)');
      final columnNames = columns.map((col) => col['name']).toList();
      
      print('Columnas disponibles en movimientos_inventario: $columnNames');
      
      // Construir query según las columnas disponibles
      String query;
      if (columnNames.contains('producto_id')) {
        query = '''
          SELECT 
            m.*,
            p.nombre as producto_nombre,
            l.numero_lote,
            l.codigo_lote_interno
          FROM movimientos_inventario m
          LEFT JOIN productos p ON m.producto_id = p.id
          LEFT JOIN lotes l ON m.lote_id = l.id
          ORDER BY m.fecha_movimiento DESC
          LIMIT 100
        ''';
      } else {
        // Si no existe la columna producto_id, solo obtener movimientos básicos
        query = '''
          SELECT * FROM movimientos_inventario 
          ORDER BY fecha_movimiento DESC 
          LIMIT 100
        ''';
      }

      final result = await db.rawQuery(query);
      _movimientos = result.map((map) => MovimientoInventario.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando movimientos: $e');
      _movimientos = [];
    }
  }

  // Agregar lote a un producto
  Future<bool> addLote({
    required int productoId,
    String? numeroLote,
    required int cantidadInicial,
    DateTime? fechaVencimiento,
    double? precioCompraLote,
    String? notas,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Generar código de lote interno
      final codigoLoteInterno = await _generateCodigoLoteInterno(productoId);
      
      final lote = Lote(
        productoId: productoId,
        numeroLote: numeroLote,
        codigoLoteInterno: codigoLoteInterno,
        fechaVencimiento: fechaVencimiento,
        cantidadInicial: cantidadInicial,
        cantidadActual: cantidadInicial,
        precioCompraLote: precioCompraLote,
        notas: notas,
      );

      // Insertar lote
      final loteId = await db.insert('lotes', lote.toMap());
      
      // Intentar crear movimiento de inventario (puede fallar si la tabla no existe)
      try {
        final movimiento = MovimientoInventario(
          productoId: productoId,
          loteId: loteId,
          tipoMovimiento: TipoMovimiento.entrada,
          cantidad: cantidadInicial,
          motivo: 'Ingreso de nuevo lote',
          observaciones: notas,
        );

        await db.insert('movimientos_inventario', movimiento.toMap());
      } catch (e) {
        print('Warning: No se pudo crear movimiento de inventario: $e');
      }
      
      // Recargar datos
      await loadInventoryData();
      
      return true;
    } catch (e) {
      _error = 'Error al agregar lote: $e';
      print('Error en addLote: $e');
      notifyListeners();
      return false;
    }
  }

  // Ajustar stock de un lote
  Future<bool> adjustStock({
    required int loteId,
    required int nuevaCantidad,
    required String motivo,
    String? observaciones,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Obtener lote actual
      final loteResult = await db.query(
        'lotes',
        where: 'id = ?',
        whereArgs: [loteId],
      );
      
      if (loteResult.isEmpty) {
        _error = 'Lote no encontrado';
        notifyListeners();
        return false;
      }
      
      final loteData = loteResult.first;
      final cantidadAnterior = loteData['cantidad_actual'] as int;
      final productoId = loteData['producto_id'] as int;
      
      // Actualizar cantidad del lote
      await db.update(
        'lotes',
        {'cantidad_actual': nuevaCantidad},
        where: 'id = ?',
        whereArgs: [loteId],
      );
      
      // Intentar crear movimiento de inventario
      try {
        final diferencia = nuevaCantidad - cantidadAnterior;
        final tipoMovimiento = diferencia > 0 
            ? TipoMovimiento.entrada 
            : TipoMovimiento.salida;
        
        final movimiento = MovimientoInventario(
          productoId: productoId,
          loteId: loteId,
          tipoMovimiento: tipoMovimiento,
          cantidad: diferencia.abs(),
          motivo: motivo,
          observaciones: observaciones,
        );

        await db.insert('movimientos_inventario', movimiento.toMap());
      } catch (e) {
        print('Warning: No se pudo crear movimiento de inventario: $e');
      }
      
      // Recargar datos
      await loadInventoryData();
      
      return true;
    } catch (e) {
      _error = 'Error al ajustar stock: $e';
      print('Error en adjustStock: $e');
      notifyListeners();
      return false;
    }
  }

  // Obtener lotes filtrados
  List<Lote> getFilteredLotes() {
    List<Lote> filtered = List.from(_lotes);
    
    if (_showExpiredOnly) {
      filtered = filtered.where((lote) => 
        lote.fechaVencimiento != null && 
        DateTime.now().isAfter(lote.fechaVencimiento!) &&
        lote.cantidadActual > 0
      ).toList();
    } else if (_showExpiringOnly) {
      filtered = filtered.where((lote) => 
        lote.fechaVencimiento != null && 
        !DateTime.now().isAfter(lote.fechaVencimiento!) &&
        lote.fechaVencimiento!.difference(DateTime.now()).inDays <= 7 &&
        lote.cantidadActual > 0
      ).toList();
    }
    
    return filtered;
  }

  // Obtener productos filtrados
  List<Product> getFilteredProducts() {
    List<Product> filtered = List.from(_products);
    
    if (_showLowStockOnly) {
      filtered = filtered.where((product) => 
        (product.stockActual ?? 0) <= (product.stockMinimo ?? 0)
      ).toList();
    }
    
    if (_selectedCategoryId != null) {
      filtered = filtered.where((product) => product.categoriaId == _selectedCategoryId).toList();
    }
    
    return filtered;
  }

  // Obtener estadísticas de inventario - versión simplificada y segura
  Map<String, dynamic> getInventoryStats() {
    try {
      final totalProductos = _products.length;
      final productosStockBajo = _products.where((p) => 
        (p.stockActual ?? 0) <= (p.stockMinimo ?? 0)
      ).length;
      final lotesVencidos = _lotes.where((l) => 
        l.fechaVencimiento != null && 
        DateTime.now().isAfter(l.fechaVencimiento!) &&
        l.cantidadActual > 0
      ).length;
      final lotesProximosVencer = _lotes.where((l) => 
        l.fechaVencimiento != null && 
        !DateTime.now().isAfter(l.fechaVencimiento!) &&
        l.fechaVencimiento!.difference(DateTime.now()).inDays <= 7 &&
        l.cantidadActual > 0
      ).length;
      final totalLotes = _lotes.where((l) => l.cantidadActual > 0).length;
      
      return {
        'totalProductos': totalProductos,
        'productosStockBajo': productosStockBajo,
        'lotesVencidos': lotesVencidos,
        'lotesProximosVencer': lotesProximosVencer,
        'totalLotes': totalLotes,
      };
    } catch (e) {
      print('Error calculando estadísticas: $e');
      return {
        'totalProductos': 0,
        'productosStockBajo': 0,
        'lotesVencidos': 0,
        'lotesProximosVencer': 0,
        'totalLotes': 0,
      };
    }
  }

  // Obtener lotes para un producto específico
  List<Lote> getLotesForProduct(int productId) {
    return _lotes.where((lote) => lote.productoId == productId).toList();
  }

  // Cambiar filtros
  void toggleLowStockFilter() {
    _showLowStockOnly = !_showLowStockOnly;
    notifyListeners();
  }

  void toggleExpiredFilter() {
    _showExpiredOnly = !_showExpiredOnly;
    if (_showExpiredOnly) _showExpiringOnly = false;
    notifyListeners();
  }

  void toggleExpiringFilter() {
    _showExpiringOnly = !_showExpiringOnly;
    if (_showExpiringOnly) _showExpiredOnly = false;
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void clearAllFilters() {
    _showLowStockOnly = false;
    _showExpiredOnly = false;
    _showExpiringOnly = false;
    _selectedCategoryId = null;
    notifyListeners();
  }

  // Generar código de lote interno
  Future<String> _generateCodigoLoteInterno(int productoId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM lotes WHERE producto_id = ?',
        [productoId],
      );
      int count = result.first['count'] as int;
      return 'PROD-${productoId.toString().padLeft(6, '0')}-L${(count + 1).toString().padLeft(3, '0')}';
    } catch (e) {
      print('Error generando código de lote: $e');
      return 'LOTE-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Refrescar datos
  Future<void> refresh() async {
    await loadInventoryData();
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}