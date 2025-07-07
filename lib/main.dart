// lib/main.dart - CON CURRENCY PROVIDER AGREGADO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/products/providers/products_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/currency_provider.dart'; // ✅ NUEVO IMPORT
import 'core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar la base de datos al inicio
  final databaseHelper = DatabaseHelper();
  try {
    await databaseHelper.database;
    print('✅ Base de datos inicializada correctamente');
    
    // Verificar y reparar si es necesario
    final wasRepaired = await databaseHelper.verifyAndRepairDatabase();
    if (wasRepaired) {
      print('🔧 Base de datos reparada exitosamente');
    }
  } catch (e) {
    print('❌ Error inicializando base de datos: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider de idioma - cargar primero y eager
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
          lazy: false,
        ),
        
        // ✅ AGREGAR CURRENCY PROVIDER AQUÍ
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(),
          lazy: false,
        ),
        
        // Provider de dashboard
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
          lazy: true,
        ),
        
        // Provider de productos
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
          lazy: true,
        ),
        
        // Provider de inventario
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(),
          lazy: true,
        ),
      ],
      child: const TiendaControlApp(),
    );
  }
}