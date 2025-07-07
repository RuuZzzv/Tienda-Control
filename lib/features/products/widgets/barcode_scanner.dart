// lib/features/products/widgets/barcode_scanner.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/extensions/build_context_extensions.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> 
    with TickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        langProvider.translate('scan_barcode'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 28),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Área de escaneo simulado
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Simulación de cámara
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Fondo simulado de cámara
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2,
                                      size: 120,
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      langProvider.translate('scan_barcode'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Marco de escaneo
                              Center(
                                child: Container(
                                  width: 280,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _animation,
                                    builder: (context, child) {
                                      return Stack(
                                        children: [
                                          // Línea de escaneo animada
                                          if (_isScanning)
                                            Positioned(
                                              top: _animation.value * 140,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 3,
                                                decoration: BoxDecoration(
                                                  color: AppColors.success,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.success.withOpacity(0.5),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          
                                          // Esquinas del marco
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: _buildCorner(isTopLeft: true),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: _buildCorner(isTopRight: true),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            child: _buildCorner(isBottomLeft: true),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: _buildCorner(isBottomRight: true),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botón de escaneo
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _isScanning ? _stopScanning : _startScanning,
                          icon: Icon(
                            _isScanning ? Icons.stop : Icons.camera_alt,
                            size: 28,
                          ),
                          label: Text(
                            _isScanning 
                                ? langProvider.translate('stop') 
                                : langProvider.translate('scan_barcode'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isScanning ? AppColors.error : AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Opción de entrada manual
                      Text(
                        langProvider.translate('enter_barcode'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Campo de entrada manual
                      TextFormField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          labelText: langProvider.translate('barcode'),
                          labelStyle: const TextStyle(fontSize: 18),
                          hintText: '1234567890123',
                          hintStyle: const TextStyle(fontSize: 16),
                          prefixIcon: const Icon(
                            Icons.edit,
                            size: 28,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: _barcodeController.clear,
                            icon: const Icon(Icons.clear),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(width: 2),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                        style: const TextStyle(fontSize: 18),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botón confirmar
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: _barcodeController.text.isNotEmpty 
                              ? () => _confirmBarcode(langProvider) 
                              : null,
                          icon: const Icon(Icons.check, size: 28),
                          label: Text(
                            langProvider.translate('confirm'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCorner({
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: (isTopLeft || isTopRight) 
              ? const BorderSide(color: AppColors.success, width: 3)
              : BorderSide.none,
          bottom: (isBottomLeft || isBottomRight)
              ? const BorderSide(color: AppColors.success, width: 3)
              : BorderSide.none,
          left: (isTopLeft || isBottomLeft)
              ? const BorderSide(color: AppColors.success, width: 3)
              : BorderSide.none,
          right: (isTopRight || isBottomRight)
              ? const BorderSide(color: AppColors.success, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _animationController.repeat();
    
    // Simular escaneo exitoso después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (_isScanning && mounted) {
        _simulateSuccessfulScan();
      }
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
    _animationController.stop();
  }

  void _simulateSuccessfulScan() {
    _stopScanning();
    
    // Generar código simulado
    final simulatedBarcode = DateTime.now().millisecondsSinceEpoch.toString();
    _barcodeController.text = simulatedBarcode;
    
    // Vibración y sonido de éxito
    HapticFeedback.lightImpact();
    
    // Mostrar mensaje de éxito
    final langProvider = context.read<LanguageProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(langProvider.translate('success')),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmBarcode(LanguageProvider langProvider) {
    final barcode = _barcodeController.text.trim();
    
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('required_field')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Validación básica de código de barras
    if (barcode.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langProvider.translate('invalid')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    Navigator.pop(context, barcode);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}