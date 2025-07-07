// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'mi_inventario.db';
  static const int _databaseVersion = 3; // ⬆️ INCREMENTAMOS LA VERSIÓN

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createAllTables(db);
    await _createIndexes(db);
    await _insertInitialData(db);
    print('✅ Base de datos creada exitosamente con versión $version');
  }

  Future<void> _createAllTables(Database db) async {
    // Crear tabla de categorías CON la columna activo
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT
      )
    ''');

    // Crear tabla de productos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        categoria_id INTEGER,
        codigo_interno TEXT UNIQUE,
        codigo_barras TEXT,
        precio_costo REAL DEFAULT 0,
        precio_venta REAL NOT NULL,
        stock_minimo INTEGER DEFAULT 0,
        unidad_medida TEXT DEFAULT 'unidad',
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT,
        FOREIGN KEY (categoria_id) REFERENCES categorias (id)
      )
    ''');

    // Crear tabla de lotes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS lotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        numero_lote TEXT,
        codigo_lote_interno TEXT NOT NULL,
        fecha_vencimiento TEXT,
        fecha_ingreso TEXT NOT NULL,
        cantidad_inicial INTEGER NOT NULL,
        cantidad_actual INTEGER NOT NULL,
        precio_costo REAL,
        activo INTEGER DEFAULT 1,
        observaciones TEXT,
        FOREIGN KEY (producto_id) REFERENCES productos (id)
      )
    ''');

    // Crear tabla de ventas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_venta TEXT UNIQUE,
        fecha_venta TEXT NOT NULL,
        subtotal REAL NOT NULL,
        descuento REAL DEFAULT 0,
        impuestos REAL DEFAULT 0,
        total REAL NOT NULL,
        metodo_pago TEXT,
        cliente_nombre TEXT,
        cliente_documento TEXT,
        vendedor TEXT,
        observaciones TEXT,
        recibo_enviado INTEGER DEFAULT 0,
        activo INTEGER DEFAULT 1
      )
    ''');

    // Crear tabla de detalles de venta
    await db.execute('''
      CREATE TABLE IF NOT EXISTS detalle_ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        lote_id INTEGER,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        descuento_item REAL DEFAULT 0,
        subtotal_item REAL NOT NULL,
        FOREIGN KEY (venta_id) REFERENCES ventas (id),
        FOREIGN KEY (producto_id) REFERENCES productos (id),
        FOREIGN KEY (lote_id) REFERENCES lotes (id)
      )
    ''');

    // Crear tabla de movimientos de inventario
    await db.execute('''
      CREATE TABLE IF NOT EXISTS movimientos_inventario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        lote_id INTEGER,
        tipo_movimiento INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        motivo TEXT NOT NULL,
        observaciones TEXT,
        fecha_movimiento TEXT NOT NULL,
        usuario_id TEXT,
        costo_unitario REAL,
        valor_total REAL,
        FOREIGN KEY (producto_id) REFERENCES productos (id),
        FOREIGN KEY (lote_id) REFERENCES lotes (id)
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_productos_activo ON productos (activo)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos (categoria_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_productos_codigo_barras ON productos (codigo_barras)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_productos_codigo_interno ON productos (codigo_interno)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lotes_producto ON lotes (producto_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lotes_activo ON lotes (activo)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_lotes_vencimiento ON lotes (fecha_vencimiento)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas (fecha_venta)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_ventas_activo ON ventas (activo)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_movimientos_producto ON movimientos_inventario (producto_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_movimientos_lote ON movimientos_inventario (lote_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_movimientos_fecha ON movimientos_inventario (fecha_movimiento)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_categorias_activo ON categorias (activo)',
    );
  }

  Future<void> _insertInitialData(Database db) async {
    // Verificar si ya hay categorías para no duplicar
    final categoriasExistentes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categorias',
    );
    if (categoriasExistentes.first['count'] as int > 0) {
      print('ℹ️ Categorías ya existen, omitiendo inserción inicial');
      return;
    }

    // Insertar categorías iniciales
    final categorias = [
      {
        'nombre': 'Alimentos',
        'descripcion': 'Productos alimenticios básicos',
      },
      {
        'nombre': 'Bebidas',
        'descripcion': 'Bebidas alcohólicas y no alcohólicas',
      },
      {'nombre': 'Lácteos', 'descripcion': 'Leche, queso, yogurt, etc.'},
      {'nombre': 'Carnes', 'descripcion': 'Carnes rojas, blancas y embutidos'},
      {
        'nombre': 'Panadería',
        'descripcion': 'Pan, pasteles y productos de panadería',
      },
      {'nombre': 'Limpieza', 'descripcion': 'Productos de aseo y limpieza'},
      {
        'nombre': 'Aseo Personal',
        'descripcion': 'Productos de higiene personal',
      },
      {'nombre': 'Dulces', 'descripcion': 'Chocolates, caramelos y dulces'},
    ];

    for (var categoria in categorias) {
      await db.insert('categorias', {
        'nombre': categoria['nombre'],
        'descripcion': categoria['descripcion'],
        'activo': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
    }

    print('✅ Datos iniciales insertados correctamente');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Actualizando base de datos de versión $oldVersion a $newVersion');

    if (oldVersion < 2) {
      // Agregar columna activo a la tabla categorias si no existe
      try {
        await db.execute(
          'ALTER TABLE categorias ADD COLUMN activo INTEGER DEFAULT 1',
        );
        print('✅ Columna activo agregada a tabla categorias');
      } catch (e) {
        print('ℹ️ Columna activo ya existe o error: $e');
      }
    }

    if (oldVersion < 3) {
      // Verificar si la columna activo existe en categorias
      try {
        final result = await db.rawQuery("PRAGMA table_info(categorias)");
        bool tieneActivo = result.any((column) => column['name'] == 'activo');
        
        if (!tieneActivo) {
          print('🔧 Agregando columna activo a categorias...');
          await db.execute(
            'ALTER TABLE categorias ADD COLUMN activo INTEGER DEFAULT 1',
          );
          print('✅ Columna activo agregada exitosamente');
        } else {
          print('ℹ️ La columna activo ya existe en categorias');
        }

        // Verificar si la tabla ventas tiene la columna recibo_enviado
        final ventasInfo = await db.rawQuery("PRAGMA table_info(ventas)");
        bool tieneReciboEnviado = ventasInfo.any(
          (column) => column['name'] == 'recibo_enviado',
        );

        if (!tieneReciboEnviado) {
          print('🔧 Agregando columna recibo_enviado a ventas...');
          await db.execute(
            'ALTER TABLE ventas ADD COLUMN recibo_enviado INTEGER DEFAULT 0',
          );
          print('✅ Columna recibo_enviado agregada exitosamente');
        }

        // Crear índices que puedan faltar
        await _createMissingIndexes(db);

      } catch (e) {
        print('❌ Error en migración: $e');
        // En caso de error grave, recrear las tablas
        await _recreateDatabase(db);
      }
    }

    print('✅ Actualización de base de datos completada');
  }

  Future<void> _createMissingIndexes(Database db) async {
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_categorias_activo ON categorias (activo)',
      );
      print('✅ Índices faltantes creados');
    } catch (e) {
      print('ℹ️ Error creando índices (pueden ya existir): $e');
    }
  }

  Future<void> _recreateDatabase(Database db) async {
    print('🔧 Recreando estructura de base de datos...');
    
    // Hacer backup de datos existentes
    final categorias = await db.rawQuery('SELECT * FROM categorias').catchError((e) => <Map<String, dynamic>>[]);
    final productos = await db.rawQuery('SELECT * FROM productos').catchError((e) => <Map<String, dynamic>>[]);
    
    // Recrear tabla categorias
    await db.execute('DROP TABLE IF EXISTS categorias');
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        descripcion TEXT,
        activo INTEGER DEFAULT 1,
        fecha_creacion TEXT
      )
    ''');
    
    // Restaurar categorías
    for (var categoria in categorias) {
      await db.insert('categorias', {
        'id': categoria['id'],
        'nombre': categoria['nombre'],
        'descripcion': categoria['descripcion'],
        'activo': 1, // Asegurar que tiene la columna activo
        'fecha_creacion': categoria['fecha_creacion'] ?? DateTime.now().toIso8601String(),
      });
    }
    
    // Si no hay categorías, insertar las iniciales
    if (categorias.isEmpty) {
      await _insertInitialData(db);
    }
    
    print('✅ Base de datos recreada exitosamente');
  }

  // Método para verificar y reparar la base de datos
  Future<bool> verifyAndRepairDatabase() async {
    try {
      final db = await database;

      // Verificar estructura de categorias
      final categoriasInfo = await db.rawQuery("PRAGMA table_info(categorias)");
      bool categoriasOk = categoriasInfo.any((column) => column['name'] == 'activo');

      if (!categoriasOk) {
        print('🔧 Reparando tabla categorias...');
        await db.execute(
          'ALTER TABLE categorias ADD COLUMN activo INTEGER DEFAULT 1',
        );
        print('✅ Tabla categorias reparada');
        return true;
      }

      // Verificar estructura de ventas
      final ventasInfo = await db.rawQuery("PRAGMA table_info(ventas)");
      bool ventasOk = ventasInfo.any((column) => column['name'] == 'recibo_enviado');

      if (!ventasOk) {
        print('🔧 Reparando tabla ventas...');
        await db.execute(
          'ALTER TABLE ventas ADD COLUMN recibo_enviado INTEGER DEFAULT 0',
        );
        print('✅ Tabla ventas reparada');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error verificando base de datos: $e');
      return false;
    }
  }

  // Método para obtener estadísticas del dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final db = await database;

      // Ventas de hoy
      final hoy = DateTime.now();
      final inicioDelDia =
          DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
      final finDelDia =
          DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59).toIso8601String();

      final ventasHoyResult = await db.rawQuery(
        '''
        SELECT 
          COALESCE(SUM(total), 0) as ventas_hoy,
          COUNT(*) as cantidad_ventas_hoy
        FROM ventas 
        WHERE fecha_venta >= ? AND fecha_venta <= ? AND activo = 1
      ''',
        [inicioDelDia, finDelDia],
      );

      // Total de productos activos
      final productosResult = await db.rawQuery('''
        SELECT COUNT(*) as total_productos
        FROM productos 
        WHERE activo = 1
      ''');

      // Productos con stock bajo
      final stockBajoResult = await db.rawQuery('''
        SELECT COUNT(*) as productos_stock_bajo
        FROM productos p
        LEFT JOIN (
          SELECT 
            producto_id,
            COALESCE(SUM(cantidad_actual), 0) as stock_total
          FROM lotes 
          WHERE activo = 1
          GROUP BY producto_id
        ) l ON p.id = l.producto_id
        WHERE p.activo = 1 AND COALESCE(l.stock_total, 0) <= p.stock_minimo
      ''');

      // Lotes vencidos
      final lotesVencidosResult = await db.rawQuery('''
        SELECT COUNT(*) as lotes_vencidos
        FROM lotes l
        INNER JOIN productos p ON l.producto_id = p.id
        WHERE l.activo = 1 
          AND p.activo = 1 
          AND l.cantidad_actual > 0
          AND l.fecha_vencimiento IS NOT NULL
          AND l.fecha_vencimiento < datetime('now')
      ''');

      // Lotes próximos a vencer (7 días)
      final lotesProximosVencerResult = await db.rawQuery('''
        SELECT COUNT(*) as lotes_proximos_vencer
        FROM lotes l
        INNER JOIN productos p ON l.producto_id = p.id
        WHERE l.activo = 1 
          AND p.activo = 1 
          AND l.cantidad_actual > 0
          AND l.fecha_vencimiento IS NOT NULL
          AND l.fecha_vencimiento >= datetime('now')
          AND l.fecha_vencimiento <= datetime('now', '+7 days')
      ''');

      final result = {
        'ventasHoy': ventasHoyResult.first['ventas_hoy'],
        'cantidadVentasHoy': ventasHoyResult.first['cantidad_ventas_hoy'],
        'totalProductos': productosResult.first['total_productos'],
        'productosStockBajo': stockBajoResult.first['productos_stock_bajo'],
        'lotesVencidos': lotesVencidosResult.first['lotes_vencidos'],
        'lotesProximosVencer': lotesProximosVencerResult.first['lotes_proximos_vencer'],
      };

      return result;
    } catch (e) {
      print('❌ Error getting dashboard stats: $e');
      return {
        'ventasHoy': 0,
        'cantidadVentasHoy': 0,
        'totalProductos': 0,
        'productosStockBajo': 0,
        'lotesVencidos': 0,
        'lotesProximosVencer': 0,
      };
    }
  }

  // Método para obtener información de la base de datos
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;

    final productCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM productos WHERE activo = 1',
    );
    final categoryCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categorias WHERE activo = 1',
    );
    final loteCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lotes WHERE activo = 1',
    );
    final ventasCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ventas WHERE activo = 1',
    );

    return {
      'productos': productCount.first['count'],
      'categorias': categoryCount.first['count'],
      'lotes': loteCount.first['count'],
      'ventas': ventasCount.first['count'],
      'version': _databaseVersion,
    };
  }

  // Métodos de utilidad para consultas comunes
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, 
    String where, 
    List<dynamic> whereArgs
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> insertRecord(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<int> updateRecord(
    String table, 
    Map<String, dynamic> data, 
    String where, 
    List<dynamic> whereArgs
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteRecord(
    String table, 
    String where, 
    List<dynamic> whereArgs
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Método para obtener estadísticas básicas
  Future<Map<String, int>> getBasicStats() async {
    final db = await database;
    
    final productosCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM productos WHERE activo = 1')
    ) ?? 0;
    
    final lotesActivos = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM lotes WHERE activo = 1 AND cantidad_actual > 0')
    ) ?? 0;
    
    final stockBajo = Sqflite.firstIntValue(
      await db.rawQuery('''
        SELECT COUNT(*) FROM productos p 
        LEFT JOIN (
          SELECT producto_id, SUM(cantidad_actual) as total_stock 
          FROM lotes WHERE activo = 1 
          GROUP BY producto_id
        ) l ON p.id = l.producto_id
        WHERE p.activo = 1 AND COALESCE(l.total_stock, 0) <= COALESCE(p.stock_minimo, 0)
      ''')
    ) ?? 0;
    
    return {
      'productos': productosCount,
      'lotes_activos': lotesActivos,
      'stock_bajo': stockBajo,
    };
  }

  // Método para cerrar la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Método para eliminar la base de datos (solo para desarrollo)
  Future<void> deleteDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('🗑️ Base de datos eliminada');
  }

  // Método para resetear la base de datos (útil para desarrollo)
  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase();
    _database = null;
    _database = await _initDatabase();
    print('Base de datos reseteada');
  }
}