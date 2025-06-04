// lib/core/widgets/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../features/dashboard/providers/dashboard_provider.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  String _previousLocation = '';

  int _getCurrentIndex() {
    if (widget.location.startsWith('/dashboard') || widget.location == '/') {
      return 0;
    } else if (widget.location.startsWith('/products')) {
      return 1;
    } else if (widget.location.startsWith('/pos')) {
      return 2;
    } else if (widget.location.startsWith('/inventory')) {
      return 3;
    } else if (widget.location.startsWith('/reports')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index) {
    // Guardar la ubicación anterior
    _previousLocation = widget.location;
    
    switch (index) {
      case 0:
        context.go('/dashboard');
        // Auto-refrescar dashboard cuando navegas hacia él
        _refreshDashboardIfNeeded('/dashboard');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/pos');
        break;
      case 3:
        context.go('/inventory');
        break;
      case 4:
        context.go('/reports');
        break;
    }
  }

  // Refrescar dashboard automáticamente cuando sea necesario
  void _refreshDashboardIfNeeded(String newLocation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && newLocation.startsWith('/dashboard')) {
        // Refrescar si venimos de productos (donde pudimos agregar algo)
        if (_previousLocation.startsWith('/products') || 
            _previousLocation.startsWith('/add-product')) {
          print('🔄 Auto-refrescando dashboard después de venir de productos...');
          context.read<DashboardProvider>().forceReload();
        }
      }
    });
  }

  @override
  void didUpdateWidget(MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detectar cambios de ubicación
    if (oldWidget.location != widget.location) {
      _refreshDashboardIfNeeded(widget.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(),
        onTap: _onItemTapped,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedFontSize: AppSizes.textS,
        unselectedFontSize: AppSizes.textS,
        iconSize: AppSizes.iconM,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            activeIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse_outlined),
            activeIcon: Icon(Icons.warehouse),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}