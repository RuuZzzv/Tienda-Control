// lib/features/dashboard/widgets/quick_actions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class QuickActionsWidget extends StatelessWidget {
  final LanguageProvider languageProvider;
  
  const QuickActionsWidget({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('quick_actions'),
          style: const TextStyle(
            fontSize: AppSizes.textXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                title: languageProvider.translate('new_sale'),
                icon: Icons.point_of_sale,
                color: AppColors.success,
                onTap: () => context.go('/pos'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _QuickActionButton(
                title: languageProvider.translate('add_product'),
                icon: Icons.add_circle,
                color: AppColors.primary,
                onTap: () => context.push('/add-product'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                title: languageProvider.translate('inventory'),
                icon: Icons.inventory_2,
                color: AppColors.accent,
                onTap: () => context.go('/inventory'),
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: _QuickActionButton(
                title: languageProvider.translate('reports'),
                icon: Icons.analytics,
                color: AppColors.info,
                onTap: () => context.go('/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 80,
          ),
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconXL,
                  color: color,
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingS),
              
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSizes.textL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}