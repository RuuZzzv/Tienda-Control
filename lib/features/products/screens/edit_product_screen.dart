// lib/features/products/screens/edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  
  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  
  int? _selectedCategoriaId;
  String _selectedUnidadMedida = 'unit';
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadCategorias();
    });
  }

  void _initializeFields() {
    _nombreController.text = widget.product.nombre;
    _descripcionController.text = widget.product.descripcion ?? '';
    _codigoBarrasController.text = widget.product.codigoBarras ?? '';
    _precioCompraController.text = widget.product.precioCompra.toString();
    _precioVentaController.text = widget.product.precioVenta.toString();
    _stockMinimoController.text = widget.product.stockMinimo.toString();
    _selectedCategoriaId = widget.product.categoriaId;
    _selectedUnidadMedida = widget.product.unidadMedida;
    
    _nombreController.addListener(_onFieldChanged);
    _descripcionController.addListener(_onFieldChanged);
    _codigoBarrasController.addListener(_onFieldChanged);
    _precioCompraController.addListener(_onFieldChanged);
    _precioVentaController.addListener(_onFieldChanged);
    _stockMinimoController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final unidadesMedida = [
          languageProvider.translate('unit'),
          languageProvider.translate('kilogram'),
          languageProvider.translate('gram'),
          languageProvider.translate('liter'),
          languageProvider.translate('milliliter'),
          languageProvider.translate('package'),
          languageProvider.translate('box'),
        ];

        return WillPopScope(
          onWillPop: () async {
            if (_hasChanges) {
              return await _showUnsavedChangesDialog(languageProvider);
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(languageProvider.translate('edit_product')),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => _updateProduct(languageProvider),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text(
                          languageProvider.translate('save'),
                          style: const TextStyle(
                            fontSize: AppSizes.textL,
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            body: Consumer<ProductsProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    provider.clearError();
                  });
                }

                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductInfoCard(languageProvider),
                        
                        const SizedBox(height: AppSizes.sectionSpacing),
                        
                        _buildSectionTitle(languageProvider.translate('product_info')),
                        _buildBasicProductInfo(provider, languageProvider, unidadesMedida),
                        
                        const SizedBox(height: AppSizes.sectionSpacing),
                        
                        _buildStockNote(languageProvider),
                        
                        const SizedBox(height: AppSizes.sectionSpacing),
                        
                        _buildActionButtons(languageProvider),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInfoCard(LanguageProvider languageProvider) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.containerRadius),
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.primary,
                size: AppSizes.iconL,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${languageProvider.translate('editing_product')}: ${widget.product.nombre}',
                    style: const TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${languageProvider.translate('code')}: ${widget.product.codigoDisplay}',
                    style: const TextStyle(
                      fontSize: AppSizes.textM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${languageProvider.translate('current_stock')}: ${widget.product.stockActual} ${widget.product.unidadMedida}',
                    style: const TextStyle(
                      fontSize: AppSizes.textM,
                      color: AppColors.textSecondary,
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
          fontSize: AppSizes.textXL,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBasicProductInfo(ProductsProvider provider, LanguageProvider languageProvider, List<String> unidadesMedida) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: '${languageProvider.translate('product_name')} *',
                hintText: 'Arroz Diana 1kg',
                prefixIcon: const Icon(Icons.inventory_2),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return languageProvider.translate('product_name_required');
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            TextFormField(
              controller: _descripcionController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('product_description'),
                hintText: languageProvider.translate('additional_description'),
                prefixIcon: const Icon(Icons.description),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              maxLines: 2,
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            DropdownButtonFormField<int>(
              value: _selectedCategoriaId,
              decoration: InputDecoration(
                labelText: languageProvider.translate('category'),
                prefixIcon: const Icon(Icons.category),
              ),
              style: const TextStyle(
                fontSize: AppSizes.textL,
                color: AppColors.textPrimary,
              ),
              items: provider.categorias.map((categoria) {
                return DropdownMenuItem<int>(
                  value: categoria.id,
                  child: Text(categoria.nombre),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoriaId = value;
                });
                _onFieldChanged();
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            TextFormField(
              controller: _codigoBarrasController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('barcode'),
                hintText: '7701234567890',
                prefixIcon: const Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(languageProvider.translate('coming_soon_scanner')),
                      ),
                    );
                  },
                ),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            TextFormField(
              controller: _precioCompraController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('purchase_price'),
                hintText: '0',
                prefixIcon: const Icon(Icons.shopping_cart),
                prefixText: '\$ ',
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            TextFormField(
              controller: _precioVentaController,
              decoration: InputDecoration(
                labelText: '${languageProvider.translate('sale_price')} *',
                hintText: '0',
                prefixIcon: const Icon(Icons.attach_money),
                prefixText: '\$ ',
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return languageProvider.translate('sale_price_required');
                }
                if (double.tryParse(value) == null) {
                  return languageProvider.translate('enter_valid_price');
                }
                if (double.parse(value) <= 0) {
                  return languageProvider.translate('price_greater_zero');
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            TextFormField(
              controller: _stockMinimoController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('minimum_stock_label'),
                hintText: '5',
                prefixIcon: const Icon(Icons.warning),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (int.tryParse(value) == null) {
                    return languageProvider.translate('enter_valid_number');
                  }
                  if (int.parse(value) < 0) {
                    return languageProvider.translate('cannot_be_negative');
                  }
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            DropdownButtonFormField<String>(
              value: _selectedUnidadMedida,
              decoration: InputDecoration(
                labelText: languageProvider.translate('unit_of_measure'),
                prefixIcon: const Icon(Icons.straighten),
              ),
              style: const TextStyle(
                fontSize: AppSizes.textL,
                color: AppColors.textPrimary,
              ),
              items: unidadesMedida.map((unidad) {
                return DropdownMenuItem<String>(
                  value: unidad,
                  child: Text(unidad),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnidadMedida = value!;
                });
                _onFieldChanged();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockNote(LanguageProvider languageProvider) {
    return Card(
      color: AppColors.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.accent,
              size: AppSizes.iconL,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate('note_about_stock'),
                    style: const TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  Text(
                    languageProvider.translate('stock_modification_note'),
                    style: const TextStyle(
                      fontSize: AppSizes.textM,
                      color: AppColors.textSecondary,
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

  Widget _buildActionButtons(LanguageProvider languageProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () async {
              if (_hasChanges) {
                final shouldPop = await _showUnsavedChangesDialog(languageProvider);
                if (shouldPop && mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
            icon: const Icon(Icons.cancel),
            label: Text(
              languageProvider.translate('cancel'),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading || !_hasChanges ? null : () => _updateProduct(languageProvider),
            icon: const Icon(Icons.save),
            label: Text(
              _hasChanges 
                  ? languageProvider.translate('save_changes') 
                  : languageProvider.translate('no_changes'),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? AppColors.primary : AppColors.textTertiary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showUnsavedChangesDialog(LanguageProvider languageProvider) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.translate('unsaved_changes')),
        content: Text(languageProvider.translate('sure_exit')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(languageProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: Text(languageProvider.translate('exit_without_saving')),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _updateProduct(LanguageProvider languageProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ProductsProvider>();

      final updatedProduct = widget.product.copyWith(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty 
            ? null 
            : _descripcionController.text.trim(),
        categoriaId: _selectedCategoriaId,
        codigoBarras: _codigoBarrasController.text.trim().isEmpty 
            ? null 
            : _codigoBarrasController.text.trim(),
        precioCompra: double.tryParse(_precioCompraController.text) ?? 0,
        precioVenta: double.parse(_precioVentaController.text),
        stockMinimo: int.tryParse(_stockMinimoController.text) ?? 0,
        unidadMedida: _selectedUnidadMedida,
      );

      final success = await provider.updateProduct(updatedProduct);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.translate('product_updated_successfully')),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? languageProvider.translate('error_updating_product')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${languageProvider.translate('error_updating_product')}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoBarrasController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }
}
