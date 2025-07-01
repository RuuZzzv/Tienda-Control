// lib/features/products/screens/products_list_screen.dart - REDISEÑADO
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
import '../widgets/product_card.dart';
import '../widgets/product_filters.dart';
import '../widgets/products_empty_state.dart';
import '../widgets/product_details_sheet.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Estados de filtros
  int? _selectedCategoriaId;
  bool _showLowStockOnly = false;
  bool _showOutOfStock = false;
  String _sortBy = 'name';
  
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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(languageProvider),
          body: Consumer<ProductsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.products.isEmpty) {
                return const LoadingWidget(
                  message: 'Cargando productos...',
                );
              }

              if (provider.error != null && provider.products.isEmpty) {
                return CustomErrorWidget(
                  error: provider.error!,
                  onRetry: () => provider.refresh(),
                );
              }

              final products = _getFilteredAndSortedProducts(provider);

              return SafeArea(
                child: Column(
                  children: [
                    // Barra de búsqueda y filtros
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          // Búsqueda
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingL,
                              vertical: AppSizes.paddingM,
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar productos...',
                                hintStyle: TextStyle(
                                  fontSize: AppSizes.textL,
                                  color: AppColors.textTertiary,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: AppSizes.iconL,
                                  color: AppColors.textSecondary,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          size: AppSizes.iconM,
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
                                  horizontal: AppSizes.paddingL,
                                  vertical: AppSizes.paddingL,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(fontSize: AppSizes.textL),
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          
                          // Botón de filtros
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSizes.paddingL,
                              right: AppSizes.paddingL,
                              bottom: AppSizes.paddingM,
                            ),
                            child: OutlinedButton(
                              onPressed: () => _showFilterDialog(context, languageProvider),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingL,
                                  vertical: AppSizes.paddingM,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                side: BorderSide(
                                  color: _hasActiveFilters() 
                                      ? AppColors.primary 
                                      : AppColors.divider,
                                  width: 2,
                                ),
                                backgroundColor: _hasActiveFilters()
                                    ? AppColors.primary.withOpacity(0.05)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    size: AppSizes.iconM,
                                    color: _hasActiveFilters()
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppSizes.paddingS),
                                  Text(
                                    'Filtros',
                                    style: TextStyle(
                                      fontSize: AppSizes.textL,
                                      color: _hasActiveFilters()
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_hasActiveFilters()) ...[
                                    const SizedBox(width: AppSizes.paddingS),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        _getActiveFiltersCount().toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: AppSizes.textS,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1),

                    // Lista de productos o estado vacío
                    Expanded(
                      child: products.isEmpty
                          ? ProductsEmptyState(
                              hasFilters: _hasActiveFilters(),
                              onClearFilters: _clearAllFilters,
                              onAddProduct: () => context.push('/add-product'),
                            )
                          : RefreshIndicator(
                              onRefresh: provider.refresh,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: AppSizes.paddingL,
                                  right: AppSizes.paddingL,
                                  top: AppSizes.paddingM,
                                  bottom: 100, // Espacio para el FAB
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  
                                  return ProductCard(
                                    product: product,
                                    onTap: () => _showProductDetails(product, languageProvider),
                                    onEdit: () => context.push('/edit-product', extra: product),
                                    onAddStock: () => context.push('/add-lote', extra: product),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: _buildFAB(languageProvider),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  AppBar _buildAppBar(LanguageProvider languageProvider) {
    return AppBar(
      title: const Text(
        'Productos',
        style: TextStyle(
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<ProductsProvider>(
          builder: (context, provider, child) {
            final lowStockCount = provider.products.where((p) => p.tieneStockBajo).length;
            
            if (lowStockCount == 0) {
              return const SizedBox.shrink();
            }
            
            return Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingM),
              child: Badge(
                label: Text(
                  lowStockCount.toString(),
                  style: const TextStyle(fontSize: AppSizes.textS),
                ),
                backgroundColor: AppColors.warning,
                child: IconButton(
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    size: AppSizes.iconL,
                  ),
                  onPressed: () {
                    setState(() {
                      _showLowStockOnly = !_showLowStockOnly;
                    });
                  },
                  tooltip: 'Productos con stock bajo',
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh, size: AppSizes.iconL),
          onPressed: () => context.read<ProductsProvider>().refresh(),
          tooltip: 'Actualizar',
        ),
      ],
    );
  }

  Widget _buildFAB(LanguageProvider languageProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: FloatingActionButton.extended(
        onPressed: () => context.push('/add-product'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: Icon(Icons.add, size: AppSizes.iconL),
        label: const Text(
          'Agregar Producto',
          style: TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  List<Product> _getFilteredAndSortedProducts(ProductsProvider provider) {
    List<Product> products = [...provider.products];
    
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
      products = products.where((p) => p.categoriaId == _selectedCategoriaId).toList();
    }
    
    // Aplicar filtro de stock bajo
    if (_showLowStockOnly) {
      products = products.where((p) => p.tieneStockBajo).toList();
    }
    
    // Aplicar filtro de sin stock
    if (_showOutOfStock) {
      products = products.where((p) => p.stockActual == 0).toList();
    }
    
    // Ordenar productos
    products.sort((a, b) {
      switch (_sortBy) {
        case 'stock':
          return a.stockActual.compareTo(b.stockActual);
        case 'price':
          return a.precioVenta.compareTo(b.precioVenta);
        case 'name':
        default:
          return a.nombre.compareTo(b.nombre);
      }
    });
    
    return products;
  }

  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
           _selectedCategoriaId != null ||
           _showLowStockOnly ||
           _showOutOfStock ||
           _sortBy != 'name';
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_selectedCategoriaId != null) count++;
    if (_showLowStockOnly) count++;
    if (_showOutOfStock) count++;
    if (_sortBy != 'name') count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoriaId = null;
      _showLowStockOnly = false;
      _showOutOfStock = false;
      _sortBy = 'name';
    });
  }

  void _showProductDetails(Product product, LanguageProvider languageProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsSheet(
        product: product,
        languageProvider: languageProvider,
      ),
    );
  }

  void _showFilterDialog(BuildContext context, LanguageProvider languageProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadius * 2),
          topRight: Radius.circular(AppSizes.cardRadius * 2),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSizes.cardRadius * 2),
            topRight: Radius.circular(AppSizes.cardRadius * 2),
          ),
        ),
        child: Column(
          children: [
            // Barra superior
            Container(
              margin: const EdgeInsets.only(top: AppSizes.paddingM),
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Título
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: AppSizes.iconXL,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  const Expanded(
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: AppSizes.textXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: AppSizes.iconL,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Contenido de filtros
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Estado
                    _buildFilterSection(
                      title: 'Estado del Stock',
                      children: [
                        CheckboxListTile(
                          value: _showLowStockOnly,
                          onChanged: (value) {
                            setState(() => _showLowStockOnly = value ?? false);
                            Navigator.pop(context);
                          },
                          title: const Text(
                            'Stock Bajo',
                            style: TextStyle(fontSize: AppSizes.textL),
                          ),
                          subtitle: const Text(
                            'Mostrar solo productos con poco stock',
                            style: TextStyle(fontSize: AppSizes.textM),
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(AppSizes.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                            ),
                            child: Icon(
                              Icons.warning,
                              color: AppColors.warning,
                              size: AppSizes.iconL,
                            ),
                          ),
                        ),
                        const Divider(),
                        CheckboxListTile(
                          value: _showOutOfStock,
                          onChanged: (value) {
                            setState(() => _showOutOfStock = value ?? false);
                            Navigator.pop(context);
                          },
                          title: const Text(
                            'Sin Stock',
                            style: TextStyle(fontSize: AppSizes.textL),
                          ),
                          subtitle: const Text(
                            'Mostrar solo productos agotados',
                            style: TextStyle(fontSize: AppSizes.textM),
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(AppSizes.paddingS),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                            ),
                            child: Icon(
                              Icons.remove_circle,
                              color: AppColors.error,
                              size: AppSizes.iconL,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Sección de Ordenar
                    _buildFilterSection(
                      title: 'Ordenar por',
                      children: [
                        RadioListTile<String>(
                          value: 'name',
                          groupValue: _sortBy,
                          onChanged: (value) {
                            setState(() => _sortBy = value!);
                            Navigator.pop(context);
                          },
                          title: const Text(
                            'Nombre (A-Z)',
                            style: TextStyle(fontSize: AppSizes.textL),
                          ),
                          secondary: Icon(
                            Icons.sort_by_alpha,
                            size: AppSizes.iconL,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Divider(),
                        RadioListTile<String>(
                          value: 'stock',
                          groupValue: _sortBy,
                          onChanged: (value) {
                            setState(() => _sortBy = value!);
                            Navigator.pop(context);
                          },
                          title: const Text(
                            'Cantidad en Stock',
                            style: TextStyle(fontSize: AppSizes.textL),
                          ),
                          secondary: Icon(
                            Icons.inventory,
                            size: AppSizes.iconL,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Divider(),
                        RadioListTile<String>(
                          value: 'price',
                          groupValue: _sortBy,
                          onChanged: (value) {
                            setState(() => _sortBy = value!);
                            Navigator.pop(context);
                          },
                          title: const Text(
                            'Precio',
                            style: TextStyle(fontSize: AppSizes.textL),
                          ),
                          secondary: Icon(
                            Icons.attach_money,
                            size: AppSizes.iconL,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Botón de limpiar filtros
            if (_hasActiveFilters())
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _clearAllFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                      ),
                    ),
                    child: const Text(
                      'Limpiar Todos los Filtros',
                      style: TextStyle(
                        fontSize: AppSizes.textL,
                        fontWeight: FontWeight.bold,
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

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}