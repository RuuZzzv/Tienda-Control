// lib/features/sales/screens/pos_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class POSScreen extends StatelessWidget {
  const POSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        automaticallyImplyLeading: false,
        actions: const [
          _CartButton(),
        ],
      ),
      body: const _POSContent(),
    );
  }
}

// Botón del carrito separado para futuras mejoras
class _CartButton extends StatelessWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.shopping_cart),
      onPressed: () => _showComingSoon(context, 'Carrito de compras'),
      tooltip: 'Carrito de compras',
    );
  }

  static void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Próximamente: $feature'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        ),
      ),
    );
  }
}

// Contenido principal simplificado sin conflictos de layout
class _POSContent extends StatelessWidget {
  const _POSContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                     MediaQuery.of(context).padding.top - 
                     kToolbarHeight - 
                     80, // Espacio para bottom navigation
        ),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _POSIcon(),
            SizedBox(height: AppSizes.paddingL),
            _POSTitle(),
            SizedBox(height: AppSizes.paddingM),
            _POSDescription(),
            SizedBox(height: AppSizes.paddingL),
            _ActionButtons(),
          ],
        ),
      ),
    );
  }
}

// Icono principal
class _POSIcon extends StatelessWidget {
  const _POSIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL * 1.5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.point_of_sale,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}

// Título
class _POSTitle extends StatelessWidget {
  const _POSTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Punto de Venta',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// Descripción
class _POSDescription extends StatelessWidget {
  const _POSDescription();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Text(
        'Esta función estará disponible próximamente.\nAquí podrás realizar ventas rápidas y gestionar el carrito de compras.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

// Botones de acción simplificados
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón principal
        ElevatedButton.icon(
          onPressed: () => _showFeatureInfo(context),
          icon: const Icon(Icons.info_outline),
          label: const Text('Más información'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        // Features preview usando Column en lugar de GridView
        const _FeaturesPreview(),
      ],
    );
  }

  static void _showFeatureInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => const _FeatureInfoSheet(),
    );
  }
}

// Preview de características usando Column simple
class _FeaturesPreview extends StatelessWidget {
  const _FeaturesPreview();

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.qr_code_scanner,
      title: 'Escaneo rápido',
      color: AppColors.info,
    ),
    _FeatureItem(
      icon: Icons.calculate,
      title: 'Calculadora integrada',
      color: AppColors.success,
    ),
    _FeatureItem(
      icon: Icons.receipt_long,
      title: 'Gestión de tickets',
      color: AppColors.warning,
    ),
    _FeatureItem(
      icon: Icons.payment,
      title: 'Múltiples pagos',
      color: AppColors.accent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primera fila
        Row(
          children: [
            Expanded(child: _FeatureChip(feature: _features[0])),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(child: _FeatureChip(feature: _features[1])),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        // Segunda fila
        Row(
          children: [
            Expanded(child: _FeatureChip(feature: _features[2])),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(child: _FeatureChip(feature: _features[3])),
          ],
        ),
      ],
    );
  }
}

// Modelo para características
class _FeatureItem {
  final IconData icon;
  final String title;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}

// Chip de característica
class _FeatureChip extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureChip({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: feature.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feature.icon,
            size: 24,
            color: feature.color,
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            feature.title,
            style: TextStyle(
              fontSize: 12,
              color: feature.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Bottom sheet con información de características
class _FeatureInfoSheet extends StatelessWidget {
  const _FeatureInfoSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(top: AppSizes.paddingM),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Título
          const Padding(
            padding: EdgeInsets.all(AppSizes.paddingL),
            child: Text(
              'Próximamente en POS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
              child: const _FeaturesList(),
            ),
          ),
          // Botón cerrar
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lista de características detalladas
class _FeaturesList extends StatelessWidget {
  const _FeaturesList();

  static const List<String> _featureDescriptions = [
    '• Búsqueda rápida de productos por código o nombre',
    '• Escaneo de códigos de barras con la cámara',
    '• Aplicación de descuentos por producto o total',
    '• Gestión de múltiples formas de pago',
    '• Generación e impresión de tickets',
    '• Registro de ventas diarias y reportes',
    '• Modo offline para continuar vendiendo',
    '• Calculadora integrada para cambio rápido',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _featureDescriptions.map((description) => 
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ).toList(),
    );
  }
}