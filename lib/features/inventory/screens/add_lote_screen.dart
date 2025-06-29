import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_provider.dart';
import '../../products/providers/products_provider.dart';
import '../../products/models/product.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class AddLoteScreen extends StatefulWidget {
  final Product? preselectedProduct;

  const AddLoteScreen({
    super.key,
    this.preselectedProduct,
  });

  @override
  State<AddLoteScreen> createState() => _AddLoteScreenState();
}

class _AddLoteScreenState extends State<AddLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroLoteController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _notasController = TextEditingController();
  
  Product? _selectedProduct;
  DateTime? _fechaVencimiento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.preselectedProduct;
    if (widget.preselectedProduct == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductsProvider>().initializeIfNeeded();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar Selector para solo escuchar el idioma actual
    return Selector<LanguageProvider, String>(
      selector: (_, provider) => provider.currentLanguage,
      builder: (context, currentLanguage, child) {
        final languageProvider = context.read<LanguageProvider>();
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(languageProvider.translate('add_lote')),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveLote,
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
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del lote
                  _SectionTitle(title: languageProvider.translate('lote_info')),
                  _LoteInfoCard(
                    numeroLoteController: _numeroLoteController,
                    cantidadController: _cantidadController,
                    fechaVencimiento: _fechaVencimiento,
                    onSelectDate: _selectExpirationDate,
                    languageProvider: languageProvider,
                  ),
                  
                  const SizedBox(height: AppSizes.sectionSpacing),
                  
                  // Selección de producto
                  if (widget.preselectedProduct == null) ...[
                    _SectionTitle(title: languageProvider.translate('select_product')),
                    _ProductSelector(
                      selectedProduct: _selectedProduct,
                      onProductChanged: (product) {
                        setState(() {
                          _selectedProduct = product;
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.sectionSpacing),
                  ] else ...[
                    _SectionTitle(title: languageProvider.translate('selected_product')),
                    _SelectedProductInfo(product: widget.preselectedProduct!),
                    const SizedBox(height: AppSizes.sectionSpacing),
                  ],
                  
                  // Información adicional
                  _SectionTitle(title: languageProvider.translate('additional_info')),
                  _AdditionalInfoCard(
                    precioCompraController: _precioCompraController,
                    notasController: _notasController,
                    languageProvider: languageProvider,
                  ),
                  
                  const SizedBox(height: AppSizes.sectionSpacing),
                  
                  // Botones de acción
                  _ActionButtons(
                    isLoading: _isLoading,
                    onCancel: () => context.pop(),
                    onSave: _saveLote,
                    languageProvider: languageProvider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    
    if (date != null) {
      setState(() {
        _fechaVencimiento = date;
      });
    }
  }

  Future<void> _saveLote() async {
    if (!_formKey.currentState!.validate()) return;

    final product = _selectedProduct ?? widget.preselectedProduct;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un producto'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryProvider = context.read<InventoryProvider>();

      final success = await inventoryProvider.addLote(
        productoId: product.id!,
        numeroLote: _numeroLoteController.text.trim().isEmpty 
            ? null 
            : _numeroLoteController.text.trim(),
        cantidadInicial: int.parse(_cantidadController.text),
        fechaVencimiento: _fechaVencimiento,
        precioCompraLote: _precioCompraController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_precioCompraController.text),
        notas: _notasController.text.trim().isEmpty 
            ? null 
            : _notasController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lote agregado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(inventoryProvider.error ?? 'Error al agregar el lote'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
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
    _numeroLoteController.dispose();
    _cantidadController.dispose();
    _precioCompraController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}

// Widget separado para títulos de sección
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
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
}

// Widget separado para información del lote
class _LoteInfoCard extends StatelessWidget {
  final TextEditingController numeroLoteController;
  final TextEditingController cantidadController;
  final DateTime? fechaVencimiento;
  final VoidCallback onSelectDate;
  final LanguageProvider languageProvider;

  const _LoteInfoCard({
    required this.numeroLoteController,
    required this.cantidadController,
    required this.fechaVencimiento,
    required this.onSelectDate,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // Número de lote
            TextFormField(
              controller: numeroLoteController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('lote_number_optional'),
                hintText: 'Ej: ABC123, LOT-001',
                prefixIcon: const Icon(Icons.batch_prediction),
                helperText: languageProvider.translate('auto_generate_if_empty'),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // Cantidad
            TextFormField(
              controller: cantidadController,
              decoration: InputDecoration(
                labelText: '${languageProvider.translate('quantity')} *',
                hintText: '0',
                prefixIcon: const Icon(Icons.inventory),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return languageProvider.translate('quantity_required');
                }
                if (int.tryParse(value) == null) {
                  return languageProvider.translate('enter_valid_quantity');
                }
                if (int.parse(value) <= 0) {
                  return languageProvider.translate('quantity_must_be_greater_zero');
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // Fecha de vencimiento
            InkWell(
              onTap: onSelectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: languageProvider.translate('expiration_date_optional'),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  helperText: languageProvider.translate('optional_non_perishable'),
                ),
                child: Text(
                  fechaVencimiento != null
                      ? '${fechaVencimiento!.day}/${fechaVencimiento!.month}/${fechaVencimiento!.year}'
                      : languageProvider.translate('select_date'),
                  style: TextStyle(
                    fontSize: AppSizes.textL,
                    color: fechaVencimiento != null 
                        ? AppColors.textPrimary 
                        : AppColors.textTertiary,
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

// Widget separado para selector de producto
class _ProductSelector extends StatelessWidget {
  final Product? selectedProduct;
  final ValueChanged<Product?> onProductChanged;

  const _ProductSelector({
    required this.selectedProduct,
    required this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ProductsProvider, ({bool isLoading, List<Product> products})>(
      selector: (_, provider) => (
        isLoading: provider.isLoading,
        products: provider.products,
      ),
      builder: (context, data, child) {
        if (data.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingL),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              children: [
                DropdownButtonFormField<Product>(
                  value: selectedProduct,
                  decoration: const InputDecoration(
                    labelText: 'Producto *',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  style: const TextStyle(
                    fontSize: AppSizes.textL,
                    color: AppColors.textPrimary,
                  ),
                  items: data.products.map((product) {
                    return DropdownMenuItem<Product>(
                      value: product,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.nombre,
                            style: const TextStyle(
                              fontSize: AppSizes.textM,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Stock actual: ${product.stockActual} ${product.unidadMedida}',
                            style: const TextStyle(
                              fontSize: AppSizes.textS,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onProductChanged,
                  validator: (value) {
                    if (value == null) {
                      return 'Debe seleccionar un producto';
                    }
                    return null;
                  },
                ),
                
                if (selectedProduct != null) ...[
                  const SizedBox(height: AppSizes.paddingM),
                  _ProductInfoBox(product: selectedProduct!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget para mostrar información del producto seleccionado
class _ProductInfoBox extends StatelessWidget {
  final Product product;

  const _ProductInfoBox({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Producto',
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          _InfoRow('Código', product.codigoDisplay),
          _InfoRow('Stock Actual', '${product.stockActual} ${product.unidadMedida}'),
          _InfoRow('Stock Mínimo', '${product.stockMinimo} ${product.unidadMedida}'),
          if (product.categoriaNombre != null)
            _InfoRow('Categoría', product.categoriaNombre!),
        ],
      ),
    );
  }
}

// Widget para producto preseleccionado
class _SelectedProductInfo extends StatelessWidget {
  final Product product;

  const _SelectedProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
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
                Icons.inventory_2,
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
                    product.nombre,
                    style: const TextStyle(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Código: ${product.codigoDisplay}',
                    style: const TextStyle(
                      fontSize: AppSizes.textM,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Stock actual: ${product.stockActual} ${product.unidadMedida}',
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
}

// Widget para información adicional
class _AdditionalInfoCard extends StatelessWidget {
  final TextEditingController precioCompraController;
  final TextEditingController notasController;
  final LanguageProvider languageProvider;

  const _AdditionalInfoCard({
    required this.precioCompraController,
    required this.notasController,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // Precio de compra del lote
            TextFormField(
              controller: precioCompraController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('purchase_price_optional'),
                hintText: '0',
                prefixIcon: const Icon(Icons.attach_money),
                prefixText: '\$ ',
                helperText: languageProvider.translate('specific_price_this_lote'),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // Notas
            TextFormField(
              controller: notasController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('notes_optional'),
                hintText: languageProvider.translate('observations_about_lote'),
                prefixIcon: const Icon(Icons.note),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para botones de acción
class _ActionButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final LanguageProvider languageProvider;

  const _ActionButtons({
    required this.isLoading,
    required this.onCancel,
    required this.onSave,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón cancelar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onCancel,
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
        // Botón guardar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onSave,
            icon: const Icon(Icons.add_box),
            label: Text(
              languageProvider.translate('add_lote'),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget para filas de información
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: AppSizes.textS,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.textS,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}