import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/lote.dart';
import '../models/categoria.dart';
import '../../../core/database/database_helper.dart';

class ProductsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Product> _products = [];
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  
  // Cache para búsquedas y filtros
  Map<String, List<Product>> _searchCache = {};
  List<Product>? _cachedLowStockProducts;

  // Getters
  List<Product> get products => _products;
  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Inicializar solo cuando sea necesario
  Future<void> initializeIfNeeded() async {
    if (!_isInitialized) {
      await _loadDataWithoutNotify();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Método privado para cargar datos sin notificar
  Future<void> _loadDataWithoutNotify() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;

    try {
      final db = await _dbHelper.database;
      
      // Cargar productos y categorías en paralelo
      final results = await Future.wait([
        db.rawQuery('''
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
        '''),
        db.query('categorias', orderBy: 'nombre'),
      ]);

      _products = (results[0] as List).map((map) => Product.fromMap(map)).toList();
      _categorias = (results[1] as List).map((map) => Categoria.fromMap(map)).toList();
      
      // Limpiar cache
      _clearCache();
      
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      print('Products error: $e');
      _products = [];
      _categorias = [];
    } finally {
      _isLoading = false;
    }
  }

  // Cargar productos con notificación
  Future<void> loadProducts() async {
    await _loadDataWithoutNotify();
    notifyListeners();
  }

  // Cargar categorías por separado si es necesario
  Future<void> loadCategorias() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query('categorias', orderBy: 'nombre');
      _categorias = result.map((map) => Categoria.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  // Agregar producto con stock inicial - optimizado
  Future<bool> addProductWithInitialStock({
    required Product product,
    String? numeroLote,
    required int cantidadInicial,
    DateTime? fechaVencimiento,
  }) async {
    try {
      final db = await _dbHelper.database;
      final codigoInterno = await _generateCodigoInterno();
      
      bool success = false;
      int? productId;
      
      await db.transaction((txn) async {
        final productWithCode = product.copyWith(
          codigoInterno: codigoInterno,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        );

        productId = await txn.insert('productos', productWithCode.toMap());

        if (cantidadInicial > 0 && productId != null) {
          final codigoLoteInterno = await _generateCodigoLoteInternoInTransaction(txn, productId!);
          
          final lote = Lote(
            productoId: productId!,
            numeroLote: numeroLote,
            codigoLoteInterno: codigoLoteInterno,
            fechaVencimiento: fechaVencimiento,
            cantidadInicial: cantidadInicial,
            cantidadActual: cantidadInicial,
          );

          await txn.insert('lotes', lote.toMap());
        }
        
        success = true;
      });

      if (success) {
        await _loadDataWithoutNotify();
        notifyListeners();
        return true;
      }
      
      return false;
      
    } catch (e) {
      _error = 'Error al agregar producto con stock inicial: $e';
      print('Error en addProductWithInitialStock: $e');
      notifyListeners();
      return false;
    }
  }

  // Agregar producto simple - optimizado
  Future<int?> addProduct(Product product) async {
    try {
      final db = await _dbHelper.database;
      final codigoInterno = await _generateCodigoInterno();
      
      final productWithCode = product.copyWith(
        codigoInterno: codigoInterno,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final productId = await db.insert('productos', productWithCode.toMap());
      
      await _loadDataWithoutNotify();
      notifyListeners();
      
      return productId;
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      print('Error en addProduct: $e');
      notifyListeners();
      return null;
    }
  }

  // Agregar lote - optimizado
  Future<bool> addLote(int productoId, Lote lote) async {
    try {
      final db = await _dbHelper.database;
      final codigoLoteInterno = await _generateCodigoLoteInterno(productoId);
      
      final loteWithCode = lote.copyWith(
        productoId: productoId,
        codigoLoteInterno: codigoLoteInterno,
      );

      await db.insert('lotes', loteWithCode.toMap());
      
      await _loadDataWithoutNotify();
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Error al agregar lote: $e';
      print('Error en addLote: $e');
      notifyListeners();
      return false;
    }
  }

  // Actualizar producto - optimizado
  Future<bool> updateProduct(Product product) async {
    try {
      final db = await _dbHelper.database;
      
      final productWithUpdate = product.copyWith(
        fechaActualizacion: DateTime.now(),
      );

      await db.update(
        'productos',
        productWithUpdate.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      
      await _loadDataWithoutNotify();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // Eliminar producto - optimizado
  Future<bool> deleteProduct(int productId) async {
    try {
      final db = await _dbHelper.database;
      
      await db.update(
        'productos',
        {'activo': 0, 'fecha_actualizacion': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [productId],
      );
      
      await _loadDataWithoutNotify();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // Buscar productos con cache
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    // Verificar cache
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!;
    }
    
    final lowercaseQuery = query.toLowerCase();
    final results = _products.where((product) {
      return product.nombre.toLowerCase().contains(lowercaseQuery) ||
             product.descripcion?.toLowerCase().contains(lowercaseQuery) == true ||
             product.codigoBarras?.contains(query) == true ||
             product.codigoInterno?.contains(query) == true;
    }).toList();
    
    // Guardar en cache (máximo 10 búsquedas)
    if (_searchCache.length >= 10) {
      _searchCache.remove(_searchCache.keys.first);
    }
    _searchCache[query] = results;
    
    return results;
  }

  // Obtener productos con stock bajo - con cache
  List<Product> getProductsWithLowStock() {
    if (_cachedLowStockProducts != null) {
      return _cachedLowStockProducts!;
    }
    
    _cachedLowStockProducts = _products.where((product) => product.tieneStockBajo).toList();
    return _cachedLowStockProducts!;
  }

  // Obtener lotes de un producto
  Future<List<Lote>> getLotesForProduct(int productId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'lotes',
        where: 'producto_id = ? AND activo = 1',
        whereArgs: [productId],
        orderBy: 'fecha_vencimiento ASC',
      );
      
      return result.map((map) => Lote.fromMap(map)).toList();
    } catch (e) {
      print('Error cargando lotes: $e');
      return [];
    }
  }

  // Generar código interno automático
  Future<String> _generateCodigoInterno() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM productos');
      int count = result.first['count'] as int;
      return 'PROD-${(count + 1).toString().padLeft(6, '0')}';
    } catch (e) {
      print('Error generando código interno: $e');
      return 'PROD-${DateTime.now().millisecondsSinceEpoch}';
    }
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

  // Generar código de lote interno en transacción
  Future<String> _generateCodigoLoteInternoInTransaction(dynamic txn, int productoId) async {
    try {
      final result = await txn.rawQuery(
        'SELECT COUNT(*) as count FROM lotes WHERE producto_id = ?',
        [productoId],
      );
      int count = result.first['count'] as int;
      return 'PROD-${productoId.toString().padLeft(6, '0')}-L${(count + 1).toString().padLeft(3, '0')}';
    } catch (e) {
      print('Error generando código de lote en transacción: $e');
      return 'LOTE-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Limpiar cache
  void _clearCache() {
    _searchCache.clear();
    _cachedLowStockProducts = null;
  }

  // Refrescar datos
  Future<void> refresh() async {
    await loadProducts();
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