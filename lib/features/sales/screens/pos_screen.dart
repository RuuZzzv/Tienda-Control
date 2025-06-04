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
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Carrito de compras'),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.point_of_sale,
                size: AppSizes.iconXXL * 2,
                color: AppColors.primary,
              ),
              SizedBox(height: AppSizes.paddingL),
              Text(
                'Punto de Venta',
                style: TextStyle(
                  fontSize: AppSizes.textXXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSizes.paddingM),
              Text(
                'Esta función estará disponible próximamente.\nAquí podrás realizar ventas rápidas y gestionar el carrito de compras.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.textL,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}