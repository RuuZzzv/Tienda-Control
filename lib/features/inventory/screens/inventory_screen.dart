// lib/features/inventory/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_provider.dart';
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart';
import '../widgets/product_inventory_card.dart';
import '../widgets/lote_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentView = 'productos'; // 'productos', 'stock_bajo', 'vencidos', 'por_vencer'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventoryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Mi Inventario',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 28),
            onPressed: () => _showAddLoteDialog(context),
            tooltip: 'Agregar Stock',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: () => context.read<InventoryProvider>().refresh(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 8,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Cargando inventario...',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return Column(
            children: [
              // Resumen principal - Cards grandes y simples
              _buildMainSummary(provider),
              
              // Navegación por categorías
              _buildCategoryNavigation(provider),
              
              // Lista de productos/lotes según la vista actual
              Expanded(
                child: _buildCurrentView(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(InventoryProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber,
              size: 80,
              color: AppColors.warning,
            ),
            const SizedBox(height: 24),
            const Text(
              'No se pudo cargar el inventario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.clearError();
                  provider.refresh();
                },
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text(
                  'Reintentar',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSummary(InventoryProvider provider) {
    // Calcular estadísticas directamente para evitar errores
    final totalProductos = provider.products.length;
    final productosStockBajo = provider.products.where((p) => 
      (p.stockActual ?? 0) <= (p.stockMinimo ?? 0)
    ).length;
    final lotesVencidos = provider.lotes.where((l) => 
      l.fechaVencimiento != null && 
      DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.cantidadActual > 0
    ).length;
    final lotesProximosVencer = provider.lotes.where((l) => 
      l.fechaVencimiento != null && 
      !DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.fechaVencimiento!.difference(DateTime.now()).inDays <= 7 &&
      l.cantidadActual > 0
    ).length;
    
    return Container(
      padding: const EdgeInsets.all(8), // Padding muy reducido
      child: Column(
        children: [
          // Título de sección más compacto
          const Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 18),
              SizedBox(width: 4),
              Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Cards principales - 2x2 con diseño compacto
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  title: 'Productos',
                  value: '$totalProductos',
                  icon: Icons.inventory_2,
                  color: AppColors.info,
                  isGood: true,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _BigStatCard(
                  title: 'Stock Bajo',
                  value: '$productosStockBajo',
                  icon: Icons.warning,
                  color: AppColors.warning,
                  isGood: productosStockBajo == 0,
                  onTap: () => _changeView('stock_bajo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  title: 'Vencidos',
                  value: '$lotesVencidos',
                  icon: Icons.dangerous,
                  color: AppColors.error,
                  isGood: lotesVencidos == 0,
                  onTap: () => _changeView('vencidos'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _BigStatCard(
                  title: 'Por Vencer',
                  value: '$lotesProximosVencer',
                  icon: Icons.schedule,
                  color: AppColors.accent,
                  isGood: lotesProximosVencer == 0,
                  onTap: () => _changeView('por_vencer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryNavigation(InventoryProvider provider) {
    // Calcular estadísticas para los badges
    final productosStockBajo = provider.products.where((p) => 
      (p.stockActual ?? 0) <= (p.stockMinimo ?? 0)
    ).length;
    final lotesVencidos = provider.lotes.where((l) => 
      l.fechaVencimiento != null && 
      DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.cantidadActual > 0
    ).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de búsqueda integrada - sin Container extra
          SizedBox(
            height: 32,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search, size: 14, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.divider, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.divider, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 11),
              onChanged: (value) {
                // TODO: Implementar búsqueda
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Navegación por pestañas compactas
          Row(
            children: [
              Expanded(
                child: _CategoryButton(
                  label: 'Todos',
                  icon: Icons.list_alt,
                  isSelected: _currentView == 'productos',
                  onTap: () => _changeView('productos'),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _CategoryButton(
                  label: 'Stock Bajo',
                  icon: Icons.warning,
                  isSelected: _currentView == 'stock_bajo',
                  onTap: () => _changeView('stock_bajo'),
                  badgeCount: productosStockBajo,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: _CategoryButton(
                  label: 'Vencidos',
                  icon: Icons.dangerous,
                  isSelected: _currentView == 'vencidos',
                  onTap: () => _changeView('vencidos'),
                  badgeCount: lotesVencidos,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(InventoryProvider provider) {
    switch (_currentView) {
      case 'productos':
        return _buildAllProductsList(provider);
      case 'stock_bajo':
        return _buildLowStockList(provider);
      case 'vencidos':
        return _buildExpiredList(provider);
      case 'por_vencer':
        return _buildExpiringList(provider);
      default:
        return _buildAllProductsList(provider);
    }
  }

  Widget _buildAllProductsList(InventoryProvider provider) {
    final products = provider.products;
    
    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No hay productos',
        subtitle: 'Agrega productos a tu inventario para comenzar',
        actionLabel: 'Agregar Producto',
        onAction: () => context.push('/add-product'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _SimpleProductCard(
            product: products[index],
            onTap: () => _showProductDetails(products[index], provider),
            onAddStock: () => _showAddLoteDialog(context, products[index]),
          );
        },
      ),
    );
  }

  Widget _buildLowStockList(InventoryProvider provider) {
    final products = provider.products.where((p) => 
      (p.stockActual ?? 0) <= (p.stockMinimo ?? 0)
    ).toList();
    
    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: '¡Excelente!',
        subtitle: 'Todos tus productos tienen stock suficiente',
        actionLabel: 'Ver Todos los Productos',
        onAction: () => _changeView('productos'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: AppColors.warning, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estos productos necesitan reposición urgente',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _SimpleProductCard(
                  product: products[index],
                  onTap: () => _showProductDetails(products[index], provider),
                  onAddStock: () => _showAddLoteDialog(context, products[index]),
                  showUrgentBadge: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredList(InventoryProvider provider) {
    final expiredLotes = provider.lotes.where((l) => 
      l.fechaVencimiento != null && 
      DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.cantidadActual > 0
    ).toList();
    
    if (expiredLotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: '¡Perfecto!',
        subtitle: 'No tienes productos vencidos',
        actionLabel: 'Ver Inventario',
        onAction: () => _changeView('productos'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                const Icon(Icons.dangerous, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Productos vencidos - Retirar de la venta',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: expiredLotes.length,
              itemBuilder: (context, index) {
                return _SimpleLoteCard(
                  lote: expiredLotes[index],
                  onTap: () => _showLoteDetails(expiredLotes[index], provider),
                  showExpiredBadge: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringList(InventoryProvider provider) {
    final expiringLotes = provider.lotes.where((l) => 
      l.fechaVencimiento != null && 
      !DateTime.now().isAfter(l.fechaVencimiento!) &&
      l.fechaVencimiento!.difference(DateTime.now()).inDays <= 7 &&
      l.cantidadActual > 0
    ).toList();
    
    if (expiringLotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: '¡Todo bien!',
        subtitle: 'No tienes productos próximos a vencer',
        actionLabel: 'Ver Inventario',
        onAction: () => _changeView('productos'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: AppColors.accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Productos que vencen pronto - Ofertar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: expiringLotes.length,
              itemBuilder: (context, index) {
                return _SimpleLoteCard(
                  lote: expiringLotes[index],
                  onTap: () => _showLoteDetails(expiringLotes[index], provider),
                  showExpiringBadge: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _changeView(String view) {
    setState(() {
      _currentView = view;
    });
  }

  void _showAddLoteDialog(BuildContext context, [Product? product]) {
    context.push('/add-lote', extra: product);
  }

  void _showProductDetails(Product product, InventoryProvider provider) {
    final lotes = provider.getLotesForProduct(product.id!);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _DetailChip(
                          label: 'Stock Total',
                          value: '${product.stockActual ?? 0}',
                          color: (product.stockActual ?? 0) <= (product.stockMinimo ?? 0) 
                              ? AppColors.warning 
                              : AppColors.success,
                        ),
                        _DetailChip(
                          label: 'Stock Mínimo',
                          value: '${product.stockMinimo ?? 0}',
                          color: AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Lotes
              Expanded(
                child: lotes.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay lotes registrados',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: lotes.length,
                        itemBuilder: (context, index) {
                          return _SimpleLoteCard(
                            lote: lotes[index],
                            onTap: () => _showLoteDetails(lotes[index], provider),
                            showProductName: false,
                          );
                        },
                      ),
              ),
              
              // Botón agregar stock
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddLoteDialog(context, product);
                    },
                    icon: const Icon(Icons.add_circle, size: 24),
                    label: const Text(
                      'Agregar Stock',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoteDetails(Lote lote, InventoryProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente: Detalles del lote'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Widget para las cards de estadísticas principales
class _BigStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isGood;
  final VoidCallback? onTap;

  const _BigStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isGood,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(6),
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fila con icono y flecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 18, color: color),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textTertiary),
                ],
              ),
              // Número grande
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isGood ? AppColors.success : color,
                ),
              ),
              // Título en una sola línea y más pequeño
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
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

// Widget para botones de categoría
class _CategoryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  const _CategoryButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget simplificado para productos
class _SimpleProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddStock;
  final bool showUrgentBadge;

  const _SimpleProductCard({
    required this.product,
    required this.onTap,
    required this.onAddStock,
    this.showUrgentBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final stockActual = product.stockActual ?? 0;
    final stockMinimo = product.stockMinimo ?? 0;
    final isLowStock = stockActual <= stockMinimo;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del producto
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isLowStock ? AppColors.warning.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 32,
                  color: isLowStock ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (showUrgentBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'URGENTE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Stock: ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '$stockActual',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isLowStock ? AppColors.warning : AppColors.success,
                          ),
                        ),
                        Text(
                          ' / Mín: $stockMinimo',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Botón agregar stock
              Column(
                children: [
                  IconButton(
                    onPressed: onAddStock,
                    icon: const Icon(Icons.add_circle),
                    color: AppColors.primary,
                    iconSize: 32,
                  ),
                  const Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

// Widget simplificado para lotes
class _SimpleLoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback onTap;
  final bool showProductName;
  final bool showExpiredBadge;
  final bool showExpiringBadge;

  const _SimpleLoteCard({
    required this.lote,
    required this.onTap,
    this.showProductName = true,
    this.showExpiredBadge = false,
    this.showExpiringBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = lote.fechaVencimiento != null && DateTime.now().isAfter(lote.fechaVencimiento!);
    final isExpiring = lote.fechaVencimiento != null && 
                      !isExpired && 
                      lote.fechaVencimiento!.difference(DateTime.now()).inDays <= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del lote
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isExpired 
                      ? AppColors.error.withOpacity(0.1)
                      : isExpiring
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.batch_prediction,
                  size: 28,
                  color: isExpired 
                      ? AppColors.error
                      : isExpiring
                          ? AppColors.warning
                          : AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del lote
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showProductName) ...[
                      Text(
                        lote.productoNombre ?? 'Producto',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'Lote: ${lote.numeroLote ?? lote.codigoLoteInterno ?? 'Sin número'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${lote.cantidadActual}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (lote.fechaVencimiento != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        isExpired 
                            ? 'Vencido el ${_formatDate(lote.fechaVencimiento!)}'
                            : isExpiring
                                ? 'Vence en ${lote.fechaVencimiento!.difference(DateTime.now()).inDays} días'
                                : 'Vence: ${_formatDate(lote.fechaVencimiento!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isExpired 
                              ? AppColors.error
                              : isExpiring
                                  ? AppColors.warning
                                  : AppColors.textTertiary,
                          fontWeight: (isExpired || isExpiring) ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Badge de estado
              if (showExpiredBadge || showExpiringBadge || isExpired || isExpiring)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExpired || showExpiredBadge
                        ? AppColors.error
                        : AppColors.warning,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isExpired || showExpiredBadge ? 'VENCIDO' : 'POR VENCER',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Widget para chips de detalle
class _DetailChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}