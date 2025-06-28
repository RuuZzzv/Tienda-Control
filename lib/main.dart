import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/products/providers/products_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'core/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NO habilitar esto en producción - causa lag extremo
  // debugPrintRebuildDirtyWidgets = true;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
          lazy: false, // Cargar inmediatamente para debug
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = LanguageProvider();
            provider.loadSavedLanguage(); // No await para no bloquear
            return provider;
          },
          lazy: false,
        ),
      ],
      child: const TiendaControlApp(),
    );
  }
}