import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_sizes.dart';
import 'core/widgets/main_scaffold.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/products/screens/products_list_screen.dart';
import 'features/products/screens/add_product_screen.dart';
import 'features/products/screens/edit_product_screen.dart';
import 'features/products/models/product.dart';
import 'features/inventory/screens/add_lote_screen.dart';
import 'features/sales/screens/pos_screen.dart';
import 'features/inventory/screens/inventory_screen.dart';
import 'features/reports/screens/reports_screen.dart';

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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // Usar transiciones más simples para mejor performance
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
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

final GoRouter _router = GoRouter(
  initialLocation: '/dashboard',
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
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsListScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => const POSScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/edit-product',
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product == null) {
          return const ProductsListScreen();
        }
        return EditProductScreen(product: product);
      },
    ),
    GoRoute(
      path: '/add-lote',
      builder: (context, state) {
        final product = state.extra as Product?;
        return AddLoteScreen(preselectedProduct: product);
      },
    ),
  ],
);