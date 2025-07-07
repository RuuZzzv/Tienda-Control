// lib/features/products/widgets/product_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/categoria.dart';
import '../providers/products_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/language_provider.dart';

class ProductForm extends StatefulWidget {
  final Product? product; // null para crear, Product para editar
  final Function(Product) onSubmit;
  final VoidCallback? onCancel;
  final bool isEditing;
  final bool showStockFields;

  const ProductForm({
    super.key,
    this.product,
    required this.onSubmit,
    this.onCancel,
    this.isEditing = false,
    this.showStockFields = true,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores con texto más grande
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _codigoBarrasController;
  late final TextEditingController _precioCostoController;
  late final TextEditingController _precioVentaController;
  late final TextEditingController _stockMinimoController;
  late final TextEditingController _cantidadInicialController;
  
  int? _selectedCategoriaId;
  String _selectedUnidadMedida = 'unidad';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nombreController = TextEditingController(text: widget.product?.nombre ?? '');
    _descripcionController = TextEditingController(text: widget.product?.descripcion ?? '');
    _codigoBarrasController = TextEditingController(text: widget.product?.codigoBarras ?? '');
    _precioCostoController = TextEditingController(text: widget.product?.precioCosto?.toString() ?? '');
    _precioVentaController = TextEditingController(text: widget.product?.precioVenta.toString() ?? '');
    _stockMinimoController = TextEditingController(text: widget.product?.stockMinimo?.toString() ?? '5');
    _cantidadInicialController = TextEditingController(text: '0');
    
    _selectedCategoriaId = widget.product?.categoriaId;
    _selectedUnidadMedida = widget.product?.unidadMedida ?? 'unidad';
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del formulario
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  widget.isEditing ? Icons.edit : Icons.add_circle,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.isEditing 
                      ? 'Editar Producto' 
                      : 'Nuevo Producto',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información básica
          _buildSectionCard(
            title: 'Información del Producto',
            icon: Icons.inventory_2,
            children: [
              _buildLargeTextField(
                controller: _nombreController,
                label: 'Nombre del Producto',
                hint: 'Ej: Arroz Diana 1kg',
                icon: Icons.inventory_2,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              _buildLargeTextField(
                controller: _descripcionController,
                label: 'Descripción (Opcional)',
                hint: 'Descripción del producto',
                icon: Icons.description,
                maxLines: 3,
              ),
              
              const SizedBox(height: 20),
              
              _buildCategoryDropdown(),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Códigos
          _buildSectionCard(
            title: 'Códigos',
            icon: Icons.qr_code,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLargeTextField(
                      controller: _codigoBarrasController,
                      label: 'Código de Barras',
                      hint: '7701234567890',
                      icon: Icons.qr_code,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _scanBarcode,
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        size: 28,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Escanear código',
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Precios
          _buildSectionCard(
            title: 'Precios',
            icon: Icons.attach_money,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLargeTextField(
                      controller: _precioCostoController,
                      label: 'Precio de Compra',
                      hint: '0.00',
                      icon: Icons.shopping_cart,
                      prefixText: '\$ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLargeTextField(
                      controller: _precioVentaController,
                      label: 'Precio de Venta',
                      hint: '0.00',
                      icon: Icons.sell,
                      prefixText: '\$ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Precio obligatorio';
                        }
                        final precio = double.tryParse(value);
                        if (precio == null || precio <= 0) {
                          return 'Precio inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              if (_showProfitMargin()) ...[
                const SizedBox(height: 16),
                _buildProfitMarginIndicator(),
              ],
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stock (si se muestran campos de stock)
          if (widget.showStockFields)
            _buildSectionCard(
              title: 'Configuración de Stock',
              icon: Icons.inventory,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildLargeTextField(
                        controller: _stockMinimoController,
                        label: 'Stock Mínimo',
                        hint: '5',
                        icon: Icons.warning,
                        keyboardType: TextInputType.number,
                        helperText: 'Alerta cuando esté bajo',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUnitDropdown(),
                    ),
                  ],
                ),
                
                if (!widget.isEditing) ...[
                  const SizedBox(height: 20),
                  _buildLargeTextField(
                    controller: _cantidadInicialController,
                    label: 'Cantidad Inicial',
                    hint: '0',
                    icon: Icons.add_box,
                    keyboardType: TextInputType.number,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Cantidad obligatoria';
                      }
                      final cantidad = int.tryParse(value);
                      if (cantidad == null || cantidad < 0) {
                        return 'Cantidad inválida';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          
          const SizedBox(height: 32),
          
          // Botones de acción
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
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
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16),
        prefixIcon: icon != null 
            ? Icon(icon, size: 28, color: AppColors.primary) 
            : null,
        prefixText: prefixText,
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
      style: const TextStyle(fontSize: 18), // Texto más grande
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<ProductsProvider>(
      builder: (context, provider, child) {
        return DropdownButtonFormField<int?>(
          value: _selectedCategoriaId,
          decoration: InputDecoration(
            labelText: 'Categoría',
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.category,
              size: 28,
              color: AppColors.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
          ),
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Sin categoría'),
            ),
            ...provider.categorias.map((categoria) {
              return DropdownMenuItem<int?>(
                value: categoria.id,
                child: Text(categoria.nombre),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoriaId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildUnitDropdown() {
    final unidades = [
      'unidad',
      'kilogramo',
      'gramo', 
      'litro',
      'mililitro',
      'paquete',
      'caja',
      'docena',
    ];

    return DropdownButtonFormField<String>(
      value: _selectedUnidadMedida,
      decoration: InputDecoration(
        labelText: 'Unidad',
        labelStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.straighten,
          size: 28,
          color: AppColors.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.textPrimary,
      ),
      items: unidades.map((unidad) {
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
    );
  }

  Widget _buildProfitMarginIndicator() {
    final costo = double.tryParse(_precioCostoController.text) ?? 0;
    final venta = double.tryParse(_precioVentaController.text) ?? 0;
    
    if (costo > 0 && venta > 0) {
      final margen = ((venta - costo) / costo) * 100;
      final color = margen < 20 ? AppColors.warning 
                  : margen < 50 ? AppColors.info 
                  : AppColors.success;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.trending_up, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              'Margen de ganancia: ${margen.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón guardar
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    widget.isEditing ? Icons.save : Icons.add_circle,
                    size: 28,
                  ),
            label: Text(
              widget.isEditing ? 'Guardar Cambios' : 'Crear Producto',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botón cancelar
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : widget.onCancel,
            icon: const Icon(Icons.close, size: 28),
            label: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(
                color: AppColors.textSecondary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _showProfitMargin() {
    return _precioCostoController.text.isNotEmpty && 
           _precioVentaController.text.isNotEmpty;
  }

  void _scanBarcode() {
    // TODO: Implementar escáner real
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de escaneo próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: widget.product?.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty 
            ? null 
            : _descripcionController.text.trim(),
        categoriaId: _selectedCategoriaId,
        codigoBarras: _codigoBarrasController.text.trim().isEmpty 
            ? null 
            : _codigoBarrasController.text.trim(),
        precioCosto: double.tryParse(_precioCostoController.text),
        precioVenta: double.parse(_precioVentaController.text),
        stockMinimo: int.tryParse(_stockMinimoController.text),
        unidadMedida: _selectedUnidadMedida,
        activo: true,
      );

      widget.onSubmit(product);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
    super.dispose();
  }
}