// lib/core/widgets/language_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../providers/language_provider.dart';
import '../extensions/build_context_extensions.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsButton;
  final bool compact;
  final bool showTitle;
  final EdgeInsets? padding;

  const LanguageSelector({
    super.key,
    this.showAsButton = false,
    this.compact = false,
    this.showTitle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        // Mostrar loading si no está inicializado
        if (!languageProvider.isInitialized) {
          return _buildLoadingState(languageProvider);
        }
        
        if (showAsButton) {
          return _buildButton(context, languageProvider);
        } else {
          return _buildCard(context, languageProvider);
        }
      },
    );
  }

  Widget _buildLoadingState(LanguageProvider languageProvider) {
    return showAsButton ? 
      const SizedBox(width: 40, height: 40) : 
      Card(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(strokeWidth: 2)
              ),
              const SizedBox(width: 16),
              Text(languageProvider.translate('loading_language')),
            ],
          ),
        ),
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
          padding: padding ?? const EdgeInsets.all(AppSizes.paddingM),
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
                    if (showTitle)
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
      builder: (dialogContext) => Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language, 
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        langProvider.translate('select_language'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Descripción opcional
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        langProvider.translate('choose_preferred_language'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Lista de idiomas
                    ...langProvider.availableLanguages.map((language) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              try {
                                final success = await langProvider.changeLanguage(language.code);
                                if (success && dialogContext.mounted) {
                                  // Mostrar mensaje de éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        langProvider.translate('language_changed_successfully'),
                                      ),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else if (dialogContext.mounted) {
                                  // Mostrar mensaje de error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        langProvider.translate('error_changing_language'),
                                      ),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${langProvider.translate('error_changing_language')}: $e',
                                      ),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                              
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              decoration: language.isSelected ? BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ) : null,
                              child: Row(
                                children: [
                                  // Flag
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      language.flag,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Nombre del idioma
                                  Expanded(
                                    child: Text(
                                      language.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: language.isSelected 
                                            ? FontWeight.bold 
                                            : FontWeight.normal,
                                        color: language.isSelected 
                                            ? AppColors.primary 
                                            : AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  
                                  // Check icon
                                  if (language.isSelected)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  langProvider.translate('close'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}

// Widget adicional para usar como PopupMenuButton en AppBar
class LanguageSelectorPopup extends StatelessWidget {
  const LanguageSelectorPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (!languageProvider.isInitialized) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        }

        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageProvider.currentLanguageFlag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
          tooltip: languageProvider.translate('change_language'),
          onSelected: (String languageCode) async {
            try {
              final success = await languageProvider.changeLanguage(languageCode);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? languageProvider.translate('language_changed_successfully')
                          : languageProvider.translate('error_changing_language')
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(languageProvider.translate('error_changing_language')),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
          itemBuilder: (BuildContext context) {
            return languageProvider.availableLanguages.map((option) {
              return PopupMenuItem<String>(
                value: option.code,
                child: Row(
                  children: [
                    Text(
                      option.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: option.isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          color: option.isSelected 
                              ? AppColors.primary 
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (option.isSelected)
                      const Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: 18,
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}

// Widget compacto para usar en FAB o botones flotantes
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (!languageProvider.isInitialized) {
          return const CircularProgressIndicator();
        }

        return FloatingActionButton.small(
          onPressed: () => _cycleThroughLanguages(context, languageProvider),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          tooltip: languageProvider.translate('change_language'),
          child: Text(
            languageProvider.currentLanguageFlag,
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  void _cycleThroughLanguages(BuildContext context, LanguageProvider languageProvider) async {
    final languages = languageProvider.availableLanguages;
    final currentIndex = languages.indexWhere((lang) => lang.isSelected);
    final nextIndex = (currentIndex + 1) % languages.length;
    final nextLanguage = languages[nextIndex];

    try {
      final success = await languageProvider.changeLanguage(nextLanguage.code);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? languageProvider.translate('language_changed_successfully')
                  : languageProvider.translate('error_changing_language')
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.translate('error_changing_language')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}