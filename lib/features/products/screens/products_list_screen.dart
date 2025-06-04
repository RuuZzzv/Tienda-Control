// lib/features/products/screens/products_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  
  // Estados de filtros
  int? _selectedCategoriaId;
  bool _showLowStockOnly = false;
  String _activeFilterText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductsProvider>();
      provider.loadCategorias();
      provider.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: AppSizes.iconL),
            onPressed: () => context.read<ProductsProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: AppColors.primary,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: AppSizes.iconXXL,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      provider.error!,
                      style: const TextStyle(
                        fontSize: AppSizes.textL,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    ElevatedButton.icon(
                      onPressed: () => provider.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = _getFilteredProducts(provider);

          return Column(
            children: [
              // Barra de búsqueda y filtros
              _buildSearchAndFilters(provider),

              // Indicador de filtros activos
              if (_hasActiveFilters()) _buildActiveFiltersIndicator(),

              // Lista de productos
              Expanded(
                child: products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: provider.refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _ProductCard(
                              product: products[index],
                              onTap: () => _showProductDetails(products[index]),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-product'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add, size: AppSizes.iconL),
        label: const Text(
          'Agregar Producto',
          style: TextStyle(fontSize: AppSizes.textL),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(ProductsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '🔍 Buscar productos...',
                prefixIcon: Icon(Icons.search, size: AppSizes.iconL),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              onChanged: (value) => _applyFilters(provider),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Stack(
            children: [
              ElevatedButton.icon(
                onPressed: () => _showFilterDialog(provider),
                icon: const Icon(Icons.filter_list),
                label: const Text('Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasActiveFilters() 
                      ? AppColors.primary 
                      : AppColors.accent,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
              if (_hasActiveFilters())
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersIndicator() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: AppSizes.iconM,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              _activeFilterText,
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: _clearAllFilters,
            icon: const Icon(
              Icons.close,
              size: AppSizes.iconM,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _hasActiveFilters();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.inventory_2_outlined,
              size: AppSizes.iconXXL * 2,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              hasFilters 
                  ? 'No se encontraron productos'
                  : 'No hay productos registrados',
              style: const TextStyle(
                fontSize: AppSizes.textXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              hasFilters
                  ? 'Intenta cambiar los filtros o términos de búsqueda'
                  : 'Agrega tu primer producto para comenzar a gestionar tu inventario',
              style: const TextStyle(
                fontSize: AppSizes.textL,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXL),
            if (hasFilters)
              ElevatedButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => context.push('/add-product'),
                icon: const Icon(Icons.add_circle, size: AppSizes.iconL),
                label: const Text(
                  'Agregar Primer Producto',
                  style: TextStyle(fontSize: AppSizes.textL),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXL,
                    vertical: AppSizes.paddingL,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(ProductsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.cardRadius),
                    topRight: Radius.circular(AppSizes.cardRadius),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: AppColors.textOnPrimary,
                      size: AppSizes.iconL,
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    const Expanded(
                      child: Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: AppSizes.textXL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content scrollable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtro por categoría
                      const Text(
                        'Categoría',
                        style: TextStyle(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      
                      // Container scrollable para las categorías
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                        ),
                        child: Column(
                          children: [
                            // Todas las categorías
                            ListTile(
                              dense: true,
                              leading: Radio<int?>(
                                value: null,
                                groupValue: _selectedCategoriaId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategoriaId = value;
                                  });
                                  Navigator.pop(context);
                                  _applyFilters(provider);
                                },
                              ),
                              title: const Text(
                                'Todas las categorías',
                                style: TextStyle(fontSize: AppSizes.textM),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCategoriaId = null;
                                });
                                Navigator.pop(context);
                                _applyFilters(provider);
                              },
                            ),
                            
                            if (provider.categorias.isNotEmpty) 
                              const Divider(height: 1),
                            
                            // Lista de categorías en container con altura máxima
                            if (provider.categorias.isNotEmpty)
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: provider.categorias.length,
                                  itemBuilder: (context, index) {
                                    final categoria = provider.categorias[index];
                                    return ListTile(
                                      dense: true,
                                      leading: Radio<int?>(
                                        value: categoria.id,
                                        groupValue: _selectedCategoriaId,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCategoriaId = value;
                                          });
                                          Navigator.pop(context);
                                          _applyFilters(provider);
                                        },
                                      ),
                                      title: Text(
                                        categoria.nombre,
                                        style: const TextStyle(fontSize: AppSizes.textM),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoriaId = categoria.id;
                                        });
                                        Navigator.pop(context);
                                        _applyFilters(provider);
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingL),
                      
                      // Otros filtros
                      const Text(
                        'Estado',
                        style: TextStyle(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                        ),
                        child: CheckboxListTile(
                          dense: true,
                          value: _showLowStockOnly,
                          onChanged: (value) {
                            setState(() {
                              _showLowStockOnly = value ?? false;
                            });
                            Navigator.pop(context);
                            _applyFilters(provider);
                          },
                          title: const Row(
                            children: [
                              Icon(Icons.warning, color: AppColors.warning, size: AppSizes.iconM),
                              SizedBox(width: AppSizes.paddingS),
                              Expanded(
                                child: Text(
                                  'Solo productos con stock bajo',
                                  style: TextStyle(fontSize: AppSizes.textM),
                                ),
                              ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSizes.cardRadius),
                    bottomRight: Radius.circular(AppSizes.cardRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _clearAllFilters();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Limpiar Todo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Aplicar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Product> _getFilteredProducts(ProductsProvider provider) {
    List<Product> products = provider.products;
    
    // Aplicar filtro de búsqueda
    if (_searchController.text.isNotEmpty) {
      final searchLower = _searchController.text.toLowerCase();
      products = products.where((product) {
        return product.nombre.toLowerCase().contains(searchLower) ||
               product.descripcion?.toLowerCase().contains(searchLower) == true ||
               product.codigoBarras?.contains(_searchController.text) == true ||
               product.codigoInterno?.contains(_searchController.text) == true;
      }).toList();
    }
    
    // Aplicar filtro de categoría
    if (_selectedCategoriaId != null) {
      products = products.where((product) => 
          product.categoriaId == _selectedCategoriaId).toList();
    }
    
    // Aplicar filtro de stock bajo
    if (_showLowStockOnly) {
      products = products.where((product) => product.tieneStockBajo).toList();
    }
    
    return products;
  }

  void _applyFilters(ProductsProvider provider) {
    setState(() {
      _filteredProducts = _getFilteredProducts(provider);
      _updateActiveFilterText(provider);
    });
  }

  void _updateActiveFilterText(ProductsProvider provider) {
    List<String> activeFilters = [];
    
    if (_searchController.text.isNotEmpty) {
      activeFilters.add('Búsqueda: "${_searchController.text}"');
    }
    
    if (_selectedCategoriaId != null) {
      final categoria = provider.categorias.firstWhere(
        (cat) => cat.id == _selectedCategoriaId,
        orElse: () => Categoria(nombre: 'Desconocida'),
      );
      activeFilters.add('Categoría: ${categoria.nombre}');
    }
    
    if (_showLowStockOnly) {
      activeFilters.add('Stock bajo');
    }
    
    _activeFilterText = activeFilters.join(' • ');
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
           _selectedCategoriaId != null ||
           _showLowStockOnly;
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoriaId = null;
      _showLowStockOnly = false;
      _filteredProducts = [];
      _activeFilterText = '';
    });
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.cardRadius * 2),
              topRight: Radius.circular(AppSizes.cardRadius * 2),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppSizes.paddingM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: product.tieneStockBajo 
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        size: AppSizes.iconL,
                        color: product.tieneStockBajo ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.nombre,
                            style: const TextStyle(
                              fontSize: AppSizes.textXL,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.tieneStockBajo) ...[
                            const SizedBox(height: AppSizes.paddingXS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingS,
                                vertical: AppSizes.paddingXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                              ),
                              child: const Text(
                                'Stock Bajo',
                                style: TextStyle(
                                  fontSize: AppSizes.textS,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content scrollable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información básica
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingM),
                          child: Column(
                            children: [
                              _DetailRow('Código', product.codigoDisplay),
                              _DetailRow(
                                'Precio de Venta',
                                NumberFormat.currency(
                                  locale: 'es_CO',
                                  symbol: '\$',
                                ).format(product.precioVenta),
                              ),
                              _DetailRow(
                                'Stock Actual',
                                '${product.stockActual} ${product.unidadMedida}',
                              ),
                              _DetailRow(
                                'Stock Mínimo',
                                '${product.stockMinimo} ${product.unidadMedida}',
                              ),
                              if (product.categoriaNombre != null)
                                _DetailRow('Categoría', product.categoriaNombre!),
                              if (product.descripcion != null && product.descripcion!.isNotEmpty)
                                _DetailRow('Descripción', product.descripcion!),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSizes.paddingL),
                      
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                context.push('/edit-product', extra: product);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textOnPrimary,
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingM),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // TODO: Agregar lote
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Próximamente: Agregar Lote'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_box),
                              label: const Text('Agregar Lote'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.textOnPrimary,
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSizes.paddingL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.tieneStockBajo;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: isLowStock 
                ? Border.all(color: AppColors.warning, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Icono del producto
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: isLowStock 
                      ? AppColors.warning.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: AppSizes.iconL,
                  color: isLowStock ? AppColors.warning : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),

              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontSize: AppSizes.textL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    if (product.categoriaNombre != null) ...[
                      Text(
                        product.categoriaNombre!,
                        style: const TextStyle(
                          fontSize: AppSizes.textS,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                    ],
                    Text(
                      'Stock: ${product.stockActual} ${product.unidadMedida}',
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        color: isLowStock ? AppColors.warning : AppColors.textSecondary,
                        fontWeight: isLowStock ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'es_CO',
                        symbol: '\$',
                      ).format(product.precioVenta),
                      style: const TextStyle(
                        fontSize: AppSizes.textM,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Indicadores
              Column(
                children: [
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                      ),
                      child: const Text(
                        'Stock Bajo',
                        style: TextStyle(
                          fontSize: AppSizes.textS,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSizes.paddingXS),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: AppSizes.iconS,
                    color: AppColors.textTertiary,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: AppSizes.textM,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}