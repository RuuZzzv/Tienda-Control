import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/language_provider.dart';

class LanguageSettingsWidget extends StatelessWidget {
  final bool showAdvancedOptions;
  
  const LanguageSettingsWidget({
    super.key,
    this.showAdvancedOptions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la sección
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: AppSizes.iconL,
                    ),
                    const SizedBox(width: AppSizes.paddingM),
                    Text(
                      languageProvider.translate('language_settings'),
                      style: const TextStyle(
                        fontSize: AppSizes.textXL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingM),
                
                // Idioma actual
                _buildCurrentLanguageSection(languageProvider),
                
                const SizedBox(height: AppSizes.paddingL),
                
                // Selector de idioma
                _buildLanguageSelector(context, languageProvider),
                
                if (showAdvancedOptions) ...[
                  const SizedBox(height: AppSizes.paddingL),
                  _buildAdvancedOptions(languageProvider),
                ],
                
                const SizedBox(height: AppSizes.paddingM),
                
                // Información adicional
                _buildLanguageInfo(languageProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentLanguageSection(LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                languageProvider.currentLanguageFlag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.translate('current_language'),
                  style: const TextStyle(
                    fontSize: AppSizes.textS,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  languageProvider.currentLanguageName,
                  style: const TextStyle(
                    fontSize: AppSizes.textL,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: AppSizes.iconM,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('available_languages'),
          style: const TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        ...languageProvider.availableLanguages.map((language) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                onTap: language.isSelected ? null : () async {
                  final success = await languageProvider.changeLanguage(language.code);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          languageProvider.translate('language_changed_successfully'),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: language.isSelected 
                          ? AppColors.primary 
                          : AppColors.border,
                      width: language.isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                    color: language.isSelected 
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Text(
                        language.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: Text(
                          language.name,
                          style: TextStyle(
                            fontSize: AppSizes.textM,
                            fontWeight: language.isSelected 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            color: language.isSelected 
                                ? AppColors.primary 
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (language.isSelected)
                        Icon(
                          Icons.radio_button_checked,
                          color: AppColors.primary,
                          size: AppSizes.iconM,
                        )
                      else
                        Icon(
                          Icons.radio_button_unchecked,
                          color: AppColors.textTertiary,
                          size: AppSizes.iconM,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdvancedOptions(LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('advanced'),
          style: const TextStyle(
            fontSize: AppSizes.textL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        
        // Formato de fecha
        _buildFormatOption(
          languageProvider,
          Icons.calendar_today,
          'date_format',
          languageProvider.formatDate(DateTime.now()),
        ),
        
        // Formato de hora
        _buildFormatOption(
          languageProvider,
          Icons.access_time,
          'time_format',
          languageProvider.formatTime(DateTime.now()),
        ),
        
        // Código de idioma
        _buildFormatOption(
          languageProvider,
          Icons.code,
          'language_code',
          languageProvider.currentLanguage.toUpperCase(),
        ),
      ],
    );
  }

  Widget _buildFormatOption(
    LanguageProvider languageProvider,
    IconData icon,
    String labelKey,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingS),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconS,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.paddingS),
          Text(
            languageProvider.translate(labelKey),
            style: const TextStyle(
              fontSize: AppSizes.textM,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageInfo(LanguageProvider languageProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: AppSizes.iconM,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageProvider.translate('language_will_be_saved'),
                  style: const TextStyle(
                    fontSize: AppSizes.textS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}