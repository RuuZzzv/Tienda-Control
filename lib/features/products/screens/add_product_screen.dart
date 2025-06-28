// lib/features/products/screens/add_produt_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoBarrasController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _numeroLoteController = TextEditingController();
  final _cantidadInicialController = TextEditingController();
  
  int? _selectedCategoriaId;
  String _selectedUnidadMedida = 'unit';
  DateTime? _fechaVencimiento;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadCategorias();
    });
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

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(languageProvider.translate('add_product')),
            actions: [
              TextButton(
                onPressed: _isLoading ? null : () => _saveProduct(languageProvider),
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
                      _buildSectionTitle(languageProvider.translate('product_info')),
                      _buildBasicProductInfo(provider, languageProvider, unidadesMedida),
                      
                      const SizedBox(height: AppSizes.sectionSpacing),
                      
                      _buildSectionTitle(languageProvider.translate('batch_info')),
                      _buildLoteInfo(languageProvider),
                      
                      const SizedBox(height: AppSizes.sectionSpacing),
                      
                      _buildActionButtons(languageProvider),
                    ],
                  ),
                ),
              );
            },
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
              },
            ),
          ],
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
            TextFormField(
              controller: _numeroLoteController,
              decoration: InputDecoration(
                labelText: languageProvider.translate('batch_number'),
                hintText: 'ABC123',
                prefixIcon: const Icon(Icons.batch_prediction),
                helperText: languageProvider.translate('auto_generated_note'),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            TextFormField(
              controller: _cantidadInicialController,
              decoration: InputDecoration(
                labelText: '${languageProvider.translate('initial_quantity')} *',
                hintText: '0',
                prefixIcon: const Icon(Icons.inventory),
              ),
              style: const TextStyle(fontSize: AppSizes.textL),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return languageProvider.translate('initial_quantity_required');
                }
                if (int.tryParse(value) == null) {
                  return languageProvider.translate('enter_valid_quantity');
                }
                if (int.parse(value) < 0) {
                  return languageProvider.translate('quantity_cannot_negative');
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSizes.paddingM),
            
            InkWell(
              onTap: _selectExpirationDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: languageProvider.translate('expiration_date'),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  helperText: languageProvider.translate('optional_perishable'),
                ),
                child: Text(
                  _fechaVencimiento != null
                      ? '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}'
                      : languageProvider.translate('select_date'),
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

  Widget _buildActionButtons(LanguageProvider languageProvider) {
    return Column(
      children: [
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _saveProduct(languageProvider),
            icon: const Icon(Icons.save),
            label: Text(
              languageProvider.translate('save_product'),
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

  Future<void> _saveProduct(LanguageProvider languageProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ProductsProvider>();

      final product = Product(
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

      final cantidadInicial = int.tryParse(_cantidadInicialController.text) ?? 0;
      final numeroLote = _numeroLoteController.text.trim().isEmpty 
          ? null 
          : _numeroLoteController.text.trim();

      final success = await provider.addProductWithInitialStock(
        product: product,
        numeroLote: numeroLote,
        cantidadInicial: cantidadInicial,
        fechaVencimiento: _fechaVencimiento,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.translate('product_added_successfully')),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? languageProvider.translate('error_adding_product')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${languageProvider.translate('error_adding_product')}: $e'),
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
    _numeroLoteController.dispose();
    _cantidadInicialController.dispose();
    super.dispose();
  }
}