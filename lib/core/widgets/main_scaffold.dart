// lib/core/widgets/main_scaffold.dart - FAB Y NAVEGACIÓN OPTIMIZADOS
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../features/products/providers/products_provider.dart';
import '../../features/inventory/providers/inventory_provider.dart';

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
    } else if (widget.location.startsWith('/inventory')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index) {
    // Guardar la ubicación anterior
    _previousLocation = widget.location;

    switch (index) {
      case 0:
        context.go('/dashboard');
        // Auto-refrescar providers cuando navegas al dashboard
        _refreshProvidersIfNeeded('/dashboard');
        break;
      case 1:
        context.go('/products');
        break;
      case 2:
        context.go('/inventory');
        break;
    }
  }

  // Refrescar providers automáticamente cuando sea necesario
  void _refreshProvidersIfNeeded(String newLocation) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && newLocation.startsWith('/dashboard')) {
        // Refrescar si venimos de productos o inventario (donde pudimos agregar algo)
        if (_previousLocation.startsWith('/products') ||
            _previousLocation.startsWith('/add-product') ||
            _previousLocation.startsWith('/inventory') ||
            _previousLocation.startsWith('/add-lote')) {
          print('🔄 Auto-refrescando datos después de cambios...');

          final productsProvider = context.read<ProductsProvider>();
          final inventoryProvider = context.read<InventoryProvider>();

          productsProvider.refresh();
          inventoryProvider.refresh();
        }
      }
    });
  }

  @override
  void didUpdateWidget(MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar cambios de ubicación
    if (oldWidget.location != widget.location) {
      _refreshProvidersIfNeeded(widget.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNavigation(context),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ✅ NAVEGACIÓN BOTTOM OPTIMIZADA
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6, // ✅ REDUCIDO de 8 a 6
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60, // ✅ REDUCIDO de 65 a 60
          margin: const EdgeInsets.only(
            left: 12, // ✅ REDUCIDO de 16 a 12
            right: 12,
            top: 6, // ✅ REDUCIDO de 8 a 6
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // ✅ REDUCIDO de 16 a 12
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CompactNavBarItem(
                icon: widget.location == '/dashboard'
                    ? Icons.dashboard
                    : Icons.dashboard_outlined,
                label: 'Inicio',
                isSelected: widget.location == '/dashboard',
                onTap: () => _onItemTapped(0),
              ),
              _CompactNavBarItem(
                icon: widget.location.startsWith('/products')
                    ? Icons.inventory_2
                    : Icons.inventory_2_outlined,
                label: 'Productos',
                isSelected: widget.location.startsWith('/products'),
                onTap: () => _onItemTapped(1),
              ),
              const SizedBox(width: 50), // ✅ REDUCIDO de 56 a 50 para FAB
              _CompactNavBarItem(
                icon: widget.location.startsWith('/inventory')
                    ? Icons.warehouse
                    : Icons.warehouse_outlined,
                label: 'Inventario',
                isSelected: widget.location.startsWith('/inventory'),
                onTap: () => _onItemTapped(2),
              ),
              _CompactNavBarItem(
                icon: Icons.more_horiz,
                label: 'Más',
                isSelected: false,
                onTap: () => _showMoreOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FAB OPTIMIZADO Y MEJOR POSICIONADO
  Widget _buildFloatingActionButton(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: bottomPadding > 0 ? bottomPadding + 4 : 10, // ✅ AJUSTE DINÁMICO
      ),
      child: FloatingActionButton(
        onPressed: () => _showQuickActionsSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8, // ✅ INCREMENTADO de 6 a 8 para más prominencia
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // ✅ MÁS REDONDEADO
        ),
        child: const Icon(Icons.add, size: 28), // ✅ INCREMENTADO de 24 a 28
      ),
    );
  }

  // ✅ MODAL DE ACCIONES OPTIMIZADO
  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6, // ✅ REDUCIDO de 0.7 a 0.6
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), // ✅ REDUCIDO de 24 a 20
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16), // ✅ REDUCIDO de 20 a 16
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar más pequeño
                Container(
                  width: 40, // ✅ REDUCIDO de 50 a 40
                  height: 4, // ✅ REDUCIDO de 5 a 4
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16), // ✅ REDUCIDO de 20 a 16

                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 18, // ✅ REDUCIDO de 20 a 18
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16), // ✅ REDUCIDO de 20 a 16

                // ✅ BOTONES MÁS COMPACTOS
                _buildCompactActionButton(
                  context: context,
                  icon: Icons.add_circle,
                  label: 'Agregar Producto',
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/add-product');
                  },
                ),

                const SizedBox(height: 8), // ✅ REDUCIDO de 10 a 8

                _buildCompactActionButton(
                  context: context,
                  icon: Icons.add_box,
                  label: 'Agregar Stock',
                  color: AppColors.success,
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/add-lote');
                  },
                ),

                const SizedBox(height: 8), // ✅ REDUCIDO de 12 a 8
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FUNCIÓN HELPER PARA BOTONES COMPACTOS
  Widget _buildCompactActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 48, // ✅ ALTURA FIJA COMPACTA
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22), // ✅ REDUCIDO de 24 a 22
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15, // ✅ REDUCIDO de 16 a 15
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // ✅ REDUCIDO de 12 a 10
          ),
        ),
      ),
    );
  }

  // ✅ MODAL MÁS OPTIMIZADO TAMBIÉN
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7, // ✅ REDUCIDO de 0.8 a 0.7
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16), // ✅ REDUCIDO de 20 a 16
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Opciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ OPCIONES MÁS COMPACTAS
                _buildCompactListTile(
                  icon: Icons.refresh,
                  color: AppColors.info,
                  title: 'Actualizar Datos',
                  subtitle: 'Refrescar información de productos e inventario',
                  onTap: () {
                    Navigator.pop(context);
                    _refreshAllData(context);
                  },
                ),

                _buildCompactListTile(
                  icon: Icons.analytics,
                  color: AppColors.accent,
                  title: 'Ver Estadísticas',
                  subtitle: 'Resumen de inventario y alertas',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),

                _buildCompactListTile(
                  icon: Icons.info,
                  color: AppColors.primary,
                  title: 'Acerca de',
                  subtitle: 'Información de la aplicación',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),

                const SizedBox(height: 8), // ✅ REDUCIDO de 12 a 8
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FUNCIÓN HELPER PARA LIST TILES COMPACTOS
  Widget _buildCompactListTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // ✅ ESPACIADO REDUCIDO
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // ✅ REDUCIDO
        leading: Container(
          padding: const EdgeInsets.all(6), // ✅ REDUCIDO de 8 a 6
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6), // ✅ REDUCIDO de 8 a 6
          ),
          child: Icon(
            icon,
            color: color,
            size: 20, // ✅ REDUCIDO de 24 a 20
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15, // ✅ REDUCIDO de 16 a 15
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13, // ✅ REDUCIDO de 14 a 13
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _refreshAllData(BuildContext context) {
    try {
      final productsProvider = context.read<ProductsProvider>();
      final inventoryProvider = context.read<InventoryProvider>();

      productsProvider.refresh();
      inventoryProvider.refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Datos actualizados correctamente'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error al actualizar datos'),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.inventory_2, color: AppColors.primary, size: 28), // ✅ REDUCIDO
            SizedBox(width: 10), // ✅ REDUCIDO
            Flexible(
              child: Text(
                'Mi Inventario',
                style: TextStyle(fontSize: 18), // ✅ REDUCIDO
              ),
            ),
          ],
        ),
        content: const Text(
          'Aplicación para gestión de inventario y control de stock.\n\n'
          'Versión 1.0.0\n\n'
          'Diseñada especialmente para facilitar el control y seguimiento de productos, '
          'con una interfaz simple y accesible.',
          style: TextStyle(fontSize: 14, height: 1.4), // ✅ REDUCIDO
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontSize: 15), // ✅ REDUCIDO
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ NUEVO WIDGET NAVBAR COMPACTO
class _CompactNavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactNavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 60, // ✅ ALTURA CONSISTENTE
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10), // ✅ REDUCIDO
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22, // ✅ REDUCIDO de 24 a 22
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 3), // ✅ REDUCIDO de 4 a 3
              Text(
                label,
                style: TextStyle(
                  fontSize: 11, // ✅ REDUCIDO de 12 a 11
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}