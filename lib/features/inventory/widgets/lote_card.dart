// lib/features/inventory/widgets/lote_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../products/models/lote.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class LoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback onTap;
  final VoidCallback? onAdjust;
  final bool showProductName;

  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
    this.onAdjust,
    this.showProductName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: _shouldHighlight() 
                ? Border.all(color: _getStatusColor(), width: 2)
                : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Icono del lote con estado
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      size: AppSizes.iconL,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),

                  // Información del lote
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showProductName && lote.productoNombre != null) ...[
                          Text(
                            lote.productoNombre!,
                            style: const TextStyle(
                              fontSize: AppSizes.textL,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSizes.paddingXS),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Lote: ${lote.numeroLote ?? lote.codigoLoteInterno}',
                                style: const TextStyle(
                                  fontSize: AppSizes.textM,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_shouldShowUrgentBadge())
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingS,
                                  vertical: AppSizes.paddingXS,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                                ),
                                child: Text(
                                  _getUrgentBadgeText(),
                                  style: const TextStyle(
                                    fontSize: AppSizes.textXS,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        Text(
                          'Ingreso: ${DateFormat('dd/MM/yyyy').format(lote.fechaIngreso)}',
                          style: const TextStyle(
                            fontSize: AppSizes.textS,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cantidad actual
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: lote.tieneStock 
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSizes.containerRadius),
                          border: Border.all(
                            color: lote.tieneStock 
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${lote.cantidadActual}',
                          style: TextStyle(
                            fontSize: AppSizes.textXL,
                            fontWeight: FontWeight.bold,
                            color: lote.tieneStock ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      Text(
                        'de ${lote.cantidadInicial}',
                        style: const TextStyle(
                          fontSize: AppSizes.textS,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Información de vencimiento y acciones
              const SizedBox(height: AppSizes.paddingM),
              Row(
                children: [
                  // Información de vencimiento
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: AppSizes.iconS,
                          color: _getExpirationColor(),
                        ),
                        const SizedBox(width: AppSizes.paddingXS),
                        Expanded(
                          child: Text(
                            _getExpirationText(),
                            style: TextStyle(
                              fontSize: AppSizes.textS,
                              color: _getExpirationColor(),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón de ajustar
                  if (onAdjust != null && lote.tieneStock)
                    IconButton(
                      onPressed: onAdjust,
                      icon: const Icon(Icons.edit),
                      color: AppColors.accent,
                      tooltip: 'Ajustar Stock',
                    ),
                  
                  // Indicador de que se puede tocar
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: AppSizes.iconS,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),

              // Notas si existen
              if (lote.notas != null && lote.notas!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingS),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.note,
                        size: AppSizes.iconS,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Expanded(
                        child: Text(
                          lote.notas!,
                          style: const TextStyle(
                            fontSize: AppSizes.textS,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (!lote.tieneStock) return AppColors.error;
    if (lote.estaVencido) return AppColors.error;
    if (lote.proximoAVencer) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (!lote.tieneStock) return Icons.remove_circle;
    if (lote.estaVencido) return Icons.dangerous;
    if (lote.proximoAVencer) return Icons.warning;
    return Icons.batch_prediction;
  }

  bool _shouldHighlight() {
    return lote.estaVencido || lote.proximoAVencer;
  }

  bool _shouldShowUrgentBadge() {
    return (lote.estaVencido || lote.proximoAVencer) && lote.tieneStock;
  }

  String _getUrgentBadgeText() {
    if (lote.estaVencido) return 'VENCIDO';
    if (lote.proximoAVencer) return 'POR VENCER';
    return '';
  }

  Color _getExpirationColor() {
    if (lote.fechaVencimiento == null) return AppColors.textTertiary;
    if (lote.estaVencido) return AppColors.error;
    if (lote.proximoAVencer) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _getExpirationText() {
    if (lote.fechaVencimiento == null) {
      return 'Sin fecha de vencimiento';
    }
    
    if (lote.estaVencido) {
      return 'Vencido el ${DateFormat('dd/MM/yyyy').format(lote.fechaVencimiento!)}';
    }
    
    if (lote.proximoAVencer) {
      final dias = lote.diasParaVencer;
      if (dias == 0) {
        return 'Vence hoy';
      } else if (dias == 1) {
        return 'Vence mañana';
      } else {
        return 'Vence en $dias días';
      }
    }
    
    return 'Vence ${DateFormat('dd/MM/yyyy').format(lote.fechaVencimiento!)}';
  }
}