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
  bool _isInitialized = false;

  // Filtros
  bool _showLowStockOnly = false;
  bool _showExpiredOnly = false;
  bool _showExpiringOnly = false;
  int? _selectedCategoryId;
  
  // Cache mejorado con timestamps
  List<Lote>? _cachedFilteredLotes;
  List<Product>? _cachedFilteredProducts;
  Map<String, dynamic>? _cachedStats;
  String? _lastFilterKey;
  
  // Cache adicional para búsquedas frecuentes
  final Map<int, List<Lote>> _lotesPerProductCache = {};
  List<Product>? _lowStockProductsCache;
  List<Lote>? _expiredLotesCache;
  List<Lote>? _expiringLotesCache;
  
  // Control de notificaciones
  bool _shouldNotify = true;
  final Set<String> _pendingNotifications = {};

  // Getters básicos
  List<Product> get products => _products;
  List<Lote> get lotes => _lotes;
  List<MovimientoInventario> get movimientos => _movimientos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get showLowStockOnly => _showLowStockOnly;
  bool get showExpiredOnly => _showExpiredOnly;
  bool get showExpiringOnly => _showExpiringOnly;
  int? get selectedCategoryId => _selectedCategoryId;

  // Getters optimizados con cache dedicado
  List<Product> get lowStockProducts {
    _lowStockProductsCache ??= _products.where((p) => 
      (p.stockActual ?? 0) <= (p.stockMinimo ?? 0)
    ).toList();
    return _lowStockProductsCache!;
  }

  List<Lote> get expiredLotes {
    _expiredLotesCache ??= _lotes.where((l) => 
      l.fechaVencimiento != null && 
      DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.cantidadActual > 0
    ).toList();
    return _expiredLotesCache!;
  }

  List<Lote> get expiringLotes {
    _expiringLotesCache ??= _lotes.where((l) => 
      l.fechaVencimiento != null && 
      !DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.fechaVencimiento!.difference(DateTime.now()).inDays <= 7 &&
      l.cantidadActual > 0
    ).toList();
    return _expiringLotesCache!;
  }

  // Inicializar solo cuando sea necesario
  Future<void> initializeIfNeeded() async {
    if (!_isInitialized) {
      await _loadDataWithoutNotify();
      _isInitialized = true;
      _notifyIfNeeded();
    }
  }

  // Método optimizado para notificaciones
  void _notifyIfNeeded() {
    if (_shouldNotify && _pendingNotifications.isNotEmpty) {
      _pendingNotifications.clear();
      notifyListeners();
    }
  }

  // Batch de notificaciones para evitar múltiples rebuilds
  void _batchNotify(String reason) {
    _pendingNotifications.add(reason);
    // Notificar en el siguiente frame para agrupar cambios
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyIfNeeded();
    });
  }

  // Método privado para cargar datos sin notificar
  Future<void> _loadDataWithoutNotify() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    _shouldNotify = false; // Deshabilitar notificaciones temporalmente

    try {
      // Cargar productos y lotes en paralelo para mejor rendimiento
      final results = await Future.wait([
        _loadProductsInternal(),
        _loadLotesInternal(),
      ], eagerError: false);
      
      // Cargar movimientos de forma asíncrona sin bloquear
      _loadMovimientosAsync();
      
      // Limpiar todos los caches
      _clearAllCaches();
      
    } catch (e) {
      _error = 'Error al cargar datos de inventario: $e';
      print('Inventory error: $e');
    } finally {
      _isLoading = false;
      _shouldNotify = true;
    }
  }

  // Cargar movimientos de forma asíncrona
  void _loadMovimientosAsync() {
    _loadMovimientosInternal().then((_) {
      if (_shouldNotify) {
        _batchNotify('movimientos');
      }
    }).catchError((e) {
      print('Warning: No se pudieron cargar movimientos: $e');
      _movimientos = [];
    });
  }

  // Cargar datos con notificación
  Future<void> loadInventoryData() async {
    await _loadDataWithoutNotify();
    _notifyIfNeeded();
  }

  // Cargar productos internamente con query optimizada
  Future<void> _loadProductsInternal() async {
    try {
      final db = await _dbHelper.database;
      
      // Query optimizada con índices apropiados
      final result = await db.rawQuery('''
        SELECT 
          p.*,
          c.nombre as categoria_nombre,
          COALESCE(ls.stock_actual, 0) as stock_actual,
          COALESCE(ls.total_lotes, 0) as total_lotes,
          COALESCE(ls.lotes_proximos_vencer, 0) as lotes_proximos_vencer,
          COALESCE(ls.lotes_vencidos, 0) as lotes_vencidos
        FROM productos p
        LEFT JOIN categorias c ON p.categoria_id = c.id
        LEFT JOIN (
          SELECT 
            producto_id,
            SUM(cantidad_actual) as stock_actual,
            COUNT(*) as total_lotes,
            SUM(CASE 
              WHEN fecha_vencimiento IS NOT NULL 
                AND fecha_vencimiento <= date('now', '+7 days') 
                AND cantidad_actual > 0 
              THEN 1 ELSE 0 
            END) as lotes_proximos_vencer,
            SUM(CASE 
              WHEN fecha_vencimiento IS NOT NULL 
                AND fecha_vencimiento < date('now') 
                AND cantidad_actual > 0 
              THEN 1 ELSE 0 
            END) as lotes_vencidos
          FROM lotes
          WHERE activo = 1
          GROUP BY producto_id
        ) ls ON p.id = ls.producto_id
        WHERE p.activo = 1
        ORDER BY p.nombre
      ''');

      _products = result.map((map) => Product.fromMap(map)).toList();
      
    } catch (e) {
      print('Error cargando productos: $e');
      _products = [];
      rethrow;
    }
  }

  // Cargar lotes internamente con query optimizada
  Future<void> _loadLotesInternal() async {
    try {
      final db = await _dbHelper.database;
      
      // Query optimizada con solo los campos necesarios
      final result = await db.rawQuery('''
        SELECT 
          l.*,
          p.nombre as producto_nombre,
          p.precio_venta
        FROM lotes l
        INNER JOIN productos p ON l.producto_id = p.id
        WHERE l.activo = 1 AND p.activo = 1 AND l.cantidad_actual > 0
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

  // Cargar movimientos con límite y paginación
  Future<void> _loadMovimientosInternal({int limit = 50}) async {
    try {
      final db = await _dbHelper.database;
      
      // Verificar si la tabla existe
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='movimientos_inventario'"
      );
      
      if (tables.isEmpty) {
        _movimientos = [];
        return;
      }
      
      // Query limitada para mejor rendimiento
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

  // Agregar lote optimizado con transacción
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
      
      // Usar transacción para consistencia y rendimiento
      await db.transaction((txn) async {
        final codigoLoteInterno = await _generateCodigoLoteInternoOptimized(txn, productoId);
        
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

        final loteId = await txn.insert('lotes', lote.toMap());
        
        // Intentar crear movimiento en la misma transacción
        try {
          final movimiento = MovimientoInventario(
            productoId: productoId,
            loteId: loteId,
            tipoMovimiento: TipoMovimiento.entrada,
            cantidad: cantidadInicial,
            motivo: 'Ingreso de nuevo lote',
            observaciones: notas,
            fechaMovimiento: DateTime.now(),
          );

          await txn.insert('movimientos_inventario', movimiento.toMap());
        } catch (e) {
          print('Warning: No se pudo crear movimiento: $e');
        }
      });
      
      // Actualizar solo los datos necesarios
      await _refreshDataOptimized();
      
      return true;
    } catch (e) {
      _error = 'Error al agregar lote: $e';
      print('Error en addLote: $e');
      _batchNotify('error');
      return false;
    }
  }

  // Método optimizado para refrescar datos
  Future<void> _refreshDataOptimized() async {
    _shouldNotify = false;
    
    // Cargar solo productos y lotes (los más importantes)
    await Future.wait([
      _loadProductsInternal(),
      _loadLotesInternal(),
    ]);
    
    _clearAllCaches();
    _shouldNotify = true;
    _batchNotify('data-refresh');
    
    // Cargar movimientos de forma asíncrona
    _loadMovimientosAsync();
  }

  // Obtener lotes para un producto con cache
  List<Lote> getLotesForProduct(int productId) {
    // Usar cache por producto
    if (!_lotesPerProductCache.containsKey(productId)) {
      _lotesPerProductCache[productId] = _lotes
          .where((lote) => lote.productoId == productId)
          .toList();
    }
    return _lotesPerProductCache[productId]!;
  }

  // Obtener lotes filtrados con cache mejorado
  List<Lote> getFilteredLotes() {
    final filterKey = 'lotes-$_showExpiredOnly-$_showExpiringOnly';
    
    if (_cachedFilteredLotes != null && _lastFilterKey == filterKey) {
      return _cachedFilteredLotes!;
    }
    
    // Usar listas pre-cacheadas cuando sea posible
    if (_showExpiredOnly) {
      _cachedFilteredLotes = List.from(expiredLotes);
    } else if (_showExpiringOnly) {
      _cachedFilteredLotes = List.from(expiringLotes);
    } else {
      _cachedFilteredLotes = List.from(_lotes);
    }
    
    _lastFilterKey = filterKey;
    return _cachedFilteredLotes!;
  }

  // Obtener productos filtrados con cache mejorado
  List<Product> getFilteredProducts() {
    final filterKey = 'products-$_showLowStockOnly-$_selectedCategoryId';
    
    if (_cachedFilteredProducts != null && _lastFilterKey == filterKey) {
      return _cachedFilteredProducts!;
    }
    
    // Usar lista pre-cacheada para stock bajo
    if (_showLowStockOnly && _selectedCategoryId == null) {
      _cachedFilteredProducts = List.from(lowStockProducts);
    } else {
      List<Product> filtered = _showLowStockOnly 
          ? List.from(lowStockProducts)
          : List.from(_products);
      
      if (_selectedCategoryId != null) {
        filtered = filtered
            .where((product) => product.categoriaId == _selectedCategoryId)
            .toList();
      }
      
      _cachedFilteredProducts = filtered;
    }
    
    _lastFilterKey = filterKey;
    return _cachedFilteredProducts!;
  }

  // Obtener estadísticas con cache permanente
  Map<String, dynamic> getInventoryStats() {
    if (_cachedStats != null) {
      return _cachedStats!;
    }
    
    _cachedStats = {
      'totalProductos': _products.length,
      'productosStockBajo': lowStockProducts.length,
      'lotesVencidos': expiredLotes.length,
      'lotesProximosVencer': expiringLotes.length,
      'totalLotes': _lotes.where((l) => l.cantidadActual > 0).length,
    };
    
    return _cachedStats!;
  }

  // Cambiar filtros con notificación agrupada
  void toggleLowStockFilter() {
    _showLowStockOnly = !_showLowStockOnly;
    _clearFilterCaches();
    _batchNotify('filter-change');
  }

  void toggleExpiredFilter() {
    _showExpiredOnly = !_showExpiredOnly;
    if (_showExpiredOnly) _showExpiringOnly = false;
    _clearFilterCaches();
    _batchNotify('filter-change');
  }

  void toggleExpiringFilter() {
    _showExpiringOnly = !_showExpiringOnly;
    if (_showExpiringOnly) _showExpiredOnly = false;
    _clearFilterCaches();
    _batchNotify('filter-change');
  }

  void setCategoryFilter(int? categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      _clearFilterCaches();
      _batchNotify('filter-change');
    }
  }

  void clearAllFilters() {
    final hasChanges = _showLowStockOnly || _showExpiredOnly || 
                      _showExpiringOnly || _selectedCategoryId != null;
    
    if (hasChanges) {
      _showLowStockOnly = false;
      _showExpiredOnly = false;
      _showExpiringOnly = false;
      _selectedCategoryId = null;
      _clearFilterCaches();
      _batchNotify('filter-clear');
    }
  }

  // Limpiar solo caches de filtros
  void _clearFilterCaches() {
    _cachedFilteredLotes = null;
    _cachedFilteredProducts = null;
    _lastFilterKey = null;
  }

  // Limpiar todos los caches
  void _clearAllCaches() {
    _clearFilterCaches();
    _cachedStats = null;
    _lotesPerProductCache.clear();
    _lowStockProductsCache = null;
    _expiredLotesCache = null;
    _expiringLotesCache = null;
  }

  // Generar código de lote optimizado
  Future<String> _generateCodigoLoteInternoOptimized(dynamic db, int productoId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM lotes WHERE producto_id = ?',
        [productoId],
      );
      int count = (result.first['count'] as int?) ?? 0;
      return 'L${productoId.toString().padLeft(4, '0')}-${(count + 1).toString().padLeft(3, '0')}';
    } catch (e) {
      return 'L${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Refrescar datos
  Future<void> refresh() async {
    await loadInventoryData();
  }

  // Limpiar errores sin notificar si no hay cambios
  void clearError() {
    if (_error != null) {
      _error = null;
      _batchNotify('error-clear');
    }
  }

  @override
  void dispose() {
    _clearAllCaches();
    _pendingNotifications.clear();
    super.dispose();
  }
}