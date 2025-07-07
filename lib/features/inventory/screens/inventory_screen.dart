// lib/features/inventory/screens/inventory_screen.dart - IMPORTS CORREGIDOS
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_provider.dart';
import '../../products/providers/products_provider.dart'; // ✅ IMPORT AGREGADO
import '../../products/models/product.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart';
import '../../products/models/product_extensions.dart';
import '../../../core/constants/app_colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().initializeIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: () => context.read<InventoryProvider>().refresh(),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return Column(
            children: [
              _buildSummaryCards(provider),
              _buildSimpleNavigation(provider),
              Expanded(
                child: _buildCurrentView(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 4,
            color: AppColors.primary,
          ),
          SizedBox(height: 20),
          Text(
            'Cargando inventario...',
            style: TextStyle(
              fontSize: 17,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
              size: 70,
              color: AppColors.warning,
            ),
            const SizedBox(height: 20),
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
                fontSize: 15,
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
                icon: const Icon(Icons.refresh, size: 26),
                label: const Text(
                  'Intentar de Nuevo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(InventoryProvider provider) {
    final stats = provider.getInventoryStats();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _ImprovedCard(
                  title: 'Total Productos',
                  value: '${stats['totalProductos']}',
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                  onTap: () => provider.setCurrentFilter('todos'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ImprovedCard(
                  title: 'Con Stock',
                  value: '${stats['productosStock']}',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  onTap: () => provider.setCurrentFilter('todos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _ImprovedCard(
                  title: 'Stock Bajo',
                  value: '${stats['productosStockBajo']}',
                  icon: Icons.warning,
                  color: AppColors.warning,
                  isAlert: (stats['productosStockBajo'] as int) > 0,
                  onTap: () => provider.setCurrentFilter('stock_bajo'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ImprovedCard(
                  title: 'Vencidos',
                  value: '${stats['lotesVencidos']}',
                  icon: Icons.dangerous,
                  color: AppColors.error,
                  isAlert: (stats['lotesVencidos'] as int) > 0,
                  onTap: () => provider.setCurrentFilter('vencidos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleNavigation(InventoryProvider provider) {
    final stats = provider.getInventoryStats();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) => provider.setSearchQuery(value),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: _ImprovedTabButton(
                    label: 'Todos',
                    icon: Icons.list_alt,
                    isSelected: provider.currentFilter == 'todos',
                    onTap: () => provider.setCurrentFilter('todos'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ImprovedTabButton(
                    label: 'Stock Bajo',
                    icon: Icons.warning,
                    isSelected: provider.currentFilter == 'stock_bajo',
                    badgeCount: stats['productosStockBajo'] as int?,
                    onTap: () => provider.setCurrentFilter('stock_bajo'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ImprovedTabButton(
                    label: 'Vencidos',
                    icon: Icons.dangerous,
                    isSelected: provider.currentFilter == 'vencidos',
                    badgeCount: stats['lotesVencidos'] as int?,
                    onTap: () => provider.setCurrentFilter('vencidos'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(InventoryProvider provider) {
    switch (provider.currentFilter) {
      case 'todos':
        return _buildAllProductsList(provider);
      case 'stock_bajo':
        return _buildLowStockList(provider);
      case 'vencidos':
        return _buildExpiredLotesList(provider);
      case 'por_vencer':
        return _buildExpiringLotesList(provider);
      default:
        return _buildAllProductsList(provider);
    }
  }

  Widget _buildAllProductsList(InventoryProvider provider) {
    final products = provider.getFilteredProducts();

    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        title: provider.searchQuery.isNotEmpty
            ? 'No se encontraron productos'
            : 'No hay productos',
        subtitle: provider.searchQuery.isNotEmpty
            ? 'Intenta con otra búsqueda'
            : 'Usa el botón + en la navegación inferior para agregar productos',
        actionLabel:
            provider.searchQuery.isNotEmpty ? 'Limpiar Búsqueda' : null,
        onAction: provider.searchQuery.isNotEmpty
            ? () {
                _searchController.clear();
                provider.setSearchQuery('');
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ImprovedProductCard(
            product: products[index],
            onTap: () => _showProductDetails(products[index], provider),
            onAddStock: () => _showAddLoteDialog(context, products[index]),
          );
        },
      ),
    );
  }

  Widget _buildLowStockList(InventoryProvider provider) {
    final products = provider.getFilteredProducts();

    if (products.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: '¡Excelente!',
        subtitle: 'Todos tus productos tienen stock suficiente',
        actionLabel: 'Ver Todos los Productos',
        onAction: () => provider.setCurrentFilter('todos'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning, width: 2),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning, color: AppColors.warning, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Estos productos necesitan más stock',
                    style: TextStyle(
                      fontSize: 17,
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
                return _ImprovedProductCard(
                  product: products[index],
                  onTap: () => _showProductDetails(products[index], provider),
                  onAddStock: () =>
                      _showAddLoteDialog(context, products[index]),
                  showUrgentBadge: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredLotesList(InventoryProvider provider) {
    final lotes = provider.getFilteredLotes();

    if (lotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: '¡Perfecto!',
        subtitle: 'No tienes productos vencidos',
        actionLabel: 'Ver Inventario',
        onAction: () => provider.setCurrentFilter('todos'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error, width: 2),
            ),
            child: const Row(
              children: [
                Icon(Icons.dangerous, color: AppColors.error, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Productos vencidos - Retirar de la venta',
                    style: TextStyle(
                      fontSize: 17,
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
              itemCount: lotes.length,
              itemBuilder: (context, index) {
                return _ImprovedLoteCard(
                  lote: lotes[index],
                  onTap: () => _showLoteOptions(lotes[index], provider),
                  showExpiredBadge: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringLotesList(InventoryProvider provider) {
    final lotes = provider.expiringLotes;

    if (lotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle,
        title: '¡Todo bien!',
        subtitle: 'No tienes productos próximos a vencer',
        actionLabel: 'Ver Inventario',
        onAction: () => provider.setCurrentFilter('todos'),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lotes.length,
        itemBuilder: (context, index) {
          return _ImprovedLoteCard(
            lote: lotes[index],
            onTap: () => _showLoteOptions(lotes[index], provider),
            showExpiringBadge: true,
          );
        },
      ),
    );
  }

  // ✅ FUNCIÓN COMPLETAMENTE CORREGIDA - SIN OVERFLOW GARANTIZADO
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewPadding.bottom +
            200, // ✅ INCREMENTADO A 200px
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height *
              0.4, // ✅ ALTURA MÍNIMA CONTROLADA
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 60, // ✅ MÁS COMPACTO: 70 → 60
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16), // ✅ REDUCIDO: 20 → 16
            Text(
              title,
              style: const TextStyle(
                fontSize: 18, // ✅ REDUCIDO: 20 → 18
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8), // ✅ REDUCIDO: 10 → 8
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24), // ✅ REDUCIDO: 28 → 24
              SizedBox(
                width: double.infinity,
                height: 44, // ✅ REDUCIDO: 48 → 44
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // ✅ REDUCIDO: 12 → 10
                    ),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontSize: 15, // ✅ REDUCIDO: 16 → 15
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20), // ✅ ESPACIO ADICIONAL DE SEGURIDAD
          ],
        ),
      ),
    );
  }

  // ✅ FUNCIÓN CORREGIDA: Verificar ProductsProvider correctamente
  void navigateToAddLote(BuildContext context, [Product? product]) {
    // ✅ CORREGIDO: Usar try-catch para manejar errores de Provider
    try {
      final productsProvider = context.read<ProductsProvider>();

      // Verificar si hay productos disponibles
      if (product == null && productsProvider.products.isEmpty) {
        _showNoProductsDialog(context);
      } else {
        // Hay productos, navegar normalmente
        context.push('/add-lote', extra: product);
      }
    } catch (e) {
      // ✅ FALLBACK: Si ProductsProvider no está disponible
      print('Error accediendo a ProductsProvider: $e');
      _showNoProductsDialog(context);
    }
  }

  // ✅ FUNCIÓN EXTRAÍDA: Mostrar diálogo de productos faltantes
  void _showNoProductsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay productos registrados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para agregar un lote, primero debes registrar al menos un producto.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 16),
            Text(
              '¿Qué te gustaría hacer?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/add-product');
              },
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text(
                'Agregar Primer Producto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20),
              label: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLoteDialog(BuildContext context, [Product? product]) {
    navigateToAddLote(context, product);
  }

  void _showProductDetails(Product product, InventoryProvider provider) {
    final lotes = provider.getLotesForProduct(product.id!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductDetailsModal(
        product: product,
        lotes: lotes,
        onAddStock: () {
          Navigator.pop(context);
          _showAddLoteDialog(context, product);
        },
      ),
    );
  }

  void _showLoteOptions(Lote lote, InventoryProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _LoteOptionsModal(
        lote: lote,
        onMarkExpired: () async {
          Navigator.pop(context);
          final success = await provider.markLoteAsExpired(
            lote.id!,
            'Marcado como vencido por el usuario',
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lote marcado como vencido'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error ?? 'Error al marcar como vencido'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        onAdjustStock: () {
          Navigator.pop(context);
          _showAdjustStockDialog(lote, provider);
        },
      ),
    );
  }

  void _showAdjustStockDialog(Lote lote, InventoryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _AdjustStockDialog(
        lote: lote,
        onAdjust: (nuevaCantidad, motivo) async {
          final success = await provider.adjustLoteStock(
            loteId: lote.id!,
            nuevaCantidad: nuevaCantidad,
            motivo: motivo,
          );

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock ajustado correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error ?? 'Error al ajustar stock'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Widget para cards del resumen - VERSIÓN MUY COMPACTA
class _ImprovedCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAlert;
  final VoidCallback? onTap;

  const _ImprovedCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isAlert = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Reducido
      margin: EdgeInsets.zero, // Sin margin extra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAlert
            ? BorderSide(color: color, width: 1.5) // Borde más delgado
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8), // Muy reducido
          height: 85, // ALTURA MUY COMPACTA
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fila de icono y flecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 20, color: color), // Muy reducido
                  if (onTap != null)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
              // Número principal
              Text(
                value,
                style: TextStyle(
                  fontSize: 20, // Muy reducido
                  fontWeight: FontWeight.bold,
                  color: isAlert ? color : AppColors.success,
                ),
              ),
              // Título compacto
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9, // Muy reducido
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

// Widget para botones de pestaña - VERSIÓN MUY COMPACTA
class _ImprovedTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final int? badgeCount;
  final VoidCallback onTap;

  const _ImprovedTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, // ALTURA FIJA MUY COMPACTA
        padding: const EdgeInsets.symmetric(
            vertical: 4, horizontal: 2), // Muy reducido
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5, // Borde más delgado
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono con badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 18, // Muy reducido
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2), // Muy reducido
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8, // Muy reducido
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2), // Muy reducido
            // Label compacto
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // Muy reducido
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

// Widget mejorado para productos
class _ImprovedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddStock;
  final bool showUrgentBadge;

  const _ImprovedProductCard({
    required this.product,
    required this.onTap,
    required this.onAddStock,
    this.showUrgentBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final stockActual = product.stockActualSafe;
    final stockMinimo = product.stockMinimoSafe;
    final isLowStock = product.tieneStockBajo;
    final isOutOfStock = product.sinStock;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: showUrgentBadge
            ? const BorderSide(color: AppColors.warning, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icono del producto
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? AppColors.error.withOpacity(0.1)
                      : isLowStock
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 30, // Ligeramente más grande
                  color: isOutOfStock
                      ? AppColors.error
                      : isLowStock
                          ? AppColors.warning
                          : AppColors.success,
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
                              fontSize: 17, // Ligeramente más grande
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
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
                    iconSize: 30, // Ligeramente más grande
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

// Widget mejorado para lotes
class _ImprovedLoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback onTap;
  final bool showExpiredBadge;
  final bool showExpiringBadge;

  const _ImprovedLoteCard({
    required this.lote,
    required this.onTap,
    this.showExpiredBadge = false,
    this.showExpiringBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = lote.estaVencido;
    final isExpiring = lote.proximoAVencer;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                  size: 26, // Ligeramente más grande
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
                    Text(
                      lote.productoNombre ?? 'Producto',
                      style: const TextStyle(
                        fontSize: 17, // Ligeramente más grande
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lote: ${lote.numeroLoteDisplay}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cantidad: ${lote.cantidadActual}',
                      style: const TextStyle(
                        fontSize: 15, // Ligeramente más grande
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (lote.fechaVencimiento != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lote.estadoVencimientoTexto,
                        style: TextStyle(
                          fontSize: 14,
                          color: isExpired
                              ? AppColors.error
                              : isExpiring
                                  ? AppColors.warning
                                  : AppColors.textTertiary,
                          fontWeight: (isExpired || isExpiring)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Badge de estado
              if (showExpiredBadge ||
                  showExpiringBadge ||
                  isExpired ||
                  isExpiring)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
}

// Modal de detalles del producto
class _ProductDetailsModal extends StatelessWidget {
  final Product product;
  final List<Lote> lotes;
  final VoidCallback onAddStock;

  const _ProductDetailsModal({
    required this.product,
    required this.lotes,
    required this.onAddStock,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                      fontSize: 22, // Ligeramente más grande
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
                        value: '${product.stockActualSafe}',
                        color: product.sinStock
                            ? AppColors.error
                            : product.tieneStockBajo
                                ? AppColors.warning
                                : AppColors.success,
                      ),
                      _DetailChip(
                        label: 'Stock Mínimo',
                        value: '${product.stockMinimoSafe}',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de lotes
            Expanded(
              child: lotes.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay lotes registrados',
                        style: TextStyle(
                          fontSize: 17, // Ligeramente más grande
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: lotes.length,
                      itemBuilder: (context, index) {
                        return _ImprovedLoteCard(
                          lote: lotes[index],
                          onTap: () {},
                        );
                      },
                    ),
            ),

            // Botón agregar stock
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50, // Ligeramente más alto
                child: ElevatedButton.icon(
                  onPressed: onAddStock,
                  icon: const Icon(Icons.add_circle,
                      size: 26), // Ligeramente más grande
                  label: const Text(
                    'Agregar Stock',
                    style: TextStyle(
                      fontSize: 17, // Ligeramente más grande
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modal de opciones para lotes
class _LoteOptionsModal extends StatelessWidget {
  final Lote lote;
  final VoidCallback onMarkExpired;
  final VoidCallback onAdjustStock;

  const _LoteOptionsModal({
    required this.lote,
    required this.onMarkExpired,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Opciones del Lote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${lote.productoNombre} - ${lote.numeroLoteDisplay}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Opciones
          ListTile(
            leading: const Icon(Icons.edit,
                color: AppColors.primary, size: 26), // Ligeramente más grande
            title: const Text(
              'Ajustar Cantidad',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600), // Ligeramente más grande
            ),
            subtitle: const Text('Cambiar la cantidad actual del lote'),
            onTap: onAdjustStock,
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.dangerous,
                color: AppColors.error, size: 26), // Ligeramente más grande
            title: const Text(
              'Marcar como Vencido',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600), // Ligeramente más grande
            ),
            subtitle: const Text('Retirar todo el stock por vencimiento'),
            onTap: onMarkExpired,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Diálogo para ajustar stock
class _AdjustStockDialog extends StatefulWidget {
  final Lote lote;
  final Function(int, String) onAdjust;

  const _AdjustStockDialog({
    required this.lote,
    required this.onAdjust,
  });

  @override
  State<_AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends State<_AdjustStockDialog> {
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cantidadController.text = widget.lote.cantidadActual.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Ajustar Stock',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.lote.productoNombre}\nLote: ${widget.lote.numeroLoteDisplay}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Nueva Cantidad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              style: const TextStyle(fontSize: 16), // Ligeramente más grande
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese una cantidad';
                }
                final cantidad = int.tryParse(value);
                if (cantidad == null || cantidad < 0) {
                  return 'Cantidad inválida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              style: const TextStyle(fontSize: 16), // Ligeramente más grande
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el motivo del ajuste';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final nuevaCantidad = int.parse(_cantidadController.text);
              final motivo = _motivoController.text.trim();

              Navigator.pop(context);
              widget.onAdjust(nuevaCantidad, motivo);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text(
            'Ajustar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }
}

// Widget para chips de detalles
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 22, // Ligeramente más grande
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
