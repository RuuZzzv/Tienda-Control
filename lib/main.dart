// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/products/providers/products_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'core/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Crear instancia del provider de idioma y cargar idioma guardado
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();
  
  runApp(MyApp(languageProvider: languageProvider));
}

class MyApp extends StatelessWidget {
  final LanguageProvider languageProvider;
  
  const MyApp({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: const TiendaControlApp(),
    );
  }
}
