// lib/features/inventory/screens/lote_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart';
import '../../products/models/product.dart';
import '../../products/models/product_extensions.dart';
import '../../products/providers/products_provider.dart';
import '../providers/inventory_provider.dart';
import '../../../core/constants/app_colors.dart';

class LoteDetailScreen extends StatefulWidget {
  final Lote lote;
  final Product? product;

  const LoteDetailScreen({
    super.key,
    required this.lote,
    this.product,
  });

  @override
  State<LoteDetailScreen> createState() => _LoteDetailScreenState();
}

class _LoteDetailScreenState extends State<LoteDetailScreen> {
  final _observacionesController = TextEditingController();
  bool _isLoading = false;
  bool _hasChanges = false;
  late Lote _currentLote;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _currentLote = widget.lote;
    _product = widget.product;
    _observacionesController.text = _currentLote.observaciones ?? '';
    _observacionesController.addListener(_onObservacionesChanged);
    
    // Cargar producto si no se proporcionó
    if (_product == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProduct();
      });
    }
  }

  void _onObservacionesChanged() {
    final newValue = _observacionesController.text.trim();
    final originalValue = widget.lote.observaciones ?? '';
    
    if (newValue != originalValue && !_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    } else if (newValue == originalValue && _hasChanges) {
      setState(() {
        _hasChanges = false;
      });
    }
  }

  Future<void> _loadProduct() async {
    final productsProvider = context.read<ProductsProvider>();
    final product = productsProvider.products
        .where((p) => p.id == _currentLote.productoId)
        .firstOrNull;
    
    if (product != null) {
      setState(() {
        _product = product;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Detalles del Lote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (_hasChanges)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _saveChanges,
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card principal del lote
              _buildLoteMainCard(),
              
              const SizedBox(height: 20),
              
              // Información del producto
              if (_product != null) ...[
                _buildProductInfoSection(),
                const SizedBox(height: 20),
              ],
              
              // Detalles del lote
              _buildLoteDetailsSection(),
              
              const SizedBox(height: 20),
              
              // Estado del lote
              _buildLoteStatusSection(),
              
              const SizedBox(height: 20),
              
              // Observaciones editables
              _buildObservacionesSection(),
              
              const SizedBox(height: 32),
              
              // Acciones del lote
              _buildActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoteMainCard() {
    final isExpiringSoon = _currentLote.fechaVencimiento != null &&
        _currentLote.fechaVencimiento!.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        );
    
    final isExpired = _currentLote.fechaVencimiento != null &&
        _currentLote.fechaVencimiento!.isBefore(DateTime.now());

    Color statusColor = AppColors.success;
    IconData statusIcon = Icons.check_circle;
    String statusText = 'Activo';

    if (isExpired) {
      statusColor = AppColors.error;
      statusIcon = Icons.warning;
      statusText = 'Vencido';
    } else if (isExpiringSoon) {
      statusColor = AppColors.warning;
      statusIcon = Icons.access_time;
      statusText = 'Próximo a vencer';
    } else if (!_currentLote.activo) {
      statusColor = AppColors.textTertiary;
      statusIcon = Icons.block;
      statusText = 'Inactivo';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory,
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentLote.numeroLoteDisplay,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
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
          const SizedBox(height: 16),
          // Stock actual destacado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Actual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${_currentLote.cantidadActual} ${_product?.unidadMedidaDisplay ?? 'unidades'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoSection() {
    if (_product == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.inventory_2, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Información del Producto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nombre', _product!.nombre),
          _buildInfoRow('Código', _product!.codigoDisplay),
          _buildInfoRow('Stock Total', '${_product!.stockActualSafe} ${_product!.unidadMedidaDisplay}'),
          if (_product!.categoriaNombre != null)
            _buildInfoRow('Categoría', _product!.categoriaNombre!),
          _buildInfoRow('Precio de Venta', '\$${_product!.precioVenta.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildLoteDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Detalles del Lote',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Cantidad Inicial', '${_currentLote.cantidadInicial} ${_product?.unidadMedidaDisplay ?? 'unidades'}'),
          _buildInfoRow('Cantidad Actual', '${_currentLote.cantidadActual} ${_product?.unidadMedidaDisplay ?? 'unidades'}'),
          _buildInfoRow('Cantidad Vendida', '${_currentLote.cantidadInicial - _currentLote.cantidadActual} ${_product?.unidadMedidaDisplay ?? 'unidades'}'),
          if (_currentLote.precioCosto != null)
            _buildInfoRow('Precio de Compra', '\$${_currentLote.precioCosto!.toStringAsFixed(2)}'),
          if (_currentLote.fechaVencimiento != null)
            _buildInfoRow('Fecha de Vencimiento', _formatDate(_currentLote.fechaVencimiento!)),
          _buildInfoRow('Fecha de Creación', _formatDate(_currentLote.fechaIngreso ?? DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildLoteStatusSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Estado del Lote',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentLote.activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _currentLote.activo ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _currentLote.activo,
                onChanged: _toggleLoteStatus,
                activeColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObservacionesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.note, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Observaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              hintText: 'Agregar observaciones sobre este lote...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 4,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        if (_hasChanges) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveChanges,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 24),
              label: const Text(
                'Guardar Cambios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Botón para ver movimientos del lote (funcionalidad futura)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar vista de movimientos del lote
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ver movimientos del lote - Próximamente'),
                ),
              );
            },
            icon: const Icon(Icons.history, size: 24),
            label: const Text(
              'Ver Movimientos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _toggleLoteStatus(bool value) {
    setState(() {
      _currentLote = _currentLote.copyWith(activo: value);
      _hasChanges = true;
    });
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning, size: 28),
            SizedBox(width: 12),
            Text('Cambios sin guardar'),
          ],
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres descartar los cambios?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Continuar editando',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Descartar cambios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productsProvider = context.read<ProductsProvider>();
      
      final updatedLote = _currentLote.copyWith(
        observaciones: _observacionesController.text.trim().isEmpty 
            ? null 
            : _observacionesController.text.trim(),
      );

      final success = await productsProvider.updateLote(updatedLote);

      if (success && mounted) {
        setState(() {
          _hasChanges = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Lote actualizado exitosamente!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(productsProvider.error ?? 'Error al actualizar el lote'),
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
    _observacionesController.dispose();
    super.dispose();
  }
}