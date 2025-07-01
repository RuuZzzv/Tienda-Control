// lib/core/constants/app_strings.dart
class AppStrings {
  // Prevenir instanciación
  AppStrings._();

  // 📱 INFORMACIÓN DE LA APLICACIÓN
  static const String appName = 'Mi Tienda';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // 🏠 PANTALLA PRINCIPAL
  static const String dashboard = 'Mi Tienda - Inicio';
  static const String ventasHoy = 'Ventas Hoy';
  static const String productosRegistrados = 'Productos';
  static const String stockBajo = 'Stock Bajo';
  static const String proximosVencer = 'Próximos a Vencer';
  
  // 🧭 NAVEGACIÓN
  static const String nuevaVenta = 'Nueva Venta';
  static const String agregarProducto = 'Agregar Producto';
  static const String inventario = 'Inventario';
  static const String reportes = 'Reportes';
  static const String configuracion = 'Configuración';
  
  // 📦 PRODUCTOS
  static const String productos = 'Productos';
  static const String nombre = 'Nombre';
  static const String descripcion = 'Descripción';
  static const String categoria = 'Categoría';
  static const String precio = 'Precio';
  static const String precioVenta = 'Precio de Venta';
  static const String precioCompra = 'Precio de Compra';
  static const String stock = 'Stock';
  static const String stockMinimo = 'Stock Mínimo';
  static const String unidadMedida = 'Unidad de Medida';
  static const String codigoBarras = 'Código de Barras';
  
  // 📋 LOTES
  static const String lotes = 'Lotes';
  static const String numeroLote = 'Número de Lote';
  static const String fechaVencimiento = 'Fecha de Vencimiento';
  static const String fechaIngreso = 'Fecha de Ingreso';
  static const String cantidad = 'Cantidad';
  static const String cantidadInicial = 'Cantidad Inicial';
  static const String cantidadActual = 'Cantidad Actual';
  
  // 💰 VENTAS
  static const String ventas = 'Ventas';
  static const String numeroVenta = 'Número de Venta';
  static const String fechaVenta = 'Fecha de Venta';
  static const String total = 'Total';
  static const String metodoPago = 'Método de Pago';
  static const String efectivo = 'Efectivo';
  static const String tarjeta = 'Tarjeta';
  static const String transferencia = 'Transferencia';
  
  // 📷 SCANNER
  static const String escanearCodigo = 'Escanear Código';
  static const String escanearProducto = 'Escanear Producto';
  static const String codigoNoEncontrado = 'Código no encontrado';
  static const String productoNoEncontrado = 'Producto no encontrado';
  static const String deseaRegistrarlo = '¿Desea registrarlo?';
  
  // 🎯 ACCIONES
  static const String guardar = 'Guardar';
  static const String cancelar = 'Cancelar';
  static const String editar = 'Editar';
  static const String eliminar = 'Eliminar';
  static const String buscar = 'Buscar';
  static const String filtrar = 'Filtrar';
  static const String exportar = 'Exportar';
  static const String enviar = 'Enviar';
  static const String confirmar = 'Confirmar';
  static const String continuar = 'Continuar';
  static const String finalizar = 'Finalizar';
  static const String agregar = 'Agregar';
  static const String actualizar = 'Actualizar';
  
  // 💬 MENSAJES
  static const String guardadoExitoso = 'Guardado exitosamente';
  static const String eliminadoExitoso = 'Eliminado exitosamente';
  static const String actualizadoExitoso = 'Actualizado exitosamente';
  static const String errorAlGuardar = 'Error al guardar';
  static const String errorAlEliminar = 'Error al eliminar';
  static const String errorAlActualizar = 'Error al actualizar';
  static const String camposObligatorios = 'Por favor complete los campos obligatorios';
  static const String confirmacionEliminar = '¿Está seguro de eliminar este elemento?';
  
  // 📧 EMAIL
  static const String email = 'Email';
  static const String emailEnviado = 'Email enviado';
  static const String errorEnvioEmail = 'Error al enviar email';
  static const String reciboEnviado = 'Recibo enviado por email';
  
  // 🚦 ESTADOS
  static const String activo = 'Activo';
  static const String inactivo = 'Inactivo';
  static const String vencido = 'Vencido';
  static const String sinStock = 'Sin Stock';
  static const String disponible = 'Disponible';
  
  // 📏 UNIDADES DE MEDIDA
  static const String unidad = 'Unidad';
  static const String kilogramo = 'Kilogramo';
  static const String gramo = 'Gramo';
  static const String litro = 'Litro';
  static const String mililitro = 'Mililitro';
  
