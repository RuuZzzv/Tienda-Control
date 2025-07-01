// lib/features/products/widgets/product_filters.dart - CORREGIDO
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
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: const TextStyle(fontSize: AppSizes.textL),
                prefixIcon: const Icon(Icons.search, size: AppSizes.iconL),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: AppSizes.iconM),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              onChanged: onSearchChanged,
            ),
          ),

          // Botón de filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFilterDialog(context, languageProvider),
                    icon: const Icon(Icons.filter_list, size: AppSizes.iconM),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(fontSize: AppSizes.textL),
                        ),
                        if (hasActiveFilters) ...[
                          const SizedBox(width: AppSizes.paddingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
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
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                      side: BorderSide(
                        color: hasActiveFilters ? AppColors.primary : AppColors.divider,
                        width: hasActiveFilters ? 2 : 1,
                      ),
                      backgroundColor: hasActiveFilters 
                          ? AppColors.primary.withOpacity(0.05) 
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chips de filtros activos
          if (hasActiveFilters)
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: AppSizes.paddingS),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                children: [
                  if (selectedCategoriaId != null)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingS),
                      child: Chip(
                        label: Text(
                          categorias.firstWhere(
                            (c) => c.id == selectedCategoriaId,
                            orElse: () => Categoria(nombre: 'Categoría'),
                          ).nombre,
                          style: const TextStyle(fontSize: AppSizes.textM),
                        ),
                        onDeleted: () => onCategoryChanged(null),
                        deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        deleteIconColor: AppColors.primary,
                      ),
                    ),
                  
                  if (showLowStockOnly)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingS),
                      child: Chip(
                        label: const Text(
                          'Stock Bajo',
                          style: TextStyle(fontSize: AppSizes.textM),
                        ),
                        onDeleted: () => onLowStockChanged(false),
                        deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                        backgroundColor: AppColors.warning.withOpacity(0.2),
                        deleteIconColor: AppColors.warning,
                      ),
                    ),
                  
                  if (showOutOfStock)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingS),
                      child: Chip(
                        label: const Text(
                          'Sin Stock',
                          style: TextStyle(fontSize: AppSizes.textM),
                        ),
                        onDeleted: () => onOutOfStockChanged(false),
                        deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                        backgroundColor: AppColors.error.withOpacity(0.2),
                        deleteIconColor: AppColors.error,
                      ),
                    ),
                  
                  if (sortBy != 'name')
                    Padding(
                      padding: const EdgeInsets.only(right: AppSizes.paddingS),
                      child: Chip(
                        label: Text(
                          _getSortLabel(sortBy),
                          style: const TextStyle(fontSize: AppSizes.textM),
                        ),
                        onDeleted: () => onSortChanged('name'),
                        deleteIcon: const Icon(Icons.close, size: AppSizes.iconS),
                        backgroundColor: AppColors.accent.withOpacity(0.1),
                        deleteIconColor: AppColors.accent,
                      ),
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.paddingS),
                    child: ActionChip(
                      label: const Text(
                        'Limpiar todo',
                        style: TextStyle(fontSize: AppSizes.textM),
                      ),
                      onPressed: onClearFilters,
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
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

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'stock':
        return 'Ordenar por Stock';
      case 'price':
        return 'Ordenar por Precio';
      default:
        return 'Ordenar por Nombre';
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

// Diálogo de filtros simplificado
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
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: AppSizes.iconXL),
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
                    icon: const Icon(Icons.close, size: AppSizes.iconL),
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
                    _buildSectionTitle('Categoría'),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<int?>(
                            value: null,
                            groupValue: _tempCategoriaId,
                            title: const Text(
                              'Todas las categorías',
                              style: TextStyle(fontSize: AppSizes.textL),
                            ),
                            onChanged: (value) {
                              setState(() => _tempCategoriaId = value);
                            },
                          ),
                          if (widget.categorias.isNotEmpty) const Divider(height: 1),
                          ...widget.categorias.map((categoria) => RadioListTile<int?>(
                            value: categoria.id,
                            groupValue: _tempCategoriaId,
                            title: Text(
                              categoria.nombre,
                              style: const TextStyle(fontSize: AppSizes.textL),
                            ),
                            onChanged: (value) {
                              setState(() => _tempCategoriaId = value);
                            },
                          )),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingL),
                    
                    // Estado del stock
                    _buildSectionTitle('Estado del Stock'),
                    Card(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _tempShowLowStock,
                            title: const Text(
                              'Solo stock bajo',
                              style: TextStyle(fontSize: AppSizes.textL),
                            ),
                            secondary: const Icon(Icons.warning, color: AppColors.warning),
                            onChanged: (value) {
                              setState(() => _tempShowLowStock = value ?? false);
                            },
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            value: _tempShowOutOfStock,
                            title: const Text(
                              'Solo sin stock',
                              style: TextStyle(fontSize: AppSizes.textL),
                            ),
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
                    _buildSectionTitle('Ordenar por'),
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'name',
                            groupValue: _tempSortBy,
                            title: const Text(
                              'Nombre',
                              style: TextStyle(fontSize: AppSizes.textL),
                            ),
                            secondary: const Icon(Icons.sort_by_alpha),
                            onChanged: (value) {
                              setState(() => _tempSortBy = value!);
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'stock',
                            groupValue: _tempSortBy,
                            title: const Text(
                              'Stock',
                              style: TextStyle(fontSize: AppSizes.textL),
                            ),
                            secondary: const Icon(Icons.inventory),
                            onChanged: (value) {
                              setState(() => _tempSortBy = value!);
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'price',
                            groupValue: _tempSortBy,
                            title: const Text(
                              'Precio',
                              style: TextStyle(fontSize: AppSizes.textL),
                            ),
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                      ),
                      child: const Text(
                        'Limpiar',
                        style: TextStyle(fontSize: AppSizes.textL),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
                      ),
                      child: const Text(
                        'Aplicar',
                        style: TextStyle(fontSize: AppSizes.textL),
                      ),
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