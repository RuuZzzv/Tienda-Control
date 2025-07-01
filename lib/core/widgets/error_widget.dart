// lib/core/widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../providers/language_provider.dart';

class CustomErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? title;
  final String? retryText;
  final bool showDetails;
  final Widget? customAction;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title,
    this.retryText,
    this.showDetails = true,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: AppSizes.paddingL),
            _buildTitle(languageProvider),
            if (showDetails) ...[
              const SizedBox(height: AppSizes.paddingM),
              _buildErrorMessage(),
            ],
            const SizedBox(height: AppSizes.paddingXL),
            _buildActions(context, languageProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.error.withOpacity(0.8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(LanguageProvider languageProvider) {
    return Text(
      title ?? languageProvider.translate('error_occurred'),
      style: const TextStyle(
        fontSize: AppSizes.textXL,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
        ),
      ),
      child: Text(
        _formatErrorMessage(error),
        style: const TextStyle(
          fontSize: AppSizes.textM,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActions(BuildContext context, LanguageProvider languageProvider) {
    if (customAction != null) {
      return customAction!;
    }

    if (onRetry == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(
            retryText ?? languageProvider.translate('retry'),
            style: const TextStyle(fontSize: AppSizes.textM),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingXL,
              vertical: AppSizes.paddingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(
            languageProvider.translate('go_back'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.textM,
            ),
          ),
        ),
      ],
    );
  }

  String _formatErrorMessage(String error) {
    // Eliminar información técnica del error para el usuario
    if (error.contains('Exception:')) {
      return error.split('Exception:').last.trim();
    }
    if (error.contains('Error:')) {
      return error.split('Error:').last.trim();
    }
    
    // Traducir errores comunes
    final errorTranslations = {
      'Network error': 'Error de conexión a internet',
      'Connection timeout': 'Tiempo de conexión agotado',
      'Server error': 'Error del servidor',
      'Permission denied': 'Permiso denegado',
      'Not found': 'No encontrado',
      'Invalid data': 'Datos inválidos',
    };
    
    for (final entry in errorTranslations.entries) {
      if (error.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return error;
  }
}

// Widget especializado para errores de red
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return CustomErrorWidget(
      error: languageProvider.translate('check_internet_connection'),
      icon: Icons.wifi_off,
      title: languageProvider.translate('no_connection'),
      onRetry: onRetry,
      showDetails: false,
    );
  }
}

// lib/core/widgets/error_widget.dart - SECCIÓN CORREGIDA

// Widget especializado para errores de permisos
class PermissionErrorWidget extends StatelessWidget {
  final String permission;
  final VoidCallback? onRequestPermission;
  
  const PermissionErrorWidget({
    super.key,
    required this.permission,
    this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    return CustomErrorWidget(
      // OPCIÓN 1: Usar translateWithParams que ya tienes en tu LanguageProvider
      error: languageProvider.translateWithParams(
        'permission_required_for', 
        {'permission': permission}
      ),
      
      // OPCIÓN 2: Construir el mensaje manualmente
      // error: '${languageProvider.translate('permission_required_for')} $permission',
      
      icon: Icons.lock_outline,
      title: languageProvider.translate('permission_required'),
      customAction: Column(
        children: [
          ElevatedButton.icon(
            onPressed: onRequestPermission,
            icon: const Icon(Icons.settings),
            label: Text(languageProvider.translate('grant_permission')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXL,
                vertical: AppSizes.paddingM,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(languageProvider.translate('maybe_later')),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar errores inline (no ocupa toda la pantalla)
class InlineErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final bool compact;
  
  const InlineErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.containerRadius),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppSizes.iconM,
            ),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: AppSizes.textS,
                ),
              ),
            ),
            if (onRetry != null)
              IconButton(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                color: AppColors.error,
                iconSize: AppSizes.iconM,
              ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: AppSizes.iconL,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('error'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        fontSize: AppSizes.textM,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      error,
                      style: TextStyle(
                        color: AppColors.error.withOpacity(0.8),
                        fontSize: AppSizes.textS,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSizes.paddingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: AppSizes.iconS),
                label: Text(languageProvider.translate('try_again')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}