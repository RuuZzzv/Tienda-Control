// lib/features/inventory/screens/add_lote_screen.dart
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preselectedProduct == null) {
        context.read<ProductsProvider>().loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Agregar Lote'),
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
                  _buildSectionTitle('Información del Lote'),
                  _buildLoteInfo(languageProvider),
                  
                  const SizedBox(height: AppSizes.sectionSpacing),
                  
                  // Selección de producto (si no está preseleccionado)
                  if (widget.preselectedProduct == null) ...[
                    _buildSectionTitle('Seleccionar Producto'),
                    _buildProductSelector(),
                    const SizedBox(height: AppSizes.sectionSpacing),
                  ] else ...[
                    _buildSectionTitle('Producto Seleccionado'),
                    _buildSelectedProductInfo(),
                    const SizedBox(height: AppSizes.sectionSpacing),
                  ],
                  
                  // Información adicional
                  _buildSectionTitle('Información Adicional'),
                  _buildAdditionalInfo(languageProvider),
                  
                  const SizedBox(height: AppSizes.sectionSpacing),
                  
                  // Botones de acción
                  _buildActionButtons(languageProvider),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildLoteInfo(LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // Número de lote
            TextFormField(
              controller: _numeroLoteController,
              decoration: const InputDecoration(
                labelText: 'Número de Lote (opcional)',
                hintText: 'Ej: ABC123, LOT-001',
                prefixIcon: Icon(Icons.batch_prediction),
                helperText: 'Si no se especifica, se generará automáticamente',
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // Cantidad
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad *',
                hintText: '0',
                prefixIcon: Icon(Icons.inventory),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad es obligatoria';
                }
                if (int.tryParse(value) == null) {
                  return 'Ingrese una cantidad válida';
                }
                if (int.parse(value) <= 0) {
                  return 'La cantidad debe ser mayor a 0';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // Fecha de vencimiento
            InkWell(
              onTap: _selectExpirationDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Vencimiento (opcional)',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  helperText: 'Opcional para productos no perecederos',
                ),
                child: Text(
                  _fechaVencimiento != null
                      ? '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    fontSize: AppSizes.textL,
                    color: _fechaVencimiento != null 
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

  Widget _buildProductSelector() {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        if (productsProvider.isLoading) {
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
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                    labelText: 'Producto *',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  style: const TextStyle(
                    fontSize: AppSizes.textL,
                    color: AppColors.textPrimary,
                  ),
                  items: productsProvider.products.map((product) {
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
                  onChanged: (value) {
                    setState(() {
                      _selectedProduct = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debe seleccionar un producto';
                    }
                    return null;
                  },
                ),
                
                if (_selectedProduct != null) ...[
                  const SizedBox(height: AppSizes.paddingM),
                  Container(
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
                        _InfoRow('Código', _selectedProduct!.codigoDisplay),
                        _InfoRow('Stock Actual', '${_selectedProduct!.stockActual} ${_selectedProduct!.unidadMedida}'),
                        _InfoRow('Stock Mínimo', '${_selectedProduct!.stockMinimo} ${_selectedProduct!.unidadMedida}'),
                        if (_selectedProduct!.categoriaNombre != null)
                          _InfoRow('Categoría', _selectedProduct!.categoriaNombre!),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedProductInfo() {
    if (widget.preselectedProduct == null) return const SizedBox();
    
    final product = widget.preselectedProduct!;
    
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

  Widget _buildAdditionalInfo(LanguageProvider languageProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            // Precio de compra del lote
            TextFormField(
              controller: _precioCompraController,
              decoration: const InputDecoration(
                labelText: 'Precio de Compra (opcional)',
                hintText: '0',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '\$ ',
                helperText: 'Precio de compra específico para este lote',
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            // Notas
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                hintText: 'Observaciones sobre este lote...',
                prefixIcon: Icon(Icons.note),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LanguageProvider languageProvider) {
    return Column(
      children: [
        // Botón cancelar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => context.pop(),
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
            onPressed: _isLoading ? null : _saveLote,
            icon: const Icon(Icons.add_box),
            label: const Text(
              'Agregar Lote',
              style: TextStyle(fontSize: AppSizes.textL),
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