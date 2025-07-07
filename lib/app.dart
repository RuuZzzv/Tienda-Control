// lib/app.dart - CON RUTA DE EDIT PRODUCT CORREGIDA
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/widgets/main_scaffold.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/products/screens/products_list_screen.dart';
import 'features/products/models/product.dart';
import 'features/products/providers/products_provider.dart';
import 'features/inventory/screens/add_lote_screen.dart';
import 'features/inventory/screens/inventory_screen.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'core/providers/language_provider.dart';

// ✅ IMPORTS CORREGIDOS - YA NO TEMPORALES
import 'features/products/screens/add_product_screen.dart' as add_screen;
import 'features/products/screens/edit_product_screen.dart' as edit_screen; // ✅ DESCOMENTADO

class TiendaControlApp extends StatelessWidget {
  const TiendaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp.router(
          title: 'Mi Inventario',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          routerConfig: _router,
          
          // Configuración de localización
          locale: Locale(languageProvider.currentLanguage),
          
          // Builder para mejorar accesibilidad
          builder: (context, child) {
            return MediaQuery(
              // Texto optimizado para legibilidad
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
  
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.background,
      ),
      
      // Configuración de texto optimizada
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      
      // AppBar theme optimizado
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // Elevated button theme optimizado
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          minimumSize: const Size(100, 44),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
      ),
      
      // Outlined button theme optimizado
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(100, 44),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
      ),
      
      // Input decoration theme optimizado
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
      ),
      
      // Card theme optimizado
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        color: AppColors.cardBackground,
      ),
      
      // FAB theme optimizado
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // Chip theme optimizado
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // SnackBar theme optimizado
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
      ),
      
      // ListTile theme agregado para consistencia
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        dense: true,
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      
      // Dialog theme agregado
      dialogTheme: const DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

// ✅ ROUTER COMPLETO CON TODAS LAS RUTAS
final GoRouter _router = GoRouter(
  initialLocation: '/dashboard',
  debugLogDiagnostics: false,
  routes: [
    // Rutas principales con scaffold (navegación principal)
    ShellRoute(
      builder: (context, state, child) {
        String currentLocation = state.uri.path;
        
        // Asegurar que los providers estén inicializados
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureProvidersInitialized(context);
        });
        
        return MainScaffold(
          location: currentLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => '/dashboard',
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductsListScreen(),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
      ],
    ),
    
    // ✅ RUTA DE AGREGAR PRODUCTO
    GoRoute(
      path: '/add-product',
      name: 'add-product',
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureProvidersInitialized(context);
        });
        return const add_screen.AddProductScreen();
      },
    ),
    
    // ✅ RUTA DE EDITAR PRODUCTO - AHORA FUNCIONAL
    GoRoute(
      path: '/edit-product/:id',
      name: 'edit-product',
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureProvidersInitialized(context);
        });
        
        final productId = int.tryParse(state.pathParameters['id'] ?? '');
        if (productId == null) {
          return const _ErrorScreen(error: 'ID de producto inválido');
        }
        
        // Buscar el producto en el provider
        final productsProvider = context.read<ProductsProvider>();
        final product = productsProvider.products
            .where((p) => p.id == productId)
            .firstOrNull;
        
        if (product == null) {
          return const _ErrorScreen(error: 'Producto no encontrado');
        }
        
        return edit_screen.EditProductScreen(product: product);
      },
    ),
    
    // ✅ RUTA PARA AGREGAR LOTE
    GoRoute(
      path: '/add-lote',
      name: 'add-lote',
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureProvidersInitialized(context);
        });
        
        final product = state.extra as Product?;
        return AddLoteScreen(preselectedProduct: product);
      },
    ),
  ],
  
  // Manejo de errores mejorado
  errorBuilder: (context, state) => _ErrorScreen(
    error: state.error?.toString() ?? 'Página no encontrada',
  ),
);

// Función helper para inicializar providers
void _ensureProvidersInitialized(BuildContext context) {
  try {
    final productsProvider = context.read<ProductsProvider>();
    final inventoryProvider = context.read<InventoryProvider>();
    
    if (!productsProvider.isInitialized) {
      productsProvider.initializeIfNeeded();
    }
    
    if (!inventoryProvider.isInitialized) {
      inventoryProvider.initializeIfNeeded();
    }
  } catch (e) {
    print('Error al inicializar providers: $e');
  }
}

// Widget mejorado para errores generales
class _ErrorScreen extends StatelessWidget {
  final String error;
  
  const _ErrorScreen({
    this.error = 'Página no encontrada',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Oops! Algo salió mal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/dashboard');
                        }
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Volver'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Inicio'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}