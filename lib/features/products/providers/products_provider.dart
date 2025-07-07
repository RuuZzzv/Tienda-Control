// lib/features/products/providers/products_provider.dart - COMPLETO Y CORREGIDO
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
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
  final Map<String, List<Product>> _searchCache = {};
  List<Product>? _cachedLowStockProducts;
  List<Product>? _cachedUrgentRestockProducts;
  List<Product>? _cachedOutOfStockProducts;

  // Getters
  List<Product> get products => _products;
  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  // Estadísticas
  int get totalProducts => _products.length;
  int get lowStockCount => getProductsWithLowStock().length;
  int get outOfStockCount => getOutOfStockProducts().length;
  int get urgentRestockCount => getUrgentRestockProducts().length;

  // Inicializar solo cuando sea necesario - MEJORADO
  Future<void> initializeIfNeeded() async {
    if (_isInitialized) return;
    
    await loadProducts();
    _isInitialized = true;
  }

  // Cargar productos con notificación - CORREGIDO
  Future<void> loadProducts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Crear algunos productos de prueba si no hay datos
      await _ensureTestData();
      
      final db = await _dbHelper.database;
      
      // Cargar productos y categorías en paralelo
      final results = await Future.wait([
        db.rawQuery('''
          SELECT 
            p.*,
            c.nombre as categoria_nombre,
            COALESCE(SUM(CASE WHEN l.activo = 1 THEN l.cantidad_actual ELSE 0 END), 0) as stock_actual
          FROM productos p
          LEFT JOIN categorias c ON p.categoria_id = c.id
          LEFT JOIN lotes l ON p.id = l.producto_id
          WHERE p.activo = 1
          GROUP BY p.id, p.nombre, c.nombre
          ORDER BY p.nombre
        '''),
        db.query('categorias', where: 'activo = 1', orderBy: 'nombre'),
      ]);

      final productsData = results[0] as List<Map<String, dynamic>>;
      final categoriasData = results[1] as List<Map<String, dynamic>>;

      _products = productsData.map((map) {
        // Asegurar que stock_actual se mapee correctamente
        final productMap = Map<String, dynamic>.from(map);
        final stockActual = productMap['stock_actual'];
        if (stockActual != null) {
          productMap['stock_actual'] = (stockActual as num).toInt();
        }
        return Product.fromMap(productMap);
      }).toList();
      
      _categorias = categoriasData.map((map) => Categoria.fromMap(map)).toList();
      
      // Limpiar cache
      _clearCache();
      
      print('Productos cargados: ${_products.length}');
      
    } catch (e) {
      _error = 'Error al cargar productos: $e';
      print('Error en loadProducts: $e');
      _products = [];
      _categorias = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MÉTODO AGREGADO: Cargar categorías por separado
  Future<void> loadCategorias() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'categorias', 
        where: 'activo = 1',
        orderBy: 'nombre'
      );
      _categorias = result.map((map) => Categoria.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  // MÉTODO AGREGADO: Actualizar producto
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
      
      await loadProducts(); // Recargar datos
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO AGREGADO: Actualizar lote
  Future<bool> updateLote(Lote lote) async {
    try {
      final db = await _dbHelper.database;
      
      await db.update(
        'lotes',
        lote.toMap(),
        where: 'id = ?',
        whereArgs: [lote.id],
      );
      
      await loadProducts(); // Recargar datos para actualizar stocks
      return true;
    } catch (e) {
      _error = 'Error al actualizar lote: $e';
      print('Error en updateLote: $e');
      notifyListeners();
      return false;
    }
  }

  // MÉTODO AGREGADO: Obtener lotes de un producto
  Future<List<Lote>> getLotesForProduct(int productId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'lotes',
        where: 'producto_id = ? AND activo = 1',
        whereArgs: [productId],
        orderBy: 'fecha_vencimiento ASC, id DESC',
      );
      
      return result.map((map) => Lote.fromMap(map)).toList();
    } catch (e) {
      print('Error cargando lotes: $e');
      return [];
    }
  }

  // Asegurar datos de prueba - NUEVO
  Future<void> _ensureTestData() async {
    try {
      final db = await _dbHelper.database;
      
      // Verificar si ya hay productos
      final existingProducts = await db.query('productos', limit: 1);
      if (existingProducts.isNotEmpty) return;
      
      print('Creando datos de prueba...');
      
      // Crear categoría de prueba
      final categoriaId = await db.insert('categorias', {
        'nombre': 'Alimentos',
        'descripcion': 'Productos alimenticios',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'activo': 1,
      });
      
      // Crear producto de prueba
      final productoId = await db.insert('productos', {
        'nombre': 'Arroz',
        'descripcion': 'Arroz blanco premium',
        'categoria_id': categoriaId,
        'codigo_interno': 'PROD-000001',
        'codigo_barras': '7701234567890',
        'precio_costo': 2500.0,
        'precio_venta': 3500.0,
        'stock_minimo': 10,
        'unidad_medida': 'kilogramo',
        'activo': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Crear lote de prueba
      await db.insert('lotes', {
        'producto_id': productoId,
        'numero_lote': 'LOTE001',
        'codigo_lote_interno': 'PROD-000001-L001',
        'fecha_vencimiento': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        'fecha_ingreso': DateTime.now().toIso8601String(),
        'cantidad_inicial': 41,
        'cantidad_actual': 41,
        'precio_costo': 2500.0,
        'activo': 1,
        'observaciones': 'Lote inicial de prueba',
      });
      
      print('Datos de prueba creados exitosamente');
      
    } catch (e) {
      print('Error creando datos de prueba: $e');
    }
  }

  // MÉTODO AGREGADO: Agregar lote
  Future<bool> addLote(int productoId, Lote lote) async {
    try {
      final db = await _dbHelper.database;
      final codigoLoteInterno = await _generateCodigoLoteInterno(productoId);
      
      final loteWithCode = lote.copyWith(
        productoId: productoId,
        codigoLoteInterno: codigoLoteInterno,
        activo: true,
      );

      await db.insert('lotes', loteWithCode.toMap());
      
      await loadProducts(); // Recargar datos
      return true;
    } catch (e) {
      _error = 'Error al agregar lote: $e';
      print('Error en addLote: $e');
      notifyListeners();
      return false;
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

  // Agregar producto con stock inicial - optimizado
  Future<bool> addProductWithInitialStock({
    required Product product,
    String? numeroLote,
    required int cantidadInicial,
    DateTime? fechaVencimiento,
    String? observaciones,
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
          activo: true,
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
            observaciones: observaciones,
            activo: true,
          );

          await txn.insert('lotes', lote.toMap());
        }
        
        success = true;
      });

      if (success) {
        await loadProducts();
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
             (product.descripcion?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (product.codigoBarras?.contains(query) ?? false) ||
             (product.codigoInterno?.contains(query) ?? false) ||
             product.codigoDisplay.toLowerCase().contains(lowercaseQuery);
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

  // Obtener productos sin stock - con cache
  List<Product> getOutOfStockProducts() {
    if (_cachedOutOfStockProducts != null) {
      return _cachedOutOfStockProducts!;
    }
    
    _cachedOutOfStockProducts = _products.where((product) => product.sinStock).toList();
    return _cachedOutOfStockProducts!;
  }

  // Obtener productos que necesitan reabastecimiento urgente - con cache
  List<Product> getUrgentRestockProducts() {
    if (_cachedUrgentRestockProducts != null) {
      return _cachedUrgentRestockProducts!;
    }
    
    _cachedUrgentRestockProducts = _products
        .where((product) => product.necesitaReabastecimientoUrgente)
        .toList();
    return _cachedUrgentRestockProducts!;
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
    _cachedUrgentRestockProducts = null;
    _cachedOutOfStockProducts = null;
  }

  // Refrescar datos
  Future<void> refresh() async {
    _isInitialized = false;
    await initializeIfNeeded();
  }

  // Limpiar errores
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // MÉTODOS ADICIONALES PARA COMPLETAR LA FUNCIONALIDAD

  // Eliminar producto
  Future<bool> deleteProduct(int productId) async {
    try {
      final db = await _dbHelper.database;
      
      // Soft delete - marcar como inactivo
      await db.update(
        'productos',
        {
          'activo': 0,
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [productId],
      );
      
      await loadProducts(); // Recargar datos
      return true;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // Obtener producto por ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener producto por código de barras
  Product? getProductByBarcode(String barcode) {
    try {
      return _products.firstWhere((p) => p.codigoBarras == barcode);
    } catch (e) {
      return null;
    }
  }

  // Actualizar stock de un producto (agregando lote)
  Future<bool> updateProductStock({
    required int productId,
    required int cantidad,
    String? numeroLote,
    DateTime? fechaVencimiento,
    String? observaciones,
  }) async {
    try {
      final lote = Lote(
        productoId: productId,
        numeroLote: numeroLote,
        cantidadInicial: cantidad,
        cantidadActual: cantidad,
        fechaVencimiento: fechaVencimiento,
        observaciones: observaciones,
        activo: true,
      );

      return await addLote(productId, lote);
    } catch (e) {
      _error = 'Error al actualizar stock: $e';
      notifyListeners();
      return false;
    }
  }

  // Obtener estadísticas básicas
  Map<String, dynamic> getBasicStats() {
    return {
      'totalProductos': totalProducts,
      'stockBajo': lowStockCount,
      'sinStock': outOfStockCount,
      'reabastecimientoUrgente': urgentRestockCount,
    };
  }

  // Filtrar productos por categoría
  List<Product> getProductsByCategory(int categoriaId) {
    return _products.where((p) => p.categoriaId == categoriaId).toList();
  }

  // Obtener productos próximos a vencer
  Future<List<Map<String, dynamic>>> getProductsNearExpiry({int days = 7}) async {
    try {
      final db = await _dbHelper.database;
      final limitDate = DateTime.now().add(Duration(days: days)).toIso8601String();
      
      final result = await db.rawQuery('''
        SELECT 
          p.nombre as producto_nombre,
          l.*
        FROM lotes l
        INNER JOIN productos p ON l.producto_id = p.id
        WHERE l.activo = 1 
          AND p.activo = 1
          AND l.cantidad_actual > 0
          AND l.fecha_vencimiento IS NOT NULL
          AND l.fecha_vencimiento <= ?
          AND l.fecha_vencimiento >= ?
        ORDER BY l.fecha_vencimiento ASC
      ''', [limitDate, DateTime.now().toIso8601String()]);
      
      return result;
    } catch (e) {
      print('Error obteniendo productos próximos a vencer: $e');
      return [];
    }
  }

  // Agregar nueva categoría
  Future<bool> addCategoria(String nombre, {String? descripcion}) async {
    try {
      final db = await _dbHelper.database;
      
      await db.insert('categorias', {
        'nombre': nombre,
        'descripcion': descripcion,
        'activo': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      await loadCategorias(); // Recargar categorías
      return true;
    } catch (e) {
      _error = 'Error al agregar categoría: $e';
      notifyListeners();
      return false;
    }
  }

  // Agregar producto simple (sin stock inicial)
  Future<bool> addProduct(Product product) async {
    try {
      final db = await _dbHelper.database;
      final codigoInterno = await _generateCodigoInterno();
      
      final productWithCode = product.copyWith(
        codigoInterno: codigoInterno,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
        activo: true,
      );

      await db.insert('productos', productWithCode.toMap());
      
      await loadProducts(); // Recargar datos
      return true;
      
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      print('Error en addProduct: $e');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }
}