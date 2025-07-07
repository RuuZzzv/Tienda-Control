// lib/features/inventory/widgets/lote_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../products/models/lote.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

// Widget optimizado que memoriza cálculos costosos
class LoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback onTap;
  final VoidCallback? onAdjust;
  final bool showProductName;
  
  // Cache de formatters estáticos para evitar recrearlos
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  const LoteCard({
    super.key,
    required this.lote,
    required this.onTap,
    this.onAdjust,
    this.showProductName = true,
  });

  @override
  Widget build(BuildContext context) {
    // Pre-calcular valores una sola vez
    final statusColor = _getStatusColor();
    final shouldHighlight = _shouldHighlight();
    final shouldShowBadge = _shouldShowUrgentBadge();
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: shouldHighlight
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: statusColor, width: 2),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Importante para evitar espacio innecesario
            children: [
              // Fila principal con información del lote
              _buildMainRow(statusColor, shouldShowBadge),
              
              // Información de vencimiento y acciones
              const SizedBox(height: AppSizes.paddingM),
              _buildExpirationRow(),

              // Notas (solo si existen)
              if (lote.observaciones != null && lote.observaciones!.isNotEmpty)
                _buildNotesSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget separado para la fila principal
  Widget _buildMainRow(Color statusColor, bool shouldShowBadge) {
    return Row(
      children: [
        // Icono del lote - Widget sin estado
        _StatusIcon(
          color: statusColor,
          icon: _getStatusIcon(),
        ),
        const SizedBox(width: AppSizes.paddingM),

        // Información del lote
        Expanded(
          child: _LoteInfo(
            productName: showProductName ? lote.productoNombre : null,
            loteNumber: lote.numeroLote ?? lote.codigoLoteInterno ?? '',
            ingressDate: lote.fechaIngreso != null 
                ? _dateFormat.format(lote.fechaIngreso!) 
                : 'Fecha no disponible', // Manejo de nulos
            shouldShowBadge: shouldShowBadge,
            badgeText: shouldShowBadge ? _getUrgentBadgeText() : '',
            badgeColor: statusColor,
          ),
        ),

        // Cantidad actual
        _QuantityDisplay(
          currentQuantity: lote.cantidadActual,
          initialQuantity: lote.cantidadInicial,
          hasStock: lote.cantidadActual > 0, // Cambiado a verificar cantidadActual
        ),
      ],
    );
  }

  // Widget separado para la fila de vencimiento
  Widget _buildExpirationRow() {
    final expirationColor = _getExpirationColor();
    final expirationText = _getExpirationText();
    
    return Row(
      children: [
        // Información de vencimiento
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                size: AppSizes.iconS,
                color: expirationColor,
              ),
              const SizedBox(width: AppSizes.paddingXS),
              Expanded(
                child: Text(
                  expirationText,
                  style: TextStyle(
                    fontSize: AppSizes.textS,
                    color: expirationColor,
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
        if (onAdjust != null && lote.cantidadActual > 0) // Cambiado a verificar cantidadActual
          IconButton(
            onPressed: onAdjust,
            icon: const Icon(Icons.edit),
            color: AppColors.accent,
            tooltip: 'Ajustar Stock',
            padding: const EdgeInsets.all(8), // Padding reducido
            constraints: const BoxConstraints(), // Sin constraints mínimos
          ),
        
        // Indicador de navegación
        const Icon(
          Icons.arrow_forward_ios,
          size: AppSizes.iconS,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  // Widget separado para las notas
  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.paddingS),
      child: _NotesBox(notes: lote.observaciones!), // Cambiado a observaciones
    );
  }

  // Métodos de cálculo optimizados
  Color _getStatusColor() {
    if (lote.cantidadActual <= 0 || lote.estaVencido) return AppColors.error; // Cambiado a verificar cantidadActual
    if (lote.proximoAVencer) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (lote.cantidadActual <= 0) return Icons.remove_circle; // Cambiado a verificar cantidadActual
    if (lote.estaVencido) return Icons.dangerous;
    if (lote.proximoAVencer) return Icons.warning;
    return Icons.batch_prediction;
  }

  bool _shouldHighlight() => lote.estaVencido || lote.proximoAVencer;

  bool _shouldShowUrgentBadge() => 
      (lote.estaVencido || lote.proximoAVencer) && lote.cantidadActual > 0; // Cambiado a verificar cantidadActual

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
      return 'Vencido el ${_dateFormat.format(lote.fechaVencimiento!)}';
    }
    
    if (lote.proximoAVencer) {
      final dias = lote.fechaVencimiento!.difference(DateTime.now()).inDays; // Cambiado a calcular días restantes
      switch (dias) {
        case 0:
          return 'Vence hoy';
        case 1:
          return 'Vence mañana';
        default:
          return 'Vence en $dias días';
      }
    }
    
    return 'Vence ${_dateFormat.format(lote.fechaVencimiento!)}';
  }
}

// Widget separado para el icono de estado (sin reconstrucciones innecesarias)
class _StatusIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _StatusIcon({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: Icon(
        icon,
        size: AppSizes.iconL,
        color: color,
      ),
    );
  }
}

// Widget separado para la información del lote
class _LoteInfo extends StatelessWidget {
  final String? productName;
  final String loteNumber;
  final String ingressDate;
  final bool shouldShowBadge;
  final String badgeText;
  final Color badgeColor;

  const _LoteInfo({
    required this.productName,
    required this.loteNumber,
    required this.ingressDate,
    required this.shouldShowBadge,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (productName != null) ...[
          Text(
            productName!,
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
                'Lote: $loteNumber',
                style: const TextStyle(
                  fontSize: AppSizes.textM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (shouldShowBadge)
              _UrgentBadge(
                text: badgeText,
                color: badgeColor,
              ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          'Ingreso: $ingressDate',
          style: const TextStyle(
            fontSize: AppSizes.textS,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// Widget separado para el badge urgente
class _UrgentBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _UrgentBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.containerRadius),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppSizes.textXS,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget separado para mostrar cantidad
class _QuantityDisplay extends StatelessWidget {
  final int currentQuantity;
  final int initialQuantity;
  final bool hasStock;

  const _QuantityDisplay({
    required this.currentQuantity,
    required this.initialQuantity,
    required this.hasStock,
  });

  @override
  Widget build(BuildContext context) {
    final color = hasStock ? AppColors.success : AppColors.error;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.containerRadius),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Text(
            '$currentQuantity',
            style: TextStyle(
              fontSize: AppSizes.textXL,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          'de $initialQuantity',
          style: const TextStyle(
            fontSize: AppSizes.textS,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// Widget separado para las notas
class _NotesBox extends StatelessWidget {
  final String notes;

  const _NotesBox({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              notes,
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
    );
  }
}