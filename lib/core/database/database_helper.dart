// lib/core/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'tienda_control.db';
  static const int _databaseVersion = 2; // ⬆️ INCREMENTAMOS LA VERSIÓN

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
    // Crear tabla de categorías
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        descripcion TEXT,
        fecha_creacion TEXT
      )
    ''');

    await db.execute('''
  CREATE TABLE movimientos_inventario (
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

    await db.execute(
      'CREATE INDEX idx_movimientos_producto ON movimientos_inventario (producto_id)',
    );
    await db.execute(
      'CREATE INDEX idx_movimientos_lote ON movimientos_inventario (lote_id)',
    );
    await db.execute(
      'CREATE INDEX idx_movimientos_fecha ON movimientos_inventario (fecha_movimiento)',
    );

    // Crear tabla de productos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        categoria_id INTEGER,
        codigo_interno TEXT UNIQUE,
        codigo_barras TEXT,
        precio_compra REAL DEFAULT 0,
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
        precio_compra_lote REAL,
        activo INTEGER DEFAULT 1,
        notas TEXT,
        FOREIGN KEY (producto_id) REFERENCES productos (id)
      )
    ''');

    // Crear tabla de ventas - CON TODAS LAS COLUMNAS CORRECTAS
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
        cliente TEXT,
        vendedor TEXT,
        notas TEXT,
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
        lote_id INTEGER NOT NULL,
        tipo_movimiento TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        motivo TEXT,
        usuario TEXT,
        fecha_movimiento TEXT NOT NULL,
        precio_unitario REAL,
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
        'nombre': 'Abarrotes',
        'descripcion': 'Productos básicos de alimentación',
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
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
    }

    // Insertar ventas de ejemplo
    await _insertSampleData(db);
    print('✅ Datos iniciales insertados correctamente');
  }

  Future<void> _insertSampleData(Database db) async {
    // Insertar algunas ventas de ejemplo para que el dashboard tenga datos
    final ventasEjemplo = [
      {
        'numero_venta': 'V-000001',
        'fecha_venta':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'subtotal': 15000.0,
        'descuento': 0.0,
        'impuestos': 0.0,
        'total': 15000.0,
        'metodo_pago': 'Efectivo',
        'cliente': 'Cliente general',
        'vendedor': 'Sistema',
        'recibo_enviado': 0,
        'activo': 1,
      },
      {
        'numero_venta': 'V-000002',
        'fecha_venta':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'subtotal': 25000.0,
        'descuento': 0.0,
        'impuestos': 0.0,
        'total': 25000.0,
        'metodo_pago': 'Tarjeta',
        'cliente': 'Cliente general',
        'vendedor': 'Sistema',
        'recibo_enviado': 0,
        'activo': 1,
      },
      {
        'numero_venta': 'V-000003',
        'fecha_venta': DateTime.now().toIso8601String(),
        'subtotal': 12000.0,
        'descuento': 0.0,
        'impuestos': 0.0,
        'total': 12000.0,
        'metodo_pago': 'Efectivo',
        'cliente': 'Cliente general',
        'vendedor': 'Sistema',
        'recibo_enviado': 0,
        'activo': 1,
      },
    ];

    for (var venta in ventasEjemplo) {
      await db.insert('ventas', venta);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Actualizando base de datos de versión $oldVersion a $newVersion');

    if (oldVersion < 2) {
      // Agregar columna recibo_enviado si no existe
      try {
        await db.execute(
          'ALTER TABLE ventas ADD COLUMN recibo_enviado INTEGER DEFAULT 0',
        );
        print('✅ Columna recibo_enviado agregada a tabla ventas');
      } catch (e) {
        print('ℹ️ Columna recibo_enviado ya existe o error: $e');
      }
    }

    print('✅ Actualización de base de datos completada');
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

      // Ventas recientes - CONSULTA CORREGIDA
      final ventasRecientesResult = await db.rawQuery('''
        SELECT numero_venta, total, fecha_venta, recibo_enviado
        FROM ventas
        WHERE activo = 1
        ORDER BY fecha_venta DESC
        LIMIT 5
      ''');

      final result = {
        'ventasHoy': ventasHoyResult.first['ventas_hoy'],
        'cantidadVentasHoy': ventasHoyResult.first['cantidad_ventas_hoy'],
        'totalProductos': productosResult.first['total_productos'],
        'productosStockBajo': stockBajoResult.first['productos_stock_bajo'],
        'ventasRecientes': ventasRecientesResult,
      };

      return result;
    } catch (e) {
      print('❌ Error getting dashboard stats: $e');
      return {
        'ventasHoy': 0,
        'cantidadVentasHoy': 0,
        'totalProductos': 0,
        'productosStockBajo': 0,
        'ventasRecientes': [],
      };
    }
  }

  // Método para verificar y reparar la base de datos
  Future<bool> verifyAndRepairDatabase() async {
    try {
      final db = await database;

      // Verificar si la tabla ventas tiene la columna recibo_enviado
      final tableInfo = await db.rawQuery("PRAGMA table_info(ventas)");
      bool tieneReciboEnviado = tableInfo.any(
        (column) => column['name'] == 'recibo_enviado',
      );

      if (!tieneReciboEnviado) {
        print('🔧 Reparando base de datos: agregando columna faltante');
        await db.execute(
          'ALTER TABLE ventas ADD COLUMN recibo_enviado INTEGER DEFAULT 0',
        );
        print('✅ Base de datos reparada exitosamente');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error verificando base de datos: $e');
      return false;
    }
  }

  // Método para obtener información de la base de datos
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;

    final productCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM productos WHERE activo = 1',
    );
    final categoryCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categorias',
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

  // Método para cerrar la base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}