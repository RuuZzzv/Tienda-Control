// lib/features/inventory/screens/add_lote_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/inventory_provider.dart';
import '../../products/providers/products_provider.dart';
import '../../products/models/product.dart';
import '../../products/models/product_extensions.dart';
import '../../products/models/lote.dart';
import '../../../core/constants/app_colors.dart';
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
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.preselectedProduct;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProductsAndShowDialog();
    });
  }

  void _checkProductsAndShowDialog() {
    final productsProvider = context.read<ProductsProvider>();
    
    if (widget.preselectedProduct == null && productsProvider.products.isEmpty) {
      Future.microtask(() => _showNoProductsDialog());
    }
  }

  void _showNoProductsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay productos registrados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para agregar un lote, primero debes registrar al menos un producto.',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            SizedBox(height: 16),
            Text(
              '¿Qué te gustaría hacer?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.go('/add-product');
              },
              icon: const Icon(Icons.add_circle, size: 20),
              label: const Text(
                'Agregar Primer Producto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.go('/inventory');
              },
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text(
                'Volver al Inventario',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Agregar Nuevo Lote',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
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
              context.go('/inventory');
            }
          },
        ),
        actions: [
          if (_currentStep == 2) // Solo mostrar en el último paso
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _isLoading ? null : _saveLote,
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
                label: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
              _buildStepIndicator(0, 'Información\nBásica', Icons.info),
              _buildStepLine(0),
              _buildStepIndicator(1, 'Producto', Icons.inventory_2),
              _buildStepLine(1),
              _buildStepIndicator(2, 'Detalles\nFinales', Icons.summarize),
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
        return 'Paso 1: Información del Lote';
      case 1:
        return 'Paso 2: Selección de Producto';
      case 2:
        return 'Paso 3: Detalles Finales';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildProductSelectionStep();
      case 2:
        return _buildFinalDetailsStep();
      default:
        return Container();
    }
  }

  // PASO 1: Información Básica del Lote
  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        // Número de lote (OPCIONAL)
        _buildLargeTextField(
          controller: _numeroLoteController,
          label: 'Número de Lote (Opcional)',
          hint: 'Ej: ABC123, LOT-001',
          icon: Icons.batch_prediction,
          helperText: 'Se genera automáticamente si está vacío',
        ),

        const SizedBox(height: 20),

        // Cantidad (OBLIGATORIO)
        _buildLargeTextField(
          controller: _cantidadController,
          label: 'Cantidad',
          hint: '0',
          icon: Icons.inventory,
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La cantidad es obligatoria';
            }
            if (int.tryParse(value) == null) {
              return 'Ingrese una cantidad válida';
            }
            if (int.parse(value) <= 0) {
              return 'La cantidad debe ser mayor a cero';
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // Fecha de vencimiento
        _buildExpirationSection(),
      ],
    );
  }

  // PASO 2: Selección de Producto
  Widget _buildProductSelectionStep() {
    return Column(
      children: [
        if (widget.preselectedProduct != null) ...[
          // Producto preseleccionado
          _buildPreselectedProductCard(),
        ] else ...[
          // Selector de producto
          _buildProductSelectorSection(),
        ],
      ],
    );
  }

  // PASO 3: Detalles Finales
  Widget _buildFinalDetailsStep() {
    return Column(
      children: [
        // Precio de compra (OPCIONAL)
        _buildLargeTextField(
          controller: _precioCompraController,
          label: 'Precio de Compra (Opcional)',
          hint: '0.00',
          icon: Icons.attach_money,
          prefixText: '\$ ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          helperText: 'Precio específico de este lote',
        ),

        const SizedBox(height: 24),

        // Observaciones (OPCIONAL)
        _buildLargeTextField(
          controller: _notasController,
          label: 'Observaciones (Opcional)',
          hint: 'Notas sobre este lote...',
          icon: Icons.note,
          maxLines: 3,
        ),

        const SizedBox(height: 32),

        // Resumen del lote
        _buildSummarySection(),
      ],
    );
  }

  Widget _buildPreselectedProductCard() {
    final product = widget.preselectedProduct!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
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
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Producto Preseleccionado',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Código: ${product.codigoDisplay}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Stock: ${product.stockActualSafe} ${product.unidadMedidaDisplay}',
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
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelectorSection() {
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
              const Row(
                children: [
                  Icon(Icons.inventory_2, size: 28, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    'Seleccionar Producto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (provider.products.isEmpty) ...[
                // No hay productos
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay productos disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Agrega un producto primero',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Dropdown de productos
                DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(
                    hintText: 'Seleccionar producto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                  items: provider.products.map((product) {
                    return DropdownMenuItem<Product>(
                      value: product,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Stock: ${product.stockActualSafe} ${product.unidadMedidaDisplay}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (product) {
                    setState(() {
                      _selectedProduct = product;
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
                  const SizedBox(height: 20),
                  _buildSelectedProductInfo(_selectedProduct!),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedProductInfo(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Producto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Código', product.codigoDisplay),
          _buildInfoRow('Stock Actual', '${product.stockActualSafe} ${product.unidadMedidaDisplay}'),
          _buildInfoRow('Stock Mínimo', '${product.stockMinimoSafe} ${product.unidadMedidaDisplay}'),
          if (product.categoriaNombre != null)
            _buildInfoRow('Categoría', product.categoriaNombre!),
          _buildInfoRow('Precio de Venta', '\$${product.precioVenta.toStringAsFixed(2)}'),
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
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 24, color: AppColors.primary),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Fecha de Vencimiento (Opcional)',
                  style: TextStyle(
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
                        ? '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}'
                        : 'Seleccionar fecha',
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
              onPressed: () {
                setState(() {
                  _fechaVencimiento = null;
                });
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Quitar fecha'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final product = _selectedProduct ?? widget.preselectedProduct;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Resumen del Lote',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (product != null) ...[
            _buildSummaryRow('Producto', product.nombre),
            _buildSummaryRow('Código', product.codigoDisplay),
          ],
          _buildSummaryRow(
            'Número de Lote', 
            _numeroLoteController.text.isEmpty 
                ? 'Se generará automáticamente' 
                : _numeroLoteController.text
          ),
          _buildSummaryRow('Cantidad', '${_cantidadController.text} ${product?.unidadMedidaDisplay ?? 'unidades'}'),
          if (_fechaVencimiento != null)
            _buildSummaryRow(
              'Fecha de Vencimiento', 
              '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}'
            ),
          if (_precioCompraController.text.isNotEmpty)
            _buildSummaryRow('Precio de Compra', '\$${_precioCompraController.text}'),
          if (_notasController.text.isNotEmpty)
            _buildSummaryRow('Observaciones', _notasController.text),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
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
                        // Navegación segura para cancelar
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/inventory');
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
                _currentStep == 0 ? 'Cancelar' : 'Anterior',
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
                        _saveLote();
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
                _currentStep < 2 ? 'Siguiente' : 'Guardar Lote',
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
        if (_cantidadController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La cantidad es obligatoria'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        if (int.tryParse(_cantidadController.text) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingrese una cantidad válida'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        if (int.parse(_cantidadController.text) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La cantidad debe ser mayor a cero'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        return true;

      case 1:
        // Validar selección de producto
        if (_selectedProduct == null && widget.preselectedProduct == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debe seleccionar un producto'),
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

    // Validación final
    if (_cantidadController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad es obligatoria'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productsProvider = context.read<ProductsProvider>();

      final success = await productsProvider.addLote(
        product.id!,
        Lote(
          productoId: product.id!,
          numeroLote: _numeroLoteController.text.trim().isEmpty 
              ? null 
              : _numeroLoteController.text.trim(),
          cantidadInicial: int.parse(_cantidadController.text),
          cantidadActual: int.parse(_cantidadController.text),
          fechaVencimiento: _fechaVencimiento,
          precioCosto: _precioCompraController.text.trim().isEmpty 
              ? null 
              : double.tryParse(_precioCompraController.text),
          observaciones: _notasController.text.trim().isEmpty 
              ? null 
              : _notasController.text.trim(),
          activo: true,
        ),
      );

      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Lote agregado exitosamente!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );

        // Navegación segura al salir después de guardar
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/inventory');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(productsProvider.error ?? 'Error al agregar el lote'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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
                  child: Text('Error inesperado: $e'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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