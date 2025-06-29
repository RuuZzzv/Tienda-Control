// lib/features/products/screens/products_list_screen.dart
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
  String _sortBy = 'name'; // name, stock, price
  
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

              return Column(
                children: [
                  // Barra de búsqueda y filtros
                  ProductFilters(
                    searchController: _searchController,
                    selectedCategoriaId: _selectedCategoriaId,
                    showLowStockOnly: _showLowStockOnly,
                    showOutOfStock: _showOutOfStock,
                    sortBy: _sortBy,
                    categorias: provider.categorias,
                    onSearchChanged: (value) => setState(() {}),
                    onCategoryChanged: (value) => setState(() => _selectedCategoriaId = value),
                    onLowStockChanged: (value) => setState(() => _showLowStockOnly = value),
                    onOutOfStockChanged: (value) => setState(() => _showOutOfStock = value),
                    onSortChanged: (value) => setState(() => _sortBy = value),
                    onClearFilters: _clearAllFilters,
                  ),

                  // Lista de productos
                  Expanded(
                    child: products.isEmpty
                        ? ProductsEmptyState(
                            hasFilters: _hasActiveFilters(),
                            onClearFilters: _clearAllFilters,
                            onAddProduct: () => context.push('/add-product'),
                          )
                        : RefreshIndicator(
                            onRefresh: provider.refresh,
                            child: _buildProductsList(products, languageProvider),
                          ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: _buildFAB(languageProvider),
        );
      },
    );
  }

  AppBar _buildAppBar(LanguageProvider languageProvider) {
    return AppBar(
      title: Text(languageProvider.translate('products')),
      actions: [
        Consumer<ProductsProvider>(
          builder: (context, provider, child) {
            final lowStockCount = provider.products.where((p) => p.tieneStockBajo).length;
            
            return Badge(
              isLabelVisible: lowStockCount > 0,
              label: Text(lowStockCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.warning_amber_rounded),
                onPressed: () {
                  setState(() {
                    _showLowStockOnly = !_showLowStockOnly;
                  });
                },
                tooltip: languageProvider.translate('low_stock_products'),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<ProductsProvider>().refresh(),
          tooltip: languageProvider.translate('refresh'),
        ),
      ],
    );
  }

  Widget _buildProductsList(List<Product> products, LanguageProvider languageProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
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
    );
  }

  Widget _buildFAB(LanguageProvider languageProvider) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/add-product'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      icon: const Icon(Icons.add),
      label: Text(languageProvider.translate('add_product')),
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
      products = products.where((p) => p.stockActualSafe == 0).toList();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}