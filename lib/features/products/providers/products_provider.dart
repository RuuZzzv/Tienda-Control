// lib/features/products/providers/products_provider.dart
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

  // Getters
  List<Product> get products => _products;
  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar productos
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await _dbHelper.database;
      
      // Cargar productos con información de stock y categoría
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
      _error = 'Error al cargar productos: $e';
      print('Products error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar categorías
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

  // MÉTODO COMBINADO PARA AGREGAR PRODUCTO CON LOTE INICIAL - CORREGIDO
  Future<bool> addProductWithInitialStock({
    required Product product,
    String? numeroLote,
    required int cantidadInicial,
    DateTime? fechaVencimiento,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // GENERAR CÓDIGOS ANTES DE LA TRANSACCIÓN
      final codigoInterno = await _generateCodigoInterno();
      
      // Iniciar transacción para asegurar consistencia
      bool success = false;
      int? productId;
      
      await db.transaction((txn) async {
        // 1. Insertar producto
        final productWithCode = product.copyWith(
          codigoInterno: codigoInterno,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        );

        productId = await txn.insert('productos', productWithCode.toMap());

        // 2. Insertar lote inicial si se especificó cantidad
        if (cantidadInicial > 0 && productId != null) {
          // GENERAR CÓDIGO DE LOTE DENTRO DE LA TRANSACCIÓN
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
        // Recargar productos
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

  // Agregar producto simple - MÉTODO CORREGIDO
  Future<int?> addProduct(Product product) async {
    try {
      final db = await _dbHelper.database;
      
      // Generar código interno automático
      final codigoInterno = await _generateCodigoInterno();
      
      final productWithCode = product.copyWith(
        codigoInterno: codigoInterno,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // CAPTURAR EL ID DEL PRODUCTO INSERTADO
      final productId = await db.insert('productos', productWithCode.toMap());
      
      // Recargar productos
      await loadProducts();
      
      return productId; // Devolver el ID del producto creado
    } catch (e) {
      _error = 'Error al agregar producto: $e';
      print('Error en addProduct: $e');
      notifyListeners();
      return null;
    }
  }

  // Agregar lote a un producto - MÉTODO CORREGIDO
  Future<bool> addLote(int productoId, Lote lote) async {
    try {
      final db = await _dbHelper.database;
      
      // Generar código de lote interno
      final codigoLoteInterno = await _generateCodigoLoteInterno(productoId);
      
      final loteWithCode = lote.copyWith(
        productoId: productoId, // Asegurar que tiene el ID correcto
        codigoLoteInterno: codigoLoteInterno,
      );

      await db.insert('lotes', loteWithCode.toMap());
      
      // Recargar productos para actualizar stock
      await loadProducts();
      
      return true;
    } catch (e) {
      _error = 'Error al agregar lote: $e';
      print('Error en addLote: $e');
      notifyListeners();
      return false;
    }
  }

  // Actualizar producto
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
      
      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Error al actualizar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // Eliminar producto (marcarlo como inactivo)
  Future<bool> deleteProduct(int productId) async {
    try {
      final db = await _dbHelper.database;
      
      await db.update(
        'productos',
        {'activo': 0, 'fecha_actualizacion': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [productId],
      );
      
      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Error al eliminar producto: $e';
      notifyListeners();
      return false;
    }
  }

  // Buscar productos
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return _products;
    
    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.nombre.toLowerCase().contains(lowercaseQuery) ||
             product.descripcion?.toLowerCase().contains(lowercaseQuery) == true ||
             product.codigoBarras?.contains(query) == true ||
             product.codigoInterno?.contains(query) == true;
    }).toList();
  }

  // Obtener productos con stock bajo
  List<Product> getProductsWithLowStock() {
    return _products.where((product) => product.tieneStockBajo).toList();
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

  // Generar código interno automático - SIN TRANSACCIÓN
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

  // Generar código de lote interno - SIN TRANSACCIÓN
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

  // Generar código de lote interno DENTRO DE TRANSACCIÓN
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

  // Refrescar datos
  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadCategorias(),
    ]);
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}