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
  static const String misProductos = 'Mis Productos';
  static const String nombre = 'Nombre';
  static const String nombreProducto = 'Nombre del Producto';
  static const String descripcion = 'Descripción';
  static const String categoria = 'Categoría';
  static const String precio = 'Precio';
  static const String precioVenta = 'Precio de Venta';
  static const String precioCompra = 'Precio de Compra';
  static const String precioCosto = 'Precio de Costo';
  static const String stock = 'Stock';
  static const String stockMinimo = 'Stock Mínimo';
  static const String stockActual = 'Stock Actual';
  static const String unidadMedida = 'Unidad de Medida';
  static const String codigoBarras = 'Código de Barras';
  static const String codigoInterno = 'Código Interno';
  static const String codigoProducto = 'Código del Producto';
  
  // 📋 LOTES
  static const String lotes = 'Lotes';
  static const String numeroLote = 'Número de Lote';
  static const String codigoLote = 'Código de Lote';
  static const String fechaVencimiento = 'Fecha de Vencimiento';
  static const String fechaIngreso = 'Fecha de Ingreso';
  static const String cantidad = 'Cantidad';
  static const String cantidadInicial = 'Cantidad Inicial';
  static const String cantidadActual = 'Cantidad Actual';
  static const String observaciones = 'Observaciones';
  static const String loteVencido = 'Lote Vencido';
  static const String proximoVencer = 'Próximo a Vencer';
  
  // 💰 VENTAS
  static const String ventas = 'Ventas';
  static const String numeroVenta = 'Número de Venta';
  static const String fechaVenta = 'Fecha de Venta';
  static const String total = 'Total';
  static const String subtotal = 'Subtotal';
  static const String descuento = 'Descuento';
  static const String impuestos = 'Impuestos';
  static const String metodoPago = 'Método de Pago';
  static const String efectivo = 'Efectivo';
  static const String tarjeta = 'Tarjeta';
  static const String transferencia = 'Transferencia';
  static const String cliente = 'Cliente';
  static const String vendedor = 'Vendedor';
  
  // 📷 SCANNER
  static const String escanearCodigo = 'Escanear Código';
  static const String escanearProducto = 'Escanear Producto';
  static const String codigoNoEncontrado = 'Código no encontrado';
  static const String productoNoEncontrado = 'Producto no encontrado';
  static const String deseaRegistrarlo = '¿Desea registrarlo?';
  static const String escaneoExitoso = 'Código escaneado exitosamente';
  static const String errorEscaneo = 'Error al escanear código';
  
  // 🎯 ACCIONES PRINCIPALES
  static const String guardar = 'Guardar';
  static const String guardarProducto = 'Guardar Producto';
  static const String cancelar = 'Cancelar';
  static const String editar = 'Editar';
  static const String editarProducto = 'Editar Producto';
  static const String eliminar = 'Eliminar';
  static const String eliminarProducto = 'Eliminar Producto';
  static const String buscar = 'Buscar';
  static const String buscarProductos = 'Buscar productos...';
  static const String filtrar = 'Filtrar';
  static const String filtros = 'Filtros';
  static const String limpiarFiltros = 'Limpiar Filtros';
  static const String aplicarFiltros = 'Aplicar Filtros';
  static const String exportar = 'Exportar';
  static const String enviar = 'Enviar';
  static const String confirmar = 'Confirmar';
  static const String continuar = 'Continuar';
  static const String finalizar = 'Finalizar';
  static const String agregar = 'Agregar';
  static const String actualizar = 'Actualizar';
  static const String ver = 'Ver';
  static const String verDetalles = 'Ver Detalles';
  static const String cerrar = 'Cerrar';
  static const String aceptar = 'Aceptar';
  static const String si = 'Sí';
  static const String no = 'No';
  
  // 🔄 ESTADOS DE CARGA
  static const String cargando = 'Cargando...';
  static const String cargandoProductos = 'Cargando productos...';
  static const String actualizando = 'Actualizando...';
  static const String guardando = 'Guardando...';
  static const String procesando = 'Procesando...';
  static const String sincronizando = 'Sincronizando...';
  static const String esperar = 'Espere un momento...';
  
  // 💬 MENSAJES DE ÉXITO
  static const String guardadoExitoso = 'Guardado exitosamente';
  static const String productoAgregado = 'Producto agregado exitosamente';
  static const String productoActualizado = 'Producto actualizado exitosamente';
  static const String eliminadoExitoso = 'Eliminado exitosamente';
  static const String productoEliminado = 'Producto eliminado exitosamente';
  static const String actualizadoExitoso = 'Actualizado exitosamente';
  static const String stockActualizado = 'Stock actualizado exitosamente';
  static const String loteAgregado = 'Lote agregado exitosamente';
  static const String categoriaAgregada = 'Categoría agregada exitosamente';
  static const String operacionExitosa = 'Operación completada exitosamente';
  
  // ❌ MENSAJES DE ERROR
  static const String error = 'Error';
  static const String errorGeneral = 'Ha ocurrido un error inesperado';
  static const String errorAlGuardar = 'Error al guardar';
  static const String errorAlCargar = 'Error al cargar';
  static const String errorAlCargarProductos = 'Error al cargar productos';
  static const String errorAgregarProducto = 'Error al agregar producto';
  static const String errorActualizarProducto = 'Error al actualizar producto';
  static const String errorAlEliminar = 'Error al eliminar';
  static const String errorEliminarProducto = 'Error al eliminar producto';
  static const String errorAlActualizar = 'Error al actualizar';
  static const String errorActualizarStock = 'Error al actualizar stock';
  static const String errorConexion = 'Error de conexión';
  static const String errorBaseDatos = 'Error en la base de datos';
  static const String errorInesperado = 'Error inesperado';
  static const String reintentar = 'Reintentar';
  
  // ⚠️ VALIDACIONES
  static const String camposObligatorios = 'Por favor complete los campos obligatorios';
  static const String campoObligatorio = 'Este campo es obligatorio';
  static const String campoRequerido = 'Campo obligatorio';
  static const String nombreRequerido = 'El nombre es obligatorio';
  static const String nombreProductoRequerido = 'El nombre del producto es obligatorio';
  static const String precioRequerido = 'El precio es obligatorio';
  static const String cantidadRequerida = 'La cantidad es obligatoria';
  static const String valorInvalido = 'Valor inválido';
  static const String precioInvalido = 'Precio inválido';
  static const String cantidadInvalida = 'Cantidad inválida';
  static const String fechaInvalida = 'Fecha inválida';
  static const String codigoInvalido = 'Código inválido';
  static const String emailInvalido = 'Email inválido';
  static const String ingresePrecioValido = 'Ingrese un precio válido';
  static const String ingreseCantidadValida = 'Ingrese una cantidad válida';
  
  // 🔔 CONFIRMACIONES
  static const String confirmacionEliminar = '¿Está seguro de eliminar este elemento?';
  static const String confirmarEliminarProducto = '¿Está seguro de que desea eliminar este producto?';
  static const String confirmarEliminarLote = '¿Está seguro de que desea eliminar este lote?';
  static const String confirmarEliminarCategoria = '¿Está seguro de que desea eliminar esta categoría?';
  static const String cambiosSinGuardar = 'Hay cambios sin guardar';
  static const String descartarCambios = '¿Desea descartar los cambios?';
  static const String continuarEditando = 'Continuar editando';
  static const String sinCambios = 'Sin cambios';
  
  // 📧 EMAIL
  static const String email = 'Email';
  static const String emailEnviado = 'Email enviado';
  static const String errorEnvioEmail = 'Error al enviar email';
  static const String reciboEnviado = 'Recibo enviado por email';
  static const String configurarEmail = 'Configurar Email';
  
  // 🚦 ESTADOS
  static const String activo = 'Activo';
  static const String inactivo = 'Inactivo';
  static const String vencido = 'Vencido';
  static const String sinStock = 'Sin Stock';
  static const String disponible = 'Disponible';
  static const String agotado = 'Agotado';
  static const String vigente = 'Vigente';
  static const String todos = 'Todos';
  static const String stockOk = 'Stock OK';
  static const String alertaStockBajo = 'Alerta cuando el stock esté bajo';
  
  // 📏 UNIDADES DE MEDIDA
  static const String unidad = 'Unidad';
  static const String unidades = 'Unidades';
  static const String kilogramo = 'Kilogramo';
  static const String kilogramos = 'Kilogramos';
  static const String gramo = 'Gramo';
  static const String gramos = 'Gramos';
  static const String litro = 'Litro';
  static const String litros = 'Litros';
  static const String mililitro = 'Mililitro';
  static const String mililitros = 'Mililitros';
  static const String paquete = 'Paquete';
  static const String paquetes = 'Paquetes';
  static const String caja = 'Caja';
  static const String cajas = 'Cajas';
  static const String docena = 'Docena';
  static const String docenas = 'Docenas';
  
  // 🏷️ CATEGORÍAS
  static const String categorias = 'Categorías';
  static const String agregarCategoria = 'Agregar Categoría';
  static const String editarCategoria = 'Editar Categoría';
  static const String eliminarCategoria = 'Eliminar Categoría';
  static const String sinCategoria = 'Sin Categoría';
  static const String nombreCategoria = 'Nombre de Categoría';
  static const String descripcionCategoria = 'Descripción de Categoría';
  
  // 🏷️ CATEGORÍAS POR DEFECTO
  static const String alimentos = 'Alimentos';
  static const String bebidas = 'Bebidas';
  static const String lacteos = 'Lácteos';
  static const String carnes = 'Carnes';
  static const String panaderia = 'Panadería';
  static const String limpieza = 'Limpieza';
  static const String asePersonal = 'Aseo Personal';
  static const String higienePersonal = 'Higiene Personal';
  static const String dulces = 'Dulces';
  static const String otros = 'Otros';
  
  // 📊 ORDENAMIENTO
  static const String ordenar = 'Ordenar';
  static const String ordenarPor = 'Ordenar por:';
  static const String ordenarPorNombre = 'Ordenar por Nombre';
  static const String ordenarPorStock = 'Ordenar por Stock';
  static const String ordenarPorPrecio = 'Ordenar por Precio';
  static const String ordenarPorFecha = 'Ordenar por Fecha';
  static const String ascendente = 'Ascendente';
  static const String descendente = 'Descendente';
  
  // 🔍 FILTROS ESPECÍFICOS
  static const String todoLosProductos = 'Todos los Productos';
  static const String soloStockBajo = 'Solo Stock Bajo';
  static const String soloSinStock = 'Solo Sin Stock';
  static const String productosActivos = 'Productos Activos';
  static const String productosInactivos = 'Productos Inactivos';
  static const String limpiarTodo = 'Limpiar todo';
  
  // 📱 ESTADO VACÍO
  static const String noHayProductos = 'No hay productos registrados';
  static const String noProductosEncontrados = 'No se encontraron productos';
  static const String noHayResultados = 'No hay resultados';
  static const String agregaPrimerProducto = 'Agrega tu primer producto\npara empezar a gestionar\ntu inventario';
  static const String pruebaConBusquedaDiferente = 'Prueba cambiando los filtros\npara ver más productos';
  static const String noHayLotes = 'No hay lotes registrados';
  static const String noHayCategorias = 'No hay categorías disponibles';
  static const String listVacia = 'Lista vacía';
  
  // 📲 OPCIONES AVANZADAS
  static const String opcionesAvanzadas = 'Opciones Avanzadas';
  static const String informacionBasica = 'Información Básica';
  static const String informacionAdicional = 'Información Adicional';
  static const String configuracionStock = 'Configuración de Stock';
  static const String stockInicial = 'Stock Inicial';
  static const String preciosStock = 'Precios y Stock';
  static const String informacionProducto = 'Información del Producto';
  static const String informacionStock = 'Información de Stock';
  static const String notasAdicionales = 'Notas adicionales';
  static const String opcional = 'Opcional';
  static const String recomendado = 'Recomendado';
  static const String autoGenerado = 'Se genera automáticamente si está vacío';
  static const String opcionalParaPerecibles = 'Opcional para productos perecederos';
  static const String seleccionarFecha = 'Seleccionar fecha';
  
  // 💡 TIPS Y AYUDA
  static const String ayuda = 'Ayuda';
  static const String informacion = 'Información';
  static const String consejo = 'Consejo';
  static const String ejemplo = 'Ejemplo';
  static const String notaImportante = 'Nota Importante';
  static const String paraModificarStock = 'Para modificar el stock del producto, ve a la sección de Inventario y agrega o edita lotes.';
  
  // 🌐 IDIOMAS
  static const String idioma = 'Idioma';
  static const String espanol = 'Español';
  static const String ingles = 'English';
  static const String cambiarIdioma = 'Cambiar Idioma';
  
  // 📈 ESTADÍSTICAS Y REPORTES
  static const String estadisticas = 'Estadísticas';
  static const String totalProductos = 'Total de Productos';
  static const String totalValor = 'Valor Total';
  static const String productosStockBajo = 'Productos con Stock Bajo';
  static const String productosSinStock = 'Productos sin Stock';
  static const String proximosVencerProductos = 'Productos Próximos a Vencer';
  static const String productosVencidos = 'Productos Vencidos';
  static const String lotesVencidos = 'Lotes Vencidos';
  static const String lotesProximosVencer = 'Lotes Próximos a Vencer';
  static const String resumenInventario = 'Resumen de Inventario';
  
  // 📅 FECHAS
  static const String hoy = 'Hoy';
  static const String ayer = 'Ayer';
  static const String ultimaSemana = 'Última semana';
  static const String ultimoMes = 'Último mes';
  static const String creadoEl = 'Creado el';
  static const String actualizadoEl = 'Actualizado el';
  static const String venceEl = 'Vence el';
  static const String vencioEl = 'Venció el';
  static const String diasParaVencer = 'días para vencer';
  static const String diasVencido = 'días vencido';
  static const String venceHoy = 'Vence hoy';
  static const String venceManana = 'Vence mañana';
  static const String fecha = 'Fecha';
  
  // 💰 MONEDA Y FORMATO
  static const String moneda = 'Moneda';
  static const String simboloMoneda = '\$';
  static const String formatoPrecio = '\$0.00';
  static const String formatoPorcentaje = '0.0%';
  static const String margenGanancia = 'Margen de Ganancia';
  static const String ganancia = 'Ganancia';
  static const String costo = 'Costo';
  static const String utilidad = 'Utilidad';
  
  // 🔧 CONFIGURACIÓN
  static const String configuraciones = 'Configuraciones';
  static const String preferencias = 'Preferencias';
  static const String tema = 'Tema';
  static const String notificaciones = 'Notificaciones';
  static const String respaldo = 'Respaldo';
  static const String importar = 'Importar';
  static const String resetear = 'Restablecer';
  static const String acercaDe = 'Acerca de';
  static const String version = 'Versión';
  static const String contactoSoporte = 'Contactar Soporte';
  
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
    paquete,
    caja,
    docena,
  ];
  
  /// Lista de categorías por defecto
  static const List<String> categoriasDefecto = [
    alimentos,
    bebidas,
    lacteos,
    carnes,
    panaderia,
    limpieza,
    asePersonal,
    dulces,
    otros,
  ];
  
  /// Lista de opciones de ordenamiento
  static const List<String> opcionesOrdenamiento = [
    'Nombre',
    'Stock',
    'Precio',
    'Fecha',
  ];
  
  /// Mapa de estados con sus colores sugeridos
  static const Map<String, String> estados = {
    activo: 'success',
    inactivo: 'warning',
    vencido: 'error',
    sinStock: 'error',
    disponible: 'info',
    stockOk: 'success',
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
        return operacionExitosa;
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
        return errorGeneral;
    }
  }
  
  /// Formatea el nombre de la unidad de medida
  static String formatUnidadMedida(String unidad, int cantidad) {
    if (cantidad == 1) return unidad.toLowerCase();
    
    // Pluralizar según la unidad
    switch (unidad.toLowerCase()) {
      case 'unidad':
        return unidades.toLowerCase();
      case 'kilogramo':
        return kilogramos.toLowerCase();
      case 'gramo':
        return gramos.toLowerCase();
      case 'litro':
        return litros.toLowerCase();
      case 'mililitro':
        return mililitros.toLowerCase();
      case 'paquete':
        return paquetes.toLowerCase();
      case 'caja':
        return cajas.toLowerCase();
      case 'docena':
        return docenas.toLowerCase();
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
      case 'lácteos':
      case 'lacteos':
        return '🥛';
      case 'carnes':
        return '🥩';
      case 'panadería':
      case 'panaderia':
        return '🥖';
      case 'limpieza':
        return '🧹';
      case 'aseo personal':
      case 'higiene personal':
        return '🧼';
      case 'dulces':
        return '🍭';
      case 'otros':
        return '📦';
      default:
        return '📦';
    }
  }
  
  /// Obtiene el mensaje de estado de stock
  static String getStockStatusMessage(int stockActual, int stockMinimo) {
    if (stockActual <= 0) return sinStock;
    if (stockActual <= stockMinimo) return stockBajo;
    return stockOk;
  }
  
  /// Formatea la fecha de vencimiento
  static String formatFechaVencimiento(DateTime fecha) {
    final now = DateTime.now();
    final difference = fecha.difference(now).inDays;
    
    if (difference < 0) return vencido;
    if (difference == 0) return venceHoy;
    if (difference == 1) return venceManana;
    if (difference <= 7) return 'Vence en $difference días';
    
    return '${fecha.day}/${fecha.month}/${fecha.year}';
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
  
  /// Valida que un precio sea válido
  static bool isValidPrice(String price) {
    final parsed = double.tryParse(price);
    return parsed != null && parsed > 0;
  }
  
  /// Valida que una cantidad sea válida
  static bool isValidQuantity(String quantity) {
    final parsed = int.tryParse(quantity);
    return parsed != null && parsed >= 0;
  }
}

// 📋 ENUMS PARA TYPE SAFETY

/// Tipos de acciones
enum ActionType { save, update, delete }

/// Tipos de documentos
enum DocumentType { venta, lote, producto, movimiento }