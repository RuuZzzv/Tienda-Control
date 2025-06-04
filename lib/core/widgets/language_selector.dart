// lib/core/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsButton;
  final bool compact;

  const LanguageSelector({
    super.key,
    this.showAsButton = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (showAsButton) {
          return _buildButton(context, languageProvider);
        } else {
          return _buildCard(context, languageProvider);
        }
      },
    );
  }

  Widget _buildButton(BuildContext context, LanguageProvider languageProvider) {
    return IconButton(
      onPressed: () => _showLanguageDialog(context, languageProvider),
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            languageProvider.currentLanguageFlag,
            style: const TextStyle(fontSize: 20),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ],
      ),
      tooltip: languageProvider.translate('change_language'),
    );
  }

  Widget _buildCard(BuildContext context, LanguageProvider languageProvider) {
    return Card(
      child: InkWell(
        onTap: () => _showLanguageDialog(context, languageProvider),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                ),
                child: const Icon(
                  Icons.language,
                  color: AppColors.primary,
                  size: AppSizes.iconL,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('language'),
                      style: const TextStyle(
                        fontSize: AppSizes.textM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${languageProvider.currentLanguageFlag} ${languageProvider.currentLanguageName}',
                      style: const TextStyle(
                        fontSize: AppSizes.textL,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: AppSizes.iconS,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.language, color: AppColors.primary),
            const SizedBox(width: AppSizes.paddingS),
            Text(languageProvider.translate('select_language')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageProvider.availableLanguages.map((language) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                language.name,
                style: TextStyle(
                  fontWeight: language.isSelected ? FontWeight.bold : FontWeight.normal,
                  color: language.isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              trailing: language.isSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                languageProvider.changeLanguage(language.code);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.translate('close')),
          ),
        ],
      ),
    );
  }
}