  // 🏷️ CATEGORÍAS POR DEFECTO
  static const String alimentos = 'Alimentos';
  static const String bebidas = 'Bebidas';
  static const String limpieza = 'Limpieza';
  static const String higienePersonal = 'Higiene Personal';
  static const String otros = 'Otros';
  
  // 📊 LISTAS Y MAPAS ÚTILES
  
  /// Lista de métodos de pago disponibles
  static const List<String> metodosPago = [
    efectivo,
    tarjeta,
    transferencia,
  ];
  
  /// Lista de unidades de medida
  static const List<String> unidadesMedida = [
    unidad,
    kilogramo,
    gramo,
    litro,
    mililitro,
  ];
  
  /// Lista de categorías por defecto
  static const List<String> categoriasDefecto = [
    alimentos,
    bebidas,
    limpieza,
    higienePersonal,
    otros,
  ];
  
  /// Mapa de estados con sus colores sugeridos
  static const Map<String, String> estados = {
    activo: 'success',
    inactivo: 'warning',
    vencido: 'error',
    sinStock: 'error',
    disponible: 'info',
  };
  
  // 🛠️ MÉTODOS HELPER
  
  /// Obtiene el mensaje de éxito según la acción
  static String getSuccessMessage(ActionType action) {
    switch (action) {
      case ActionType.save:
        return guardadoExitoso;
      case ActionType.update:
        return actualizadoExitoso;
      case ActionType.delete:
        return eliminadoExitoso;
      default:
        return 'Operación exitosa';
    }
  }
  
  /// Obtiene el mensaje de error según la acción
  static String getErrorMessage(ActionType action) {
    switch (action) {
      case ActionType.save:
        return errorAlGuardar;
      case ActionType.update:
        return errorAlActualizar;
      case ActionType.delete:
        return errorAlEliminar;
      default:
        return 'Error en la operación';
    }
  }
  
  /// Formatea el nombre de la unidad de medida
  static String formatUnidadMedida(String unidad, int cantidad) {
    if (cantidad == 1) return unidad.toLowerCase();
    
    // Pluralizar según la unidad
    switch (unidad.toLowerCase()) {
      case 'unidad':
        return 'unidades';
      case 'kilogramo':
        return 'kilogramos';
      case 'gramo':
        return 'gramos';
      case 'litro':
        return 'litros';
      case 'mililitro':
        return 'mililitros';
      default:
        return '${unidad.toLowerCase()}s';
    }
  }
  
  /// Obtiene el prefijo de número según el tipo
  static String getNumeroPrefix(DocumentType type) {
    switch (type) {
      case DocumentType.venta:
        return 'V-';
      case DocumentType.lote:
        return 'L-';
      case DocumentType.producto:
        return 'P-';
      case DocumentType.movimiento:
        return 'M-';
    }
  }
  
  /// Genera un número de documento formateado
  static String generateDocumentNumber(DocumentType type, int number) {
    final prefix = getNumeroPrefix(type);
    final numberStr = number.toString().padLeft(6, '0');
    return '$prefix$numberStr';
  }
  
  /// Valida si un email es válido
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
  
  /// Formatea el método de pago para mostrar
  static String formatMetodoPago(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return '💵 $efectivo';
      case 'tarjeta':
        return '💳 $tarjeta';
      case 'transferencia':
        return '🏦 $transferencia';
      default:
        return metodo;
    }
  }
  
  /// Obtiene el icono sugerido para una categoría
  static String getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'alimentos':
        return '🍞';
      case 'bebidas':
        return '🥤';
      case 'limpieza':
        return '🧹';
      case 'higiene personal':
        return '🧼';
      case 'otros':
        return '📦';
      default:
        return '📦';
    }
  }
  
  // 🔧 VALIDACIONES
  
  /// Valida el formato de un código de barras
  static bool isValidBarcode(String barcode) {
    // EAN-13: 13 dígitos
    // UPC-A: 12 dígitos
    // Code 128: longitud variable
    final cleanBarcode = barcode.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanBarcode.length >= 8 && cleanBarcode.length <= 13;
  }
  
  /// Limpia y formatea un número de teléfono
  static String formatPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    }
    return cleanPhone;
  }
}

// 📋 ENUMS PARA TYPE SAFETY

/// Tipos de acciones
enum ActionType { save, update, delete }

/// Tipos de documentos
enum DocumentType { venta, lote, producto, movimiento }