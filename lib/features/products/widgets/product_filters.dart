// lib/features/products/widgets/product_filters.dart
import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';
import 'package:provider/provider.dart';

class ProductFilters extends StatelessWidget {
  final TextEditingController searchController;
  final int? selectedCategoriaId;
  final bool showLowStockOnly;
  final bool showOutOfStock;
  final String sortBy;
  final List<Categoria> categorias;
  final Function(String) onSearchChanged;
  final Function(int?) onCategoryChanged;
  final Function(bool) onLowStockChanged;
  final Function(bool) onOutOfStockChanged;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;

  const ProductFilters({
    super.key,
    required this.searchController,
    required this.selectedCategoriaId,
    required this.showLowStockOnly,
    required this.showOutOfStock,
    required this.sortBy,
    required this.categorias,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onLowStockChanged,
    required this.onOutOfStockChanged,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final hasActiveFilters = _hasActiveFilters();

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: languageProvider.translate('search_products'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // Filtros horizontales
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Botón de filtros
                FilterChip(
                  label: Row(
                    children: [
                      const Icon(Icons.filter_list, size: AppSizes.iconS),
                      const SizedBox(width: AppSizes.paddingXS),
                      Text(languageProvider.translate('filters')),
                      if (hasActiveFilters) ...[
                        const SizedBox(width: AppSizes.paddingXS),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _getActiveFiltersCount().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.textXS,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onSelected: (_) => _showFilterDialog(context, languageProvider),
                  selected: hasActiveFilters,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                ),
                
                const SizedBox(width: AppSizes.paddingS),
                
                // Chips de filtros activos
                if (selectedCategoriaId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: Chip(
                      label: Text(
                        categorias.firstWhere(
                          (c) => c.id == selectedCategoriaId,
                          orElse: () => Categoria(nombre: 'Categoría'),
                        ).nombre,
                      ),
                      onDeleted: () => onCategoryChanged(null),
                      deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                    ),
                  ),
                
                if (showLowStockOnly)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: Chip(
                      label: Text(languageProvider.translate('low_stock')),
                      onDeleted: () => onLowStockChanged(false),
                      deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                      backgroundColor: AppColors.warning.withOpacity(0.2),
                    ),
                  ),
                
                if (showOutOfStock)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: Chip(
                      label: Text(languageProvider.translate('out_of_stock')),
                      onDeleted: () => onOutOfStockChanged(false),
                      deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                      backgroundColor: AppColors.error.withOpacity(0.2),
                    ),
                  ),
                
                if (sortBy != 'name')
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: Chip(
                      label: Text(_getSortLabel(sortBy, languageProvider)),
                      onDeleted: () => onSortChanged('name'),
                      deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                    ),
                  ),
                
                if (hasActiveFilters)
                  ActionChip(
                    label: Text(languageProvider.translate('clear_all')),
                    onPressed: onClearFilters,
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
              ],
            ),
          ),
          
          const Divider(height: 1),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return searchController.text.isNotEmpty ||
           selectedCategoriaId != null ||
           showLowStockOnly ||
           showOutOfStock ||
           sortBy != 'name';
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (selectedCategoriaId != null) count++;
    if (showLowStockOnly) count++;
    if (showOutOfStock) count++;
    if (sortBy != 'name') count++;
    return count;
  }

  String _getSortLabel(String sort, LanguageProvider languageProvider) {
    switch (sort) {
      case 'stock':
        return languageProvider.translate('sort_by_stock');
      case 'price':
        return languageProvider.translate('sort_by_price');
      default:
        return languageProvider.translate('sort_by_name');
    }
  }

  void _showFilterDialog(BuildContext context, LanguageProvider languageProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterDialog(
        selectedCategoriaId: selectedCategoriaId,
        showLowStockOnly: showLowStockOnly,
        showOutOfStock: showOutOfStock,
        sortBy: sortBy,
        categorias: categorias,
        onCategoryChanged: onCategoryChanged,
        onLowStockChanged: onLowStockChanged,
        onOutOfStockChanged: onOutOfStockChanged,
        onSortChanged: onSortChanged,
        onClearFilters: onClearFilters,
        languageProvider: languageProvider,
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final int? selectedCategoriaId;
  final bool showLowStockOnly;
  final bool showOutOfStock;
  final String sortBy;
  final List<Categoria> categorias;
  final Function(int?) onCategoryChanged;
  final Function(bool) onLowStockChanged;
  final Function(bool) onOutOfStockChanged;
  final Function(String) onSortChanged;
  final VoidCallback onClearFilters;
  final LanguageProvider languageProvider;

  const _FilterDialog({
    required this.selectedCategoriaId,
    required this.showLowStockOnly,
    required this.showOutOfStock,
    required this.sortBy,
    required this.categorias,
    required this.onCategoryChanged,
    required this.onLowStockChanged,
    required this.onOutOfStockChanged,
    required this.onSortChanged,
    required this.onClearFilters,
    required this.languageProvider,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late int? _tempCategoriaId;
  late bool _tempShowLowStock;
  late bool _tempShowOutOfStock;
  late String _tempSortBy;

  @override
  void initState() {
    super.initState();
    _tempCategoriaId = widget.selectedCategoriaId;
    _tempShowLowStock = widget.showLowStockOnly;
    _tempShowOutOfStock = widget.showOutOfStock;
    _tempSortBy = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadius * 2),
          topRight: Radius.circular(AppSizes.cardRadius * 2),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
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
                  const Icon(Icons.filter_list, size: AppSizes.iconL),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      widget.languageProvider.translate('filters'),
                      style: const TextStyle(
                        fontSize: AppSizes.textXL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categorías
                    _buildSectionTitle(widget.languageProvider.translate('category')),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<int?>(
                            value: null,
                            groupValue: _tempCategoriaId,
                            title: Text(widget.languageProvider.translate('all_categories')),
                            onChanged: (value) {
                              setState(() => _tempCategoriaId = value);
                            },
                          ),
                          if (widget.categorias.isNotEmpty) const Divider(height: 1),
                          ...widget.categorias.map((categoria) => RadioListTile<int?>(
                            value: categoria.id,
                            groupValue: _tempCategoriaId,
                            title: Text(categoria.nombre),
                            onChanged: (value) {
                              setState(() => _tempCategoriaId = value);
                            },
                          )),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // Estado del stock
                    _buildSectionTitle(widget.languageProvider.translate('stock_status')),
                    Card(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _tempShowLowStock,
                            title: Text(widget.languageProvider.translate('low_stock_only')),
                            secondary: const Icon(Icons.warning, color: AppColors.warning),
                            onChanged: (value) {
                              setState(() => _tempShowLowStock = value ?? false);
                            },
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            value: _tempShowOutOfStock,
                            title: Text(widget.languageProvider.translate('out_of_stock_only')),
                            secondary: const Icon(Icons.remove_circle, color: AppColors.error),
                            onChanged: (value) {
                              setState(() => _tempShowOutOfStock = value ?? false);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // Ordenar por
                    _buildSectionTitle(widget.languageProvider.translate('sort_by')),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'name',
                            groupValue: _tempSortBy,
                            title: Text(widget.languageProvider.translate('name')),
                            secondary: const Icon(Icons.sort_by_alpha),
                            onChanged: (value) {
                              setState(() => _tempSortBy = value!);
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'stock',
                            groupValue: _tempSortBy,
                            title: Text(widget.languageProvider.translate('stock')),
                            secondary: const Icon(Icons.inventory),
                            onChanged: (value) {
                              setState(() => _tempSortBy = value!);
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'price',
                            groupValue: _tempSortBy,
                            title: Text(widget.languageProvider.translate('price')),
                            secondary: const Icon(Icons.attach_money),
                            onChanged: (value) {
                              setState(() => _tempSortBy = value!);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _tempCategoriaId = null;
                          _tempShowLowStock = false;
                          _tempShowOutOfStock = false;
                          _tempSortBy = 'name';
                        });
                        widget.onClearFilters();
                        Navigator.pop(context);
                      },
                      child: Text(widget.languageProvider.translate('clear')),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onCategoryChanged(_tempCategoriaId);
                        widget.onLowStockChanged(_tempShowLowStock);
                        widget.onOutOfStockChanged(_tempShowOutOfStock);
                        widget.onSortChanged(_tempSortBy);
                        Navigator.pop(context);
                      },
                      child: Text(widget.languageProvider.translate('apply')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppSizes.textL,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}