import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_sizes.dart';
import 'core/widgets/main_scaffold.dart';
import 'features/products/models/product.dart';

// Lazy imports para mejorar tiempo de carga inicial
import 'features/dashboard/screens/dashboard_screen.dart' deferred as dashboard;
import 'features/products/screens/products_list_screen.dart' deferred as products_list;
import 'features/products/screens/add_product_screen.dart' deferred as add_product;
import 'features/products/screens/edit_product_screen.dart' deferred as edit_product;
import 'features/inventory/screens/add_lote_screen.dart' deferred as add_lote;
import 'features/sales/screens/pos_screen.dart' deferred as pos;
import 'features/inventory/screens/inventory_screen.dart' deferred as inventory;
import 'features/reports/screens/reports_screen.dart' deferred as reports;

class TiendaControlApp extends StatelessWidget {
  const TiendaControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tienda Control',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router,
    );
  }
  
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.background,
      ),
      useMaterial3: true,
      // Optimización: Usar fuentes del sistema por defecto
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: AppSizes.textDisplay, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: AppSizes.textXXL, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: AppSizes.textXL, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: AppSizes.textL, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: AppSizes.textL, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: AppSizes.textM),
        bodyMedium: TextStyle(fontSize: AppSizes.textM),
        labelLarge: TextStyle(fontSize: AppSizes.textM, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(AppSizes.buttonMinWidth, AppSizes.buttonHeight),
          textStyle: const TextStyle(fontSize: AppSizes.textL, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.containerRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),
        labelStyle: const TextStyle(fontSize: AppSizes.textL),
        hintStyle: const TextStyle(fontSize: AppSizes.textL, color: AppColors.textTertiary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}

// Widget de carga para lazy loading
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Helpers para lazy loading
Future<Widget> _loadDashboard() async {
  await dashboard.loadLibrary();
  return dashboard.DashboardScreen();
}

Future<Widget> _loadProductsList() async {
  await products_list.loadLibrary();
  return products_list.ProductsListScreen();
}

Future<Widget> _loadPOS() async {
  await pos.loadLibrary();
  return pos.POSScreen();
}

Future<Widget> _loadInventory() async {
  await inventory.loadLibrary();
  return inventory.InventoryScreen();
}

Future<Widget> _loadReports() async {
  await reports.loadLibrary();
  return reports.ReportsScreen();
}

Future<Widget> _loadAddProduct() async {
  await add_product.loadLibrary();
  return add_product.AddProductScreen();
}

Future<Widget> _loadEditProduct(Product product) async {
  await edit_product.loadLibrary();
  return edit_product.EditProductScreen(product: product);
}

Future<Widget> _loadAddLote(Product? product) async {
  await add_lote.loadLibrary();
  return add_lote.AddLoteScreen(preselectedProduct: product);
}

final GoRouter _router = GoRouter(
  initialLocation: '/dashboard',
  // Optimización: Usar caché de rutas
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        String currentLocation = state.uri.path;
        
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
          builder: (context, state) => FutureBuilder<Widget>(
            future: _loadDashboard(),
            builder: (context, snapshot) {
              if (snapshot.hasData) return snapshot.data!;
              return const LoadingScreen();
            },
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => FutureBuilder<Widget>(
            future: _loadProductsList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) return snapshot.data!;
              return const LoadingScreen();
            },
          ),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => FutureBuilder<Widget>(
            future: _loadPOS(),
            builder: (context, snapshot) {
              if (snapshot.hasData) return snapshot.data!;
              return const LoadingScreen();
            },
          ),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => FutureBuilder<Widget>(
            future: _loadInventory(),
            builder: (context, snapshot) {
              if (snapshot.hasData) return snapshot.data!;
              return const LoadingScreen();
            },
          ),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => FutureBuilder<Widget>(
            future: _loadReports(),
            builder: (context, snapshot) {
              if (snapshot.hasData) return snapshot.data!;
              return const LoadingScreen();
            },
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => FutureBuilder<Widget>(
        future: _loadAddProduct(),
        builder: (context, snapshot) {
          if (snapshot.hasData) return snapshot.data!;
          return const LoadingScreen();
        },
      ),
    ),
    GoRoute(
      path: '/edit-product',
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product == null) {
          return FutureBuilder<Widget>(
            future: _loadProductsList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) return snapshot.data!;
              return const LoadingScreen();
            },
          );
        }
        return FutureBuilder<Widget>(
          future: _loadEditProduct(product),
          builder: (context, snapshot) {
            if (snapshot.hasData) return snapshot.data!;
            return const LoadingScreen();
          },
        );
      },
    ),
    GoRoute(
      path: '/add-lote',
      builder: (context, state) {
        final product = state.extra as Product?;
        return FutureBuilder<Widget>(
          future: _loadAddLote(product),
          builder: (context, snapshot) {
            if (snapshot.hasData) return snapshot.data!;
            return const LoadingScreen();
          },
        );
      },
    ),
  ],
);