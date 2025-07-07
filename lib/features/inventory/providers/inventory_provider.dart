// lib/features/inventory/providers/inventory_provider.dart - CORREGIDO Y COMPLETO
import 'package:flutter/material.dart';
import '../models/movimiento_inventario.dart';
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart';
import '../../products/models/product_extensions.dart';
import '../../../core/database/database_helper.dart';

class InventoryProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Product> _products = [];
  List<Lote> _lotes = [];
  List<Lote> get allLotes => _lotes;
  List<MovimientoInventario> _movimientos = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Filtros simplificados para adultos mayores
  String _currentFilter = 'todos'; // 'todos', 'stock_bajo', 'vencidos', 'por_vencer'
  String _searchQuery = '';

  // Cache optimizado
  List<Product>? _cachedFilteredProducts;
  List<Lote>? _cachedFilteredLotes;
  Map<String, dynamic>? _cachedStats;
  String? _lastFilterKey;

  // Getters básicos
  List<Product> get products => _products;
  List<Lote> get lotes => _lotes;
  List<MovimientoInventario> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  String get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  // Getters con cache
  List<Product> get lowStockProducts => 
      _products.where((p) => p.tieneStockBajo).toList();

  List<Lote> get expiredLotes => 
      _lotes.where((l) => l.estaVencido && l.cantidadActual > 0).toList();

  List<Lote> get expiringLotes => 
      _lotes.where((l) => l.proximoAVencer && l.cantidadActual > 0).toList();

  // Inicializar
  Future<void> initializeIfNeeded() async {
    if (!_isInitialized) {
      await loadInventoryData();
      _isInitialized = true;
    }
  }

  // Cargar datos principales
  Future<void> loadInventoryData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Crear datos de prueba si es necesario
      await _ensureTestData();
      
      // Cargar productos y lotes en paralelo
      await Future.wait([
        _loadProductsInternal(),
        _loadLotesInternal(),
      ]);

      // Cargar movimientos de forma asíncrona
      _loadMovimientosInternal();
      
      _clearCache();
      print('Inventario cargado: ${_products.length} productos, ${_lotes.length} lotes');
      
    } catch (e) {
      _error = 'Error al cargar inventario: $e';
      print('Error en loadInventoryData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear datos de prueba si no existen
  Future<void> _ensureTestData() async {
    try {
      final db = await _dbHelper.database;
      
      // Verificar si ya hay productos
      final existingProducts = await db.query('productos', limit: 1);
      if (existingProducts.isNotEmpty) return;
      
      print('Creando datos de prueba para inventario...');
      
      // Crear categoría de prueba
      final categoriaId = await db.insert('categorias', {
        'nombre': 'Alimentos',
        'descripcion': 'Productos alimenticios',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'activo': 1,
      });
      
      // Crear productos de prueba
      final productos = [
        {
          'nombre': 'Arroz Premium',
          'descripcion': 'Arroz blanco de alta calidad',
          'categoria_id': categoriaId,
          'codigo_interno': 'PROD-000001',
          'codigo_barras': '7701234567890',
          'precio_costo': 2500.0,
          'precio_venta': 3500.0,
          'stock_minimo': 10,
          'unidad_medida': 'kilogramo',
          'activo': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
        },
        {
          'nombre': 'Aceite de Cocina',
          'descripcion': 'Aceite vegetal 1L',
          'categoria_id': categoriaId,
          'codigo_interno': 'PROD-000002', 
          'codigo_barras': '7701234567891',
          'precio_costo': 4000.0,
          'precio_venta': 5500.0,
          'stock_minimo': 5,
          'unidad_medida': 'litro',
          'activo': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
        },
        {
          'nombre': 'Leche Entera',
          'descripcion': 'Leche fresca 1L',
          'categoria_id': categoriaId,
          'codigo_interno': 'PROD-000003',
          'codigo_barras': '7701234567892',
          'precio_costo': 2000.0,
          'precio_venta': 2800.0,
          'stock_minimo': 15,
          'unidad_medida': 'litro',
          'activo': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
        },
      ];
      
      for (int i = 0; i < productos.length; i++) {
        final productoId = await db.insert('productos', productos[i]);
        
        // Crear lotes para cada producto
        final lotes = [
          {
            'producto_id': productoId,
            'numero_lote': 'LOTE${(i + 1).toString().padLeft(3, '0')}',
            'codigo_lote_interno': 'PROD-${(productoId).toString().padLeft(6, '0')}-L001',
            'fecha_vencimiento': i == 2 
                ? DateTime.now().add(const Duration(days: 3)).toIso8601String() // Leche próxima a vencer
                : DateTime.now().add(Duration(days: 365 + (i * 30))).toIso8601String(),
            'fecha_ingreso': DateTime.now().subtract(Duration(days: i * 5)).toIso8601String(),
            'cantidad_inicial': [50, 25, 48][i],
            'cantidad_actual': [41, 3, 42][i], // Diferentes niveles de stock
            'precio_costo': productos[i]['precio_costo'],
            'activo': 1,
            'observaciones': 'Lote de prueba número ${i + 1}',
          }
        ];
        
        for (final lote in lotes) {
          await db.insert('lotes', lote);
        }
      }
      
      print('Datos de prueba creados para inventario');
      
    } catch (e) {
      print('Error creando datos de prueba: $e');
    }
  }

  // Cargar productos
  Future<void> _loadProductsInternal() async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.nombre as categoria_nombre,
          COALESCE(SUM(l.cantidad_actual), 0) as stock_actual
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
      rethrow;
    }
  }

  // Cargar lotes
  Future<void> _loadLotesInternal() async {
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
          CASE 
            WHEN l.fecha_vencimiento IS NULL THEN 1 
            ELSE 0 
          END,
          l.fecha_vencimiento ASC,
          p.nombre ASC
      ''');

      _lotes = result.map((map) => Lote.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando lotes: $e');
      _lotes = [];
      rethrow;
    }
  }

  // Cargar movimientos
  Future<void> _loadMovimientosInternal({int limit = 50}) async {
    try {
      final db = await _dbHelper.database;
      
      // Verificar si la tabla existe
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='movimientos_inventario'");

      if (tables.isEmpty) {
        _movimientos = [];
        return;
      }

      final result = await db.rawQuery('''
        SELECT 
          m.*,
          p.nombre as producto_nombre,
          l.numero_lote,
          l.codigo_lote_interno
        FROM movimientos_inventario m
        LEFT JOIN productos p ON m.producto_id = p.id
        LEFT JOIN lotes l ON m.lote_id = l.id
        ORDER BY m.fecha_movimiento DESC
        LIMIT ?
      ''', [limit]);

      _movimientos = result.map((map) => MovimientoInventario.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando movimientos: $e');
      _movimientos = [];
    }
  }

  // Cambiar filtro actual
  void setCurrentFilter(String filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _clearCache();
      notifyListeners();
    }
  }

  // Cambiar búsqueda
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _clearCache();
      notifyListeners();
    }
  }

  // Obtener productos filtrados
  List<Product> getFilteredProducts() {
    final filterKey = '$_currentFilter-$_searchQuery-products';
    
    if (_cachedFilteredProducts != null && _lastFilterKey == filterKey) {
      return _cachedFilteredProducts!;
    }

    List<Product> filtered = List.from(_products);
    
    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.nombre.toLowerCase().contains(query) ||
               (product.descripcion?.toLowerCase().contains(query) ?? false) ||
               (product.codigoBarras?.contains(query) ?? false) ||
               product.codigoDisplay.toLowerCase().contains(query);
      }).toList();
    }
    
    // Aplicar filtro por estado
    switch (_currentFilter) {
      case 'stock_bajo':
        filtered = filtered.where((p) => p.tieneStockBajo).toList();
        break;
      case 'sin_stock':
        filtered = filtered.where((p) => p.sinStock).toList();
        break;
      default:
        // 'todos' - no filtrar
        break;
    }

    _cachedFilteredProducts = filtered;
    _lastFilterKey = filterKey;
    return filtered;
  }

  // Obtener lotes filtrados
  List<Lote> getFilteredLotes() {
    final filterKey = '$_currentFilter-$_searchQuery-lotes';
    
    if (_cachedFilteredLotes != null && _lastFilterKey == filterKey) {
      return _cachedFilteredLotes!;
    }

    List<Lote> filtered = List.from(_lotes);
    
    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((lote) {
        return (lote.productoNombre?.toLowerCase().contains(query) ?? false) ||
               (lote.numeroLote?.toLowerCase().contains(query) ?? false) ||
               (lote.codigoLoteInterno?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // Aplicar filtro por estado
    switch (_currentFilter) {
      case 'vencidos':
        filtered = filtered.where((l) => l.estaVencido && l.cantidadActual > 0).toList();
        break;
      case 'por_vencer':
        filtered = filtered.where((l) => l.proximoAVencer && l.cantidadActual > 0).toList();
        break;
      default:
        // 'todos' - no filtrar
        break;
    }

    _cachedFilteredLotes = filtered;
    _lastFilterKey = filterKey;
    return filtered;
  }

  // Obtener lotes de un producto específico
  List<Lote> getLotesForProduct(int productId) {
    return _lotes.where((lote) => lote.productoId == productId).toList()
      ..sort((a, b) {
        // Ordenar por fecha de vencimiento (más próximos primero)
        if (a.fechaVencimiento == null && b.fechaVencimiento == null) return 0;
        if (a.fechaVencimiento == null) return 1;
        if (b.fechaVencimiento == null) return -1;
        return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
      });
  }

  // Obtener estadísticas
  Map<String, dynamic> getInventoryStats() {
    if (_cachedStats != null) {
      return _cachedStats!;
    }

    _cachedStats = {
      'totalProductos': _products.length,
      'productosStockBajo': lowStockProducts.length,
      'productosStock': _products.where((p) => (p.stockActual ?? 0) > 0).length,
      'productosSinStock': _products.where((p) => (p.stockActual ?? 0) <= 0).length,
      'totalLotes': _lotes.where((l) => l.cantidadActual > 0).length,
      'lotesVencidos': expiredLotes.length,
      'lotesProximosVencer': expiringLotes.length,
      'valorTotalInventario': _calculateTotalInventoryValue(),
    };

    return _cachedStats!;
  }

  // Calcular valor total del inventario
  double _calculateTotalInventoryValue() {
    double total = 0.0;
    
    for (final lote in _lotes) {
      if (lote.cantidadActual > 0) {
        // Usar precio de costo del lote, o precio de venta del producto como fallback
        final precioUnitario = lote.precioCosto ?? 
                              _products.firstWhere(
                                (p) => p.id == lote.productoId,
                                orElse: () => Product(nombre: '', precioVenta: 0),
                              ).precioVenta;
        
        total += (precioUnitario * lote.cantidadActual);
      }
    }
    
    return total;
  }

  // Ajustar stock de un lote
  Future<bool> adjustLoteStock({
    required int loteId,
    required int nuevaCantidad,
    required String motivo,
    String? observaciones,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Obtener el lote actual
      final loteResult = await db.query(
        'lotes',
        where: 'id = ? AND activo = 1',
        whereArgs: [loteId],
      );
      
      if (loteResult.isEmpty) {
        _error = 'Lote no encontrado';
        notifyListeners();
        return false;
      }
      
      final loteActual = Lote.fromMap(loteResult.first);
      final cantidadAnterior = loteActual.cantidadActual;
      final diferencia = nuevaCantidad - cantidadAnterior;
      
      await db.transaction((txn) async {
        // Actualizar cantidad del lote
        await txn.update(
          'lotes',
          {'cantidad_actual': nuevaCantidad},
          where: 'id = ?',
          whereArgs: [loteId],
        );
        
        // Crear movimiento de inventario
        final movimiento = MovimientoInventario.create(
          productoId: loteActual.productoId,
          loteId: loteId,
          tipoMovimiento: diferencia >= 0 ? TipoMovimiento.ajuste : TipoMovimiento.ajuste,
          cantidad: diferencia.abs(),
          motivo: motivo,
          observaciones: observaciones,
        );
        
        // Intentar insertar el movimiento
        try {
          await txn.insert('movimientos_inventario', movimiento.toMap());
        } catch (e) {
          print('Warning: No se pudo crear movimiento: $e');
        }
      });
      
      // Recargar datos
      await _refreshData();
      return true;
      
    } catch (e) {
      _error = 'Error al ajustar stock: $e';
      print('Error en adjustLoteStock: $e');
      notifyListeners();
      return false;
    }
  }

  // Marcar lote como vencido
  Future<bool> markLoteAsExpired(int loteId, String motivo) async {
    try {
      final db = await _dbHelper.database;
      
      final loteResult = await db.query(
        'lotes',
        where: 'id = ? AND activo = 1',
        whereArgs: [loteId],
      );
      
      if (loteResult.isEmpty) {
        _error = 'Lote no encontrado';
        notifyListeners();
        return false;
      }
      
      final lote = Lote.fromMap(loteResult.first);
      
      await db.transaction((txn) async {
        // Actualizar cantidad a 0
        await txn.update(
          'lotes',
          {'cantidad_actual': 0},
          where: 'id = ?',
          whereArgs: [loteId],
        );
        
        // Crear movimiento de vencimiento
        final movimiento = MovimientoInventario.create(
          productoId: lote.productoId,
          loteId: loteId,
          tipoMovimiento: TipoMovimiento.vencimiento,
          cantidad: lote.cantidadActual,
          motivo: motivo,
          observaciones: 'Producto retirado por vencimiento',
        );
        
        try {
          await txn.insert('movimientos_inventario', movimiento.toMap());
        } catch (e) {
          print('Warning: No se pudo crear movimiento: $e');
        }
      });
      
      await _refreshData();
      return true;
      
    } catch (e) {
      _error = 'Error al marcar como vencido: $e';
      print('Error en markLoteAsExpired: $e');
      notifyListeners();
      return false;
    }
  }

  // Refrescar datos optimizado
  Future<void> _refreshData() async {
    await Future.wait([
      _loadProductsInternal(),
      _loadLotesInternal(),
    ]);
    
    _loadMovimientosInternal();
    _clearCache();
    notifyListeners();
  }

  // Limpiar cache
  void _clearCache() {
    _cachedFilteredProducts = null;
    _cachedFilteredLotes = null;
    _cachedStats = null;
    _lastFilterKey = null;
  }

  // Refrescar datos públicamente
  Future<void> refresh() async {
    await loadInventoryData();
  }

  // Limpiar errores
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }
}