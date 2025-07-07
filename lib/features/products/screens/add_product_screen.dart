// lib/features/products/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/extensions/build_context_extensions.dart';

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
  final _precioCostoController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _cantidadInicialController = TextEditingController();
  final _observacionesController = TextEditingController();

  int? _selectedCategoriaId;
  String _selectedUnidadMedida = 'unidad';
  DateTime? _fechaVencimiento;
  bool _isLoading = false;
  bool _hasChanges = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadCategorias();
    });
    
    // Listeners para detectar cambios
    _nombreController.addListener(_onFieldChanged);
    _descripcionController.addListener(_onFieldChanged);
    _codigoBarrasController.addListener(_onFieldChanged);
    _precioCostoController.addListener(_onFieldChanged);
    _precioVentaController.addListener(_onFieldChanged);
    _stockMinimoController.addListener(_onFieldChanged);
    _cantidadInicialController.addListener(_onFieldChanged);
    _observacionesController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onCategoryChanged(int? value) {
    setState(() {
      _selectedCategoriaId = value;
      _hasChanges = true;
    });
  }

  void _onUnitChanged(String value) {
    setState(() {
      _selectedUnidadMedida = value;
      _hasChanges = true;
    });
  }

  void _onDateChanged(DateTime? date) {
    setState(() {
      _fechaVencimiento = date;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
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
                  _buildProgressIndicator(),

                  // Contenido del paso actual
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildCurrentStep(),
                    ),
                  ),

                  // Botones de navegación
                  _buildNavigationButtons(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        context.tr('add_product'),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _handleCancel(),
      ),
      actions: [
        if (_currentStep == 2) // Solo mostrar en el último paso
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
                context.tr('save'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildStepIndicator(0, context.tr('basic_information'), Icons.info),
              _buildStepLine(0),
              _buildStepIndicator(1, context.tr('pricing'), Icons.attach_money),
              _buildStepLine(1),
              _buildStepIndicator(2, context.tr('stock_configuration'), Icons.inventory),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(),
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

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return context.tr('product_information');
      case 1:
        return context.tr('price_information');
      case 2:
        return context.tr('stock_information');
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildPricesStep();
      case 2:
        return _buildStockStep();
      default:
        return Container();
    }
  }

  // PASO 1: Información Básica
  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        // Nombre del producto (OBLIGATORIO)
        _buildLargeTextField(
          controller: _nombreController,
          label: context.tr('product_name'),
          hint: 'Rice 1kg / Riso 1kg / Arroz 1kg',
          icon: Icons.inventory_2,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.tr('required_field');
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Descripción
        _buildLargeTextField(
          controller: _descripcionController,
          label: '${context.tr('product_description')} (${context.tr('optional_field')})',
          hint: context.tr('product_description'),
          icon: Icons.description,
          maxLines: 3,
        ),

        const SizedBox(height: 24),

        // Categoría
        _buildCategorySection(),

        const SizedBox(height: 24),

        // Código de barras
        _buildBarcodeSection(),
      ],
    );
  }

  // PASO 2: Precios
  Widget _buildPricesStep() {
    return Column(
      children: [
        // Precio de venta (OBLIGATORIO)
        _buildLargeTextField(
          controller: _precioVentaController,
          label: context.tr('sale_price'),
          hint: '0.00',
          icon: Icons.sell,
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.tr('required_field');
            }
            final precio = double.tryParse(value);
            if (precio == null || precio <= 0) {
              return context.tr('invalid');
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Precio de compra (OPCIONAL)
        _buildLargeTextField(
          controller: _precioCostoController,
          label: '${context.tr('purchase_price')} (${context.tr('optional_field')})',
          hint: '0.00',
          icon: Icons.shopping_cart,
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          helperText: context.tr('profit_margin'),
        ),

        const SizedBox(height: 24),

        // Indicador de margen
        if (_precioCostoController.text.isNotEmpty &&
            _precioVentaController.text.isNotEmpty)
          _buildProfitMarginIndicator(),
      ],
    );
  }

  // PASO 3: Stock Inicial
  Widget _buildStockStep() {
    return Column(
      children: [
        // Cantidad inicial (OBLIGATORIO)
        _buildLargeTextField(
          controller: _cantidadInicialController,
          label: context.tr('initial_quantity'),
          hint: '0',
          icon: Icons.inventory,
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.tr('required_field');
            }
            final cantidad = int.tryParse(value);
            if (cantidad == null || cantidad < 0) {
              return context.tr('invalid');
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Unidad de medida
        _buildUnitSection(),

        const SizedBox(height: 24),

        // Stock mínimo
        _buildLargeTextField(
          controller: _stockMinimoController,
          label: '${context.tr('minimum_stock')} (${context.tr('optional_field')})',
          hint: '5',
          icon: Icons.warning,
          keyboardType: TextInputType.number,
          helperText: context.tr('low_stock_warning'),
        ),

        const SizedBox(height: 24),

        // Fecha de vencimiento
        _buildExpirationSection(),

        const SizedBox(height: 24),

        // Observaciones
        _buildLargeTextField(
          controller: _observacionesController,
          label: '${context.tr('notes')} (${context.tr('optional_field')})',
          hint: context.tr('observations'),
          icon: Icons.note,
          maxLines: 3,
        ),

        const SizedBox(height: 32),

        // Resumen del producto
        _buildProductSummary(),
      ],
    );
  }

  Widget _buildProductSummary() {
    if (_nombreController.text.isEmpty && _precioVentaController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                context.tr('product_details'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryContent(),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Column(
      children: [
        if (_nombreController.text.isNotEmpty)
          _buildSummaryRow(context.tr('product_name'), _nombreController.text),
        if (_descripcionController.text.isNotEmpty)
          _buildSummaryRow(context.tr('description'), _descripcionController.text),
        if (_precioVentaController.text.isNotEmpty)
          _buildSummaryRow(context.tr('sale_price'), '\$${_precioVentaController.text}'),
        if (_precioCostoController.text.isNotEmpty)
          _buildSummaryRow(context.tr('purchase_price'), '\$${_precioCostoController.text}'),
        if (_cantidadInicialController.text.isNotEmpty)
          _buildSummaryRow(context.tr('initial_quantity'), '${_cantidadInicialController.text} $_selectedUnidadMedida'),
        if (_stockMinimoController.text.isNotEmpty)
          _buildSummaryRow(context.tr('minimum_stock'), '${_stockMinimoController.text} $_selectedUnidadMedida'),
        if (_fechaVencimiento != null)
          _buildSummaryRow(context.tr('expiration_date'), context.formatDate(_fechaVencimiento!)),
        if (_observacionesController.text.isNotEmpty)
          _buildSummaryRow(context.tr('observations'), _observacionesController.text),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
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

  Widget _buildCategorySection() {
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
                    '${context.tr('category')} (${context.tr('optional_field')})',
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
                  hintText: context.tr('select_category'),
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

  Widget _buildBarcodeSection() {
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
                  '${context.tr('barcode')} (${context.tr('optional_field')})',
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
                  onPressed: _scanBarcode,
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

  Widget _buildUnitSection() {
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
                context.tr('unit_measure'),
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

  Widget _buildExpirationSection() {
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
              const Icon(Icons.calendar_today, size: 24, color: AppColors.primary),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '${context.tr('expiration_date')} (${context.tr('optional_field')})',
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
          InkWell(
            onTap: _selectExpirationDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _fechaVencimiento != null
                        ? context.formatDate(_fechaVencimiento!)
                        : context.tr('select_date'),
                    style: TextStyle(
                      fontSize: 16,
                      color: _fechaVencimiento != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  Icon(
                    _fechaVencimiento != null
                        ? Icons.edit_calendar
                        : Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_fechaVencimiento != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _onDateChanged(null),
              icon: const Icon(Icons.clear, size: 18),
              label: Text(context.tr('remove_date')),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfitMarginIndicator() {
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
                    context.tr('profit_margin'),
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

  Widget _buildNavigationButtons() {
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
                        _handleCancel();
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
                _currentStep == 0 ? context.tr('cancel') : context.tr('back'),
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
                        if (_validateCurrentStep()) {
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
                _currentStep < 2 ? context.tr('next') : context.tr('create_product'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Validar información básica
        if (_nombreController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('required_field')),
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
              content: Text(context.tr('required_field')),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        final precio = double.tryParse(_precioVentaController.text);
        if (precio == null || precio <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('invalid')),
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
                context.tr('unsaved_changes_product'),
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
              context.tr('changes_will_be_lost'),
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('save_changes_question'),
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
                context.tr('continue_editing'),
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
                context.tr('discard_changes'),
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
    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_circle, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('create_product'),
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
              context.tr('confirm'),
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('product_details'),
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
              child: _buildSummaryContent(),
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
                context.tr('cancel'),
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
                context.tr('create_product'),
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
      _saveProduct();
    }
  }

  Future<void> _scanBarcode() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('scan_barcode')),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      _onDateChanged(date);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación final completa
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('required_field')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_precioVentaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('required_field')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_cantidadInicialController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('required_field')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
        precioCosto: _precioCostoController.text.trim().isEmpty
            ? null
            : double.tryParse(_precioCostoController.text),
        precioVenta: double.parse(_precioVentaController.text),
        stockMinimo: _stockMinimoController.text.trim().isEmpty
            ? null
            : int.tryParse(_stockMinimoController.text),
        unidadMedida: _selectedUnidadMedida,
      );

      final cantidadInicial = int.tryParse(_cantidadInicialController.text) ?? 0;
      final observaciones = _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim();

      final success = await provider.addProductWithInitialStock(
        product: product,
        numeroLote: null, // Se genera automáticamente
        cantidadInicial: cantidadInicial,
        fechaVencimiento: _fechaVencimiento,
        observaciones: observaciones,
      );

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
                    context.tr('product_created'),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navegar de vuelta
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
                    provider.error ?? context.tr('error_creating_product'),
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
                    '${context.tr('unexpected_error')}: $e',
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
    _cantidadInicialController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }
}