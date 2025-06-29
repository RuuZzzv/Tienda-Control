// lib/core/widgets/error_widget.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final IconData icon;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: AppSizes.paddingL),
            const Text(
              'Oops! Algo salió mal',
              style: TextStyle(
                fontSize: AppSizes.textXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              error,
              style: const TextStyle(
                fontSize: AppSizes.textM,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingXL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingXL,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}