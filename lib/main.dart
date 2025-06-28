import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/products/providers/products_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'core/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optimización: Cargar solo lo necesario al inicio
  final languageProvider = LanguageProvider();
  
  // Cargar idioma en paralelo mientras se inicia la app
  final loadLanguageFuture = languageProvider.loadSavedLanguage();
  
  runApp(MyApp(
    languageProvider: languageProvider,
    loadLanguageFuture: loadLanguageFuture,
  ));
}

class MyApp extends StatelessWidget {
  final LanguageProvider languageProvider;
  final Future<void> loadLanguageFuture;
  
  const MyApp({
    super.key, 
    required this.languageProvider,
    required this.loadLanguageFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadLanguageFuture,
      builder: (context, snapshot) {
        // Mostrar splash mientras carga
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        return MultiProvider(
          providers: [
            // Lazy loading de providers - solo se crean cuando se necesitan
            ChangeNotifierProvider(
              create: (_) => DashboardProvider(),
              lazy: true,
            ),
            ChangeNotifierProvider(
              create: (_) => ProductsProvider(),
              lazy: true,
            ),
            ChangeNotifierProvider(
              create: (_) => InventoryProvider(),
              lazy: true,
            ),
            ChangeNotifierProvider.value(value: languageProvider),
          ],
          child: const TiendaControlApp(),
        );
      },
    );
  }
}