// lib/features/products/screens/products_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_modal.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/extensions/build_context_extensions.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Estados de filtros simplificados
  String _currentFilter = 'todos';
  String _sortBy = 'name';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() async {
    try {
      final provider = context.read<ProductsProvider>();
      await provider.initializeIfNeeded();
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.products.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.error != null && provider.products.isEmpty) {
            return _buildErrorState(provider);
          }

          final products = _getFilteredAndSortedProducts(provider);

          return _buildMainContent(provider, products);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        context.tr('my_products'),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 24),
          onPressed: () {
            context.read<ProductsProvider>().refresh();
          },
          tooltip: context.tr('refresh'),
        ),
      ],
    );
  }

  Widget _buildMainContent(ProductsProvider provider, List<Product> products) {
    return Column(
      children: [
        // Header compacto
        _buildCompactHeader(provider),
        
        // Contenido principal
        Expanded(
          child: products.isEmpty
              ? _buildEmptyState()
              : _buildProductsList(products, provider),
        ),
      ],
    );
  }

  Widget _buildCompactHeader(ProductsProvider provider) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de búsqueda COMPACTA
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: context.tr('search_products'),
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),
          
          // Filtros COMPACTOS
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _CompactFilterButton(
                    label: context.tr('all_products'),
                    count: provider.products.length,
                    isSelected: _currentFilter == 'todos',
                    color: AppColors.info,
                    onTap: () => setState(() => _currentFilter = 'todos'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CompactFilterButton(
                    label: context.tr('low_stock'),
                    count: provider.getProductsWithLowStock().length,
                    isSelected: _currentFilter == 'stock_bajo',
                    color: AppColors.warning,
                    onTap: () => setState(() => _currentFilter = 'stock_bajo'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CompactFilterButton(
                    label: context.tr('out_of_stock'),
                    count: provider.getOutOfStockProducts().length,
                    isSelected: _currentFilter == 'sin_stock',
                    color: AppColors.error,
                    onTap: () => setState(() => _currentFilter = 'sin_stock'),
                  ),
                ),
              ],
            ),
          ),
          
          // Ordenamiento COMPACTO
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.sort,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${context.tr('sort')}:',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(6),
                      color: AppColors.background,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        isDense: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'name',
                            child: Text(context.tr('sort_by_name')),
                          ),
                          DropdownMenuItem(
                            value: 'stock',
                            child: Text(context.tr('sort_by_stock')),
                          ),
                          DropdownMenuItem(
                            value: 'price',
                            child: Text(context.tr('sort_by_price')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider reducido
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppColors.border, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<Product> products, ProductsProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 4,
          bottom: MediaQuery.of(context).viewPadding.bottom + 140,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          
          return ProductCard(
            product: product,
            onTap: () => ProductDetailModal.show(context, product),
            // Usar context.go() en lugar de context.push()
            onEdit: () => context.go('/edit-product/${product.id}'),
            onAddStock: () => context.go('/add-lote', extra: product),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewPadding.bottom + 140,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono compacto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _hasActiveFilters() ? Icons.search_off : Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.primary.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Título
          Text(
            _hasActiveFilters() 
                ? context.tr('no_products_found')
                : context.tr('no_products_registered'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Mensaje descriptivo
          Text(
            _hasActiveFilters()
                ? context.tr('try_refresh')
                : context.tr('add_first_product'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Botón para limpiar filtros
          if (_hasActiveFilters())
            OutlinedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(context.tr('clear_filters')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('loading_data'),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProductsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('error_loading_data'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? context.tr('unexpected_error'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _getFilteredAndSortedProducts(ProductsProvider provider) {
    List<Product> products = [...provider.products];
    
    // Aplicar filtro de búsqueda
    if (_searchController.text.isNotEmpty) {
      products = provider.searchProducts(_searchController.text);
    }
    
    // Aplicar filtro principal
    switch (_currentFilter) {
      case 'stock_bajo':
        products = products.where((p) => p.tieneStockBajo).toList();
        break;
      case 'sin_stock':
        products = products.where((p) => p.sinStock).toList();
        break;
      case 'todos':
      default:
        break;
    }
    
    // Ordenar productos
    products.sort((a, b) {
      switch (_sortBy) {
        case 'stock':
          return a.stockActualSafe.compareTo(b.stockActualSafe);
        case 'price':
          return a.precioVenta.compareTo(b.precioVenta);
        case 'name':
        default:
          return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      }
    });
    
    return products;
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
           _currentFilter != 'todos' ||
           _sortBy != 'name';
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _currentFilter = 'todos';
      _sortBy = 'name';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// BOTÓN DE FILTRO COMPACTO
class _CompactFilterButton extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CompactFilterButton({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected 
              ? color 
              : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? color 
                : color.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Número
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            
            // Label compacto
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
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