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

// Contenido principal como widget const
class _POSContent extends StatelessWidget {
  const _POSContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingL),
        child: _ComingSoonMessage(),
      ),
    );
  }
}

// Mensaje de "próximamente" reutilizable
class _ComingSoonMessage extends StatelessWidget {
  const _ComingSoonMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _POSIcon(),
        const SizedBox(height: AppSizes.paddingL),
        const _POSTitle(),
        const SizedBox(height: AppSizes.paddingM),
        const _POSDescription(),
        const SizedBox(height: AppSizes.paddingXL),
        _ActionButtons(),
      ],
    );
  }
}

// Icono principal como widget const
class _POSIcon extends StatelessWidget {
  const _POSIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.point_of_sale,
        size: AppSizes.iconXXL * 2,
        color: AppColors.primary,
      ),
    );
  }
}

// Título como widget const
class _POSTitle extends StatelessWidget {
  const _POSTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Punto de Venta',
      style: TextStyle(
        fontSize: AppSizes.textXXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// Descripción como widget const
class _POSDescription extends StatelessWidget {
  const _POSDescription();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Esta función estará disponible próximamente.\nAquí podrás realizar ventas rápidas y gestionar el carrito de compras.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: AppSizes.textL,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}

// Botones de acción para preparar la UI futura
class _ActionButtons extends StatelessWidget {
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
        const SizedBox(height: AppSizes.paddingM),
        // Features preview
        const _FeaturesPreview(),
      ],
    );
  }

  static void _showFeatureInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardRadius * 2),
        ),
      ),
      builder: (context) => const _FeatureInfoSheet(),
    );
  }
}

// Preview de características futuras
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
    return Wrap(
      spacing: AppSizes.paddingM,
      runSpacing: AppSizes.paddingM,
      alignment: WrapAlignment.center,
      children: _features.map((feature) => 
        _FeatureChip(feature: feature)
      ).toList(),
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
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: feature.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
        border: Border.all(
          color: feature.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feature.icon,
            size: AppSizes.iconS,
            color: feature.color,
          ),
          const SizedBox(width: AppSizes.paddingXS),
          Text(
            feature.title,
            style: TextStyle(
              fontSize: AppSizes.textS,
              color: feature.color,
              fontWeight: FontWeight.w600,
            ),
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
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          // Título
          const Text(
            'Próximamente en POS',
            style: TextStyle(
              fontSize: AppSizes.textXL,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          // Lista de características
          const _FeaturesList(),
          const SizedBox(height: AppSizes.paddingL),
          // Botón cerrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
              ),
              child: const Text('Entendido'),
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
      mainAxisSize: MainAxisSize.min,
      children: _featureDescriptions.map((description) => 
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: AppSizes.textM,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ).toList(),
    );
  }
}