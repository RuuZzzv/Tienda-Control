// lib/features/inventory/widgets/simple_lote_card.dart - SIMPLIFICADO PARA ADULTOS MAYORES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../products/models/lote.dart';
import '../../products/models/lote_extensions.dart';
import '../../../core/constants/app_colors.dart';

class SimpleLoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback? onTap;
  final VoidCallback? onAdjustStock;
  final VoidCallback? onMarkExpired;
  final bool showProductName;
  final bool isCompact;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  const SimpleLoteCard({
    super.key,
    required this.lote,
    this.onTap,
    this.onAdjustStock,
    this.onMarkExpired,
    this.showProductName = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isUrgent = _isUrgent();
    
    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      elevation: isUrgent ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isUrgent 
            ? BorderSide(color: statusColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila principal con información básica
              _buildMainRow(statusColor),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                // Información de fechas y estado
                _buildDateInfo(statusColor),
                
                // Botones de acción si están disponibles
                if (_hasActions()) ...[
                  const SizedBox(height: 12),
                  _buildActionButtons(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainRow(Color statusColor) {
    return Row(
      children: [
        // Icono de estado
        Container(
          width: isCompact ? 40 : 48,
          height: isCompact ? 40 : 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Icon(
            _getStatusIcon(),
            size: isCompact ? 20 : 24,
            color: statusColor,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Información del lote
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del producto (si se debe mostrar)
              if (showProductName && lote.productoNombre != null) ...[
                Text(
                  lote.productoNombre!,
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              
              // Número de lote
              Text(
                'Lote: ${lote.numeroLoteDisplay}',
                style: TextStyle(
                  fontSize: isCompact ? 12 : 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 2),
              
              // Cantidad actual
              Row(
                children: [
                  const Text(
                    'Cantidad: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${lote.cantidadActual}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (lote.cantidadInicial != lote.cantidadActual)
                    Text(
                      ' de ${lote.cantidadInicial}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Badge de estado
        if (_shouldShowBadge())
          _buildStatusBadge(statusColor),
        
        // Indicador de navegación
        if (onTap != null)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ),
      ],
    );
  }

  Widget _buildDateInfo(Color statusColor) {
    if (lote.fechaVencimiento == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.textTertiary),
            SizedBox(width: 8),
            Text(
              'Sin fecha de vencimiento',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getDateText(),
              style: TextStyle(
                fontSize: 14,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onAdjustStock != null && lote.cantidadActual > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAdjustStock,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Ajustar',
                style: TextStyle(fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        
        if (onAdjustStock != null && onMarkExpired != null)
          const SizedBox(width: 8),
        
        if (onMarkExpired != null && lote.cantidadActual > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarkExpired,
              icon: const Icon(Icons.dangerous, size: 18),
              label: const Text(
                'Vencido',
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getStatusText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Métodos helper
  Color _getStatusColor() {
    if (lote.cantidadActual <= 0) return AppColors.error;
    if (lote.estaVencido) return AppColors.error;
    if (lote.proximoAVencer) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getStatusIcon() {
    if (lote.cantidadActual <= 0) return Icons.remove_circle;
    if (lote.estaVencido) return Icons.dangerous;
    if (lote.proximoAVencer) return Icons.warning;
    return Icons.batch_prediction;
  }

  bool _isUrgent() {
    return lote.estaVencido || 
           lote.proximoAVencer || 
           lote.cantidadActual <= 0;
  }

  bool _shouldShowBadge() {
    return lote.estaVencido || lote.proximoAVencer;
  }

  String _getStatusText() {
    if (lote.estaVencido) return 'VENCIDO';
    if (lote.proximoAVencer) return 'POR VENCER';
    return 'OK';
  }

  String _getDateText() {
    if (lote.fechaVencimiento == null) {
      return 'Sin fecha de vencimiento';
    }
    
    if (lote.estaVencido) {
      return 'Vencido el ${_dateFormat.format(lote.fechaVencimiento!)}';
    }
    
    if (lote.proximoAVencer) {
      final dias = lote.diasParaVencer;
      switch (dias) {
        case 0:
          return '¡Vence HOY!';
        case 1:
          return 'Vence MAÑANA';
        default:
          return 'Vence en $dias días';
      }
    }
    
    return 'Vence: ${_dateFormat.format(lote.fechaVencimiento!)}';
  }

  bool _hasActions() {
    return onAdjustStock != null || onMarkExpired != null;
  }
}

// Widget especializado para mostrar lotes en listas compactas
class CompactLoteItem extends StatelessWidget {
  final Lote lote;
  final VoidCallback? onTap;

  const CompactLoteItem({
    super.key,
    required this.lote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleLoteCard(
      lote: lote,
      onTap: onTap,
      showProductName: false,
      isCompact: true,
    );
  }
}

// Widget para lotes en el dashboard con información mínima
class DashboardLoteCard extends StatelessWidget {
  final Lote lote;
  final VoidCallback? onTap;

  const DashboardLoteCard({
    super.key,
    required this.lote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = lote.estaVencido 
        ? AppColors.error
        : lote.proximoAVencer 
            ? AppColors.warning 
            : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  lote.estaVencido 
                      ? Icons.dangerous
                      : lote.proximoAVencer 
                          ? Icons.warning
                          : Icons.batch_prediction,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lote.productoNombre ?? 'Producto',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stock: ${lote.cantidadActual} - ${lote.estadoVencimientoTexto}',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para mostrar resumen de lotes de un producto
class ProductLotesSummary extends StatelessWidget {
  final List<Lote> lotes;
  final VoidCallback? onViewAll;
  final Function(Lote)? onLoteTap;

  const ProductLotesSummary({
    super.key,
    required this.lotes,
    this.onViewAll,
    this.onLoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (lotes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay lotes registrados',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    final activeLotes = lotes.where((l) => l.cantidadActual > 0).toList();
    final urgentLotes = activeLotes.where((l) => 
        l.estaVencido || l.proximoAVencer).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con resumen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activeLotes.length} ${activeLotes.length == 1 ? 'Lote Activo' : 'Lotes Activos'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (urgentLotes.isNotEmpty)
                    Text(
                      '${urgentLotes.length} necesitan atención',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              if (onViewAll != null && activeLotes.length > 3)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text(
                    'Ver todos',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Lista de lotes (máximo 3)
          ...activeLotes.take(3).map((lote) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DashboardLoteCard(
                lote: lote,
                onTap: onLoteTap != null ? () => onLoteTap!(lote) : null,
              ),
            ),
          ),
          
          // Indicador si hay más lotes
          if (activeLotes.length > 3)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Y ${activeLotes.length - 3} lotes más...',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}