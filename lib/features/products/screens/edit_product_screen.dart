// lib/features/products/screens/edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../models/product_extensions.dart';
import '../providers/products_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/extensions/build_context_extensions.dart';

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
  final _precioCostoController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  
  int? _selectedCategoriaId;
  String _selectedUnidadMedida = 'unidad';
  bool _isLoading = false;
  bool _hasChanges = false;
  int _currentStep = 0;

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
    _precioCostoController.text = widget.product.precioCosto?.toString() ?? '';
    _precioVentaController.text = widget.product.precioVenta.toString();
    _stockMinimoController.text = widget.product.stockMinimoSafe.toString();
    _selectedCategoriaId = widget.product.categoriaId;
    _selectedUnidadMedida = widget.product.unidadMedida ?? 'unidad';
    
    // Listeners para detectar cambios
    _nombreController.addListener(_onFieldChanged);
    _descripcionController.addListener(_onFieldChanged);
    _codigoBarrasController.addListener(_onFieldChanged);
    _precioCostoController.addListener(_onFieldChanged);
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

  void _onCategoryChanged(int? value) {
    if (value != _selectedCategoriaId) {
      setState(() {
        _selectedCategoriaId = value;
        _hasChanges = true;
      });
    }
  }

  void _onUnitChanged(String value) {
    if (value != _selectedUnidadMedida) {
      setState(() {
        _selectedUnidadMedida = value;
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return WillPopScope(
          onWillPop: _handleBackPress,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(langProvider),
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
                  child: Column(
                    children: [
                      // Indicador de progreso
                      _buildProgressIndicator(langProvider),

                      // Contenido del paso actual
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: _buildCurrentStep(langProvider),
                        ),
                      ),

                      // Botones de navegación
                      _buildNavigationButtons(langProvider),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(LanguageProvider langProvider) {
    return AppBar(
      title: Text(
        '${langProvider.translate('edit_product')}: ${widget.product.nombre}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/products');
          }
        },
      ),
      actions: [
        if (_hasChanges && _currentStep == 2) // Solo mostrar en el último paso si hay cambios
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _showSaveConfirmation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                langProvider.translate('save'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(LanguageProvider langProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepIndicator(0, langProvider.translate('basic_information'), Icons.info),
              _buildStepLine(0),
              _buildStepIndicator(1, langProvider.translate('pricing'), Icons.attach_money),
              _buildStepLine(1),
              _buildStepIndicator(2, '${langProvider.translate('stock')} &\n${langProvider.translate('product_details')}', Icons.inventory),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(langProvider),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(top: 25),
        color: isCompleted ? AppColors.success : AppColors.border,
      ),
    );
  }

  String _getStepTitle(LanguageProvider langProvider) {
    switch (_currentStep) {
      case 0:
        return langProvider.translate('product_information');
      case 1:
        return langProvider.translate('price_information');
      case 2:
        return langProvider.translate('stock_information');
      default:
        return '';
    }
  }

  Widget _buildCurrentStep(LanguageProvider langProvider) {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep(langProvider);
      case 1:
        return _buildPricesStep(langProvider);
      case 2:
        return _buildStockAndSummaryStep(langProvider);
      default:
        return Container();
    }
  }

  // PASO 1: Información Básica
  Widget _buildBasicInfoStep(LanguageProvider langProvider) {
    return Column(
      children: [
        // Card informativa del producto
        _buildProductInfoCard(langProvider),
        
        const SizedBox(height: 24),

        // Nombre del producto (OBLIGATORIO)
        _buildLargeTextField(
          controller: _nombreController,
          label: langProvider.translate('product_name'),
          hint: 'Rice Diana 1kg / Riso Diana 1kg / Arroz Diana 1kg',
          icon: Icons.inventory_2,
          isRequired: true,
          langProvider: langProvider,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return langProvider.translate('required_field');
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Descripción
        _buildLargeTextField(
          controller: _descripcionController,
          label: '${langProvider.translate('product_description')} (${langProvider.translate('optional_field')})',
          hint: langProvider.translate('product_description'),
          icon: Icons.description,
          maxLines: 3,
          langProvider: langProvider,
        ),

        const SizedBox(height: 24),

        // Categoría
        _buildCategorySection(langProvider),

        const SizedBox(height: 24),

        // Código de barras
        _buildBarcodeSection(langProvider),
      ],
    );
  }

  // PASO 2: Precios
  Widget _buildPricesStep(LanguageProvider langProvider) {
    return Column(
      children: [
        // Precio de venta (OBLIGATORIO)
        _buildLargeTextField(
          controller: _precioVentaController,
          label: langProvider.translate('sale_price'),
          hint: '0.00',
          icon: Icons.sell,
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isRequired: true,
          langProvider: langProvider,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return langProvider.translate('required_field');
            }
            final precio = double.tryParse(value);
            if (precio == null || precio <= 0) {
              return langProvider.translate('invalid');
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Precio de compra (OPCIONAL)
        _buildLargeTextField(
          controller: _precioCostoController,
          label: '${langProvider.translate('purchase_price')} (${langProvider.translate('optional_field')})',
          hint: '0.00',
          icon: Icons.shopping_cart,
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          helperText: langProvider.translate('profit_margin'),
          langProvider: langProvider,
        ),

        const SizedBox(height: 24),

        // Indicador de margen
        if (_precioCostoController.text.isNotEmpty &&
            _precioVentaController.text.isNotEmpty)
          _buildProfitMarginIndicator(langProvider),
      ],
    );
  }

  // PASO 3: Stock y Resumen
  Widget _buildStockAndSummaryStep(LanguageProvider langProvider) {
    return Column(
      children: [
        // Stock mínimo
        _buildLargeTextField(
          controller: _stockMinimoController,
          label: '${langProvider.translate('minimum_stock')} (${langProvider.translate('optional_field')})',
          hint: '5',
          icon: Icons.warning,
          keyboardType: TextInputType.number,
          helperText: langProvider.translate('low_stock_warning'),
          langProvider: langProvider,
        ),

        const SizedBox(height: 24),

        // Unidad de medida
        _buildUnitSection(langProvider),

        const SizedBox(height: 24),

        // Nota informativa
        _buildInfoNote(langProvider),

        const SizedBox(height: 32),

        // Resumen de cambios
        if (_hasChanges) _buildChangeSummary(langProvider),
      ],
    );
  }

  Widget _buildProductInfoCard(LanguageProvider langProvider) {
    final isLowStock = widget.product.tieneStockBajo;
    final stockColor = isLowStock ? AppColors.warning : AppColors.success;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stockColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stockColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit_note,
              color: stockColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${langProvider.translate('code')}: ${widget.product.codigoDisplay}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLowStock ? Icons.warning : Icons.check_circle,
                        color: stockColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${langProvider.translate('stock')}: ${widget.product.stockActualSafe} ${widget.product.unidadMedidaDisplay}',
                        style: TextStyle(
                          fontSize: 14,
                          color: stockColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(LanguageProvider langProvider) {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.category, size: 28, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    '${langProvider.translate('category')} (${langProvider.translate('optional_field')})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: _selectedCategoriaId,
                decoration: InputDecoration(
                  hintText: langProvider.translate('select_category'),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                items: provider.categorias.map((categoria) {
                  return DropdownMenuItem<int?>(
                    value: categoria.id,
                    child: Text(categoria.nombre),
                  );
                }).toList(),
                onChanged: _onCategoryChanged,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarcodeSection(LanguageProvider langProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code, size: 24, color: AppColors.primary),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '${langProvider.translate('barcode')} (${langProvider.translate('optional_field')})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _codigoBarrasController,
                  decoration: const InputDecoration(
                    hintText: '7701234567890',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                child: ElevatedButton(
                  onPressed: () => _scanBarcode(langProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSection(LanguageProvider langProvider) {
    final unidadesMedida = [
      'unidad',
      'kilogramo',
      'gramo',
      'litro',
      'mililitro',
      'paquete',
      'caja',
      'docena',
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten, size: 24, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                langProvider.translate('unit_measure'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedUnidadMedida,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
            items: unidadesMedida.map((unidad) {
              return DropdownMenuItem<String>(
                value: unidad,
                child: Text(unidad),
              );
            }).toList(),
            onChanged: (value) => _onUnitChanged(value!),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? prefixText,
    String? helperText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
    String? Function(String?)? validator,
    required LanguageProvider langProvider,
  }) {
    return Container(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isRequired ? AppColors.primary : AppColors.textSecondary,
          ),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, size: 24) : null,
          prefixText: prefixText,
          helperText: helperText,
          helperStyle: const TextStyle(fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(fontSize: 16),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildProfitMarginIndicator(LanguageProvider langProvider) {
    final costo = double.tryParse(_precioCostoController.text) ?? 0;
    final venta = double.tryParse(_precioVentaController.text) ?? 0;

    if (costo > 0 && venta > 0) {
      final margen = ((venta - costo) / costo) * 100;
      final color = margen < 20
          ? AppColors.warning
          : margen < 50
              ? AppColors.info
              : AppColors.success;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.trending_up, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    langProvider.translate('profit_margin'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${margen.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoNote(LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langProvider.translate('info'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Para modificar el stock del producto, ve a la sección de Inventario y agrega o edita lotes.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeSummary(LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit, color: AppColors.warning),
              const SizedBox(width: 12),
              Text(
                langProvider.translate('unsaved_changes'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryContent(langProvider),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(LanguageProvider langProvider) {
    List<Widget> changes = [];

    if (_nombreController.text != widget.product.nombre) {
      changes.add(_buildChangeRow(langProvider.translate('product_name'), widget.product.nombre, _nombreController.text));
    }

    if (_descripcionController.text != (widget.product.descripcion ?? '')) {
      changes.add(_buildChangeRow(langProvider.translate('description'), widget.product.descripcion ?? langProvider.translate('no_category'), _descripcionController.text.isEmpty ? langProvider.translate('no_category') : _descripcionController.text));
    }

    if (_selectedCategoriaId != widget.product.categoriaId) {
      changes.add(_buildChangeRow(langProvider.translate('category'), widget.product.categoriaNombre ?? langProvider.translate('no_category'), langProvider.translate('category')));
    }

    if (_precioVentaController.text != widget.product.precioVenta.toString()) {
      changes.add(_buildChangeRow(langProvider.translate('sale_price'), '\$${widget.product.precioVenta.toStringAsFixed(2)}', '\$${_precioVentaController.text}'));
    }

    if (_selectedUnidadMedida != (widget.product.unidadMedida ?? 'unidad')) {
      changes.add(_buildChangeRow(langProvider.translate('unit'), widget.product.unidadMedidaDisplay, _selectedUnidadMedida));
    }

    return Column(children: changes);
  }

  Widget _buildChangeRow(String field, String oldValue, String newValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$field:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  oldValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.error,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  newValue,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(LanguageProvider langProvider) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      child: Row(
        children: [
          // Botón Anterior/Cancelar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentStep == 0) {
                        // Navegación segura para cancelar
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/products');
                        }
                      } else {
                        setState(() {
                          _currentStep--;
                        });
                      }
                    },
              icon: Icon(
                _currentStep == 0 ? Icons.close : Icons.arrow_back,
                size: 24,
              ),
              label: Text(
                _currentStep == 0 ? langProvider.translate('cancel') : langProvider.translate('back'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _currentStep == 0 ? AppColors.error : AppColors.primary,
                side: BorderSide(
                  color: _currentStep == 0 ? AppColors.error : AppColors.primary,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Botón Siguiente/Guardar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentStep < 2) {
                        // Validar paso actual antes de continuar
                        if (_validateCurrentStep(langProvider)) {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      } else {
                        _showSaveConfirmation();
                      }
                    },
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _currentStep < 2 ? Icons.arrow_forward : Icons.save,
                      size: 24,
                    ),
              label: Text(
                _currentStep < 2 
                    ? langProvider.translate('next')
                    : _hasChanges 
                        ? langProvider.translate('save_changes_product')
                        : langProvider.translate('unsaved_changes'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges || _currentStep < 2 
                    ? AppColors.primary 
                    : AppColors.textTertiary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep(LanguageProvider langProvider) {
    switch (_currentStep) {
      case 0:
        // Validar información básica
        if (_nombreController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('required_field')),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        return true;

      case 1:
        // Validar precios
        if (_precioVentaController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('required_field')),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        final precio = double.tryParse(_precioVentaController.text);
        if (precio == null || precio <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('invalid')),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  Future<bool> _handleBackPress() async {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      return false;
    }
    return await _handleCancel();
  }

  Future<bool> _handleCancel() async {
    if (_hasChanges) {
      return await _showUnsavedChangesDialog();
    }
    
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/products');
    }
    return true;
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final langProvider = context.read<LanguageProvider>();
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                langProvider.translate('unsaved_changes'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langProvider.translate('changes_will_be_lost'),
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              langProvider.translate('save_changes_question'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Botón para continuar editando
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.edit, size: 20),
              label: Text(
                langProvider.translate('continue_editing'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Botón para descartar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline, size: 20),
              label: Text(
                langProvider.translate('discard_changes'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showSaveConfirmation() async {
    final langProvider = context.read<LanguageProvider>();
    
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('no_data_available')),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.save, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                langProvider.translate('confirm'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              langProvider.translate('save_changes_question'),
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              langProvider.translate('unsaved_changes'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: _buildSummaryContent(langProvider),
            ),
          ],
        ),
        actions: [
          // Botón para cancelar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.cancel, size: 20),
              label: Text(
                langProvider.translate('cancel'),
                style: const TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Botón para confirmar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text(
                langProvider.translate('save'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      _updateProduct();
    }
  }

  Future<void> _scanBarcode(LanguageProvider langProvider) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(langProvider.translate('scan_barcode')),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _updateProduct() async {
    final langProvider = context.read<LanguageProvider>();
    
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
        precioCosto: _precioCostoController.text.trim().isEmpty 
            ? null 
            : double.tryParse(_precioCostoController.text),
        precioVenta: double.parse(_precioVentaController.text),
        stockMinimo: _stockMinimoController.text.trim().isEmpty 
            ? null 
            : int.tryParse(_stockMinimoController.text),
        unidadMedida: _selectedUnidadMedida,
      );

      final success = await provider.updateProduct(updatedProduct);

      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    langProvider.translate('product_updated'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );

        // Navegación segura al salir después de guardar
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/products');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.error ?? langProvider.translate('error_updating_product'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${langProvider.translate('unexpected_error')}: $e',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
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
    _precioCostoController.dispose();
    _precioVentaController.dispose();
    _stockMinimoController.dispose();
    super.dispose();
  }
}