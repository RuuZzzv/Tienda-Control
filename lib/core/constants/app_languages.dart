// lib/core/constants/app_languages.dart
class AppLanguages {
  // Prevenir instanciación
  AppLanguages._();

  // Constantes de configuración
  static const String defaultLanguage = 'es';
  static const List<String> supportedLanguages = ['es', 'en', 'it'];
  
  // Información de idiomas
  static const Map<String, _LanguageInfo> languageInfo = {
    'es': _LanguageInfo('Español', '🇪🇸'),
    'en': _LanguageInfo('English', '🇬🇧'),
    'it': _LanguageInfo('Italiano', '🇮🇹'),
  };

  // Cache para traducciones cargadas
  static final Map<String, Map<String, String>> _translationsCache = {};

  // Obtener traducción con fallback
  static String translate(String languageCode, String key) {
    // Asegurar que el idioma esté cargado
    _ensureLanguageLoaded(languageCode);
    
    // Buscar traducción
    final translation = _translationsCache[languageCode]?[key];
    if (translation != null) return translation;
    
    // Fallback al idioma por defecto
    if (languageCode != defaultLanguage) {
      _ensureLanguageLoaded(defaultLanguage);
      final defaultTranslation = _translationsCache[defaultLanguage]?[key];
      if (defaultTranslation != null) return defaultTranslation;
    }
    
    // Si no hay traducción, devolver la key
    return key;
  }

  // Cargar idioma si no está en cache
  static void _ensureLanguageLoaded(String languageCode) {
    if (!_translationsCache.containsKey(languageCode)) {
      switch (languageCode) {
        case 'es':
          _translationsCache['es'] = _spanishTranslations;
          break;
        case 'en':
          _translationsCache['en'] = _englishTranslations;
          break;
        case 'it':
          _translationsCache['it'] = _italianTranslations;
          break;
      }
    }
  }

  // Precargar un idioma específico
  static void preloadLanguage(String languageCode) {
    _ensureLanguageLoaded(languageCode);
  }

  // Precargar todos los idiomas (útil en la inicialización)
  static void preloadAllLanguages() {
    for (final lang in supportedLanguages) {
      _ensureLanguageLoaded(lang);
    }
  }

  // Limpiar cache (útil para liberar memoria)
  static void clearCache() {
    _translationsCache.clear();
  }

  // Verificar si un idioma está soportado
  static bool isSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }

  // Obtener información del idioma
  static _LanguageInfo? getLanguageInfo(String languageCode) {
    return languageInfo[languageCode];
  }

  // Obtener todas las keys de traducción (útil para testing)
  static Set<String> getAllTranslationKeys() {
    _ensureLanguageLoaded(defaultLanguage);
    return _translationsCache[defaultLanguage]?.keys.toSet() ?? {};
  }

  // Verificar completitud de traducciones
  static Map<String, List<String>> checkMissingTranslations() {
    final allKeys = getAllTranslationKeys();
    final missing = <String, List<String>>{};
    
    for (final lang in supportedLanguages) {
      _ensureLanguageLoaded(lang);
      final langTranslations = _translationsCache[lang] ?? {};
      final missingKeys = allKeys.where((key) => !langTranslations.containsKey(key)).toList();
      
      if (missingKeys.isNotEmpty) {
        missing[lang] = missingKeys;
      }
    }
    
    return missing;
  }

  // TRADUCCIONES - Separadas para lazy loading
  
  // ESPAÑOL
  static const Map<String, String> _spanishTranslations = {
    // Dashboard
    'dashboard': 'Panel Principal',
    'good_morning': 'Buenos días',
    'good_afternoon': 'Buenas tardes',
    'good_evening': 'Buenas noches',
    'today_summary': 'Resumen de Hoy',
    'sales_today': 'Ventas Hoy',
    'products': 'Productos',
    'low_stock': 'Stock Bajo',
    'reports': 'Reportes',
    'sales': 'ventas',
    'active_products': 'productos activos',
    'require_attention': 'requieren atención',
    'detailed_analysis': 'análisis detallado',
    'quick_actions': 'Acciones Rápidas',
    'new_sale': 'Nueva Venta',
    'add_product': 'Agregar Producto',
    'inventory': 'Inventario',
    'recent_sales': 'Ventas Recientes',
    'view_all': 'Ver todas',
    'no_sales_recorded': 'No hay ventas registradas',
    'sales_will_appear': 'Las ventas aparecerán aquí una vez que comiences a registrarlas',
    'notifications': 'Notificaciones',
    'system_working': 'Sistema funcionando correctamente',
    'store_ready': 'Tu tienda está lista para operar',
    'close': 'Cerrar',
    'loading_data': 'Cargando datos...',
    'error_loading_data': 'Error al cargar datos',
    'retry': 'Reintentar',
    'no_data_available': 'No hay datos disponibles',
    'try_refresh': 'Intenta refrescar o agregar algunos productos',
    'reload': 'Recargar',
    'language': 'Idioma',
    'change_language': 'Cambiar Idioma',
    'select_language': 'Seleccionar Idioma',
    
    // Productos
    'products_list': 'Lista de Productos',
    'search_products': '🔍 Buscar productos...',
    'filters': 'Filtros',
    'category': 'Categoría',
    'all_categories': 'Todas las categorías',
    'status': 'Estado',
    'low_stock_only': 'Solo productos con stock bajo',
    'clear_all': 'Limpiar Todo',
    'apply': 'Aplicar',
    'no_products_found': 'No se encontraron productos',
    'try_change_filters': 'Intenta cambiar los filtros o términos de búsqueda',
    'no_products_registered': 'No hay productos registrados',
    'add_first_product_desc': 'Agrega tu primer producto para comenzar a gestionar tu inventario',
    'clear_filters': 'Limpiar Filtros',
    'add_first_product': 'Agregar Primer Producto',
    'edit_product': 'Editar Producto',
    'add_batch': 'Agregar Lote',
    'edit': 'Editar',
    'code': 'Código',
    'sale_price': 'Precio de Venta',
    'current_stock': 'Stock Actual',
    'minimum_stock': 'Stock Mínimo',
    'description': 'Descripción',
    
    // Formularios
    'product_name': 'Nombre del Producto',
    'product_name_required': 'El nombre del producto es obligatorio',
    'product_description': 'Descripción (opcional)',
    'additional_description': 'Descripción adicional del producto',
    'barcode': 'Código de Barras (opcional)',
    'coming_soon_scanner': 'Próximamente: Scanner de códigos',
    'purchase_price': 'Precio de Compra',
    'sale_price_required': 'El precio de venta es obligatorio',
    'enter_valid_price': 'Ingrese un precio válido',
    'price_greater_zero': 'El precio debe ser mayor a 0',
    'minimum_stock_label': 'Stock Mínimo',
    'enter_valid_number': 'Ingrese un número válido',
    'cannot_be_negative': 'No puede ser negativo',
    'unit_of_measure': 'Unidad de Medida',
    'batch_number': 'Número de Lote (opcional)',
    'initial_quantity': 'Cantidad Inicial',
    'initial_quantity_required': 'La cantidad inicial es obligatoria',
    'enter_valid_quantity': 'Ingrese una cantidad válida',
    'quantity_cannot_negative': 'La cantidad no puede ser negativa',
    'expiration_date': 'Fecha de Vencimiento (opcional)',
    'select_date': 'Seleccionar fecha',
    'cancel': 'Cancelar',
    'save': 'Guardar',
    'save_product': 'Guardar Producto',
    'save_changes': 'Guardar Cambios',
    'no_changes': 'Sin Cambios',
    
    // Inventario
    'batch': 'Lote',
    'batches': 'Lotes',
    'expired': 'Vencido',
    'expiring_soon': 'Por vencer',
    'current_quantity': 'Cantidad Actual',
    'notes': 'Notas',
    'batch_info': 'Información del Lote',
    'select_product': 'Seleccionar Producto',
    'selected_product': 'Producto Seleccionado',
    'additional_info': 'Información Adicional',
    'batch_purchase_price': 'Precio de Compra (opcional)',
    'batch_purchase_price_help': 'Precio de compra específico para este lote',
    'batch_notes': 'Notas (opcional)',
    'batch_notes_hint': 'Observaciones sobre este lote...',
    'add_batch_button': 'Agregar Lote',
    'quantity_required': 'La cantidad es obligatoria',
    'valid_quantity': 'Ingrese una cantidad válida',
    'quantity_greater_zero': 'La cantidad debe ser mayor a 0',
    'must_select_product': 'Debe seleccionar un producto',
    'batch_added_successfully': 'Lote agregado exitosamente',
    'error_adding_batch': 'Error al agregar el lote',
    'auto_generated_note': 'Si no se especifica, se generará automáticamente',
    'optional_perishable': 'Opcional para productos no perecederos',
    'product_info': 'Información del Producto',
    'total_stock': 'Stock Total',
    'no_batches_product': 'No hay lotes para este producto',
    'editing_product': 'Editando',
    'inventory_management': 'Gestión de Inventario',
    
    // Reportes
    'reports_analysis': 'Reportes y Análisis',
    'analyze_business': 'Analiza el rendimiento de tu negocio',
    'export_reports': 'Exportar reportes',
    
    // Navegación
    'home': 'Inicio',
    'point_of_sale': 'Punto de Venta',
    
    // Mensajes
    'product_added_successfully': 'Producto agregado exitosamente',
    'product_updated_successfully': 'Producto actualizado exitosamente',
    'error_adding_product': 'Error al agregar el producto',
    'error_updating_product': 'Error al actualizar el producto',
    'unsaved_changes': 'Cambios sin guardar',
    'sure_exit': '¿Estás seguro de que quieres salir? Los cambios realizados se perderán.',
    'exit_without_saving': 'Salir sin guardar',
    'note_about_stock': 'Nota sobre el Stock',
    'stock_modification_note': 'Para modificar el stock del producto, debes agregar o editar lotes desde la sección de inventario.',
    
    // Unidades de medida
    'unit': 'unidad',
    'kilogram': 'kilogramo',
    'gram': 'gramo',
    'liter': 'litro',
    'milliliter': 'mililitro',
    'package': 'paquete',
    'box': 'caja',
    
    // Otros
    'today': 'Hoy',
    'yesterday': 'Ayer',
    'days': 'días',
    'refresh': 'Actualizar',
    'app_name': 'Tienda Control',
    'coming_soon': 'Próximamente',
    
    // Nuevas traducciones para inventario
    'add_lote': 'Agregar Lote',
    'lote_info': 'Información del Lote',
    'lote_number_optional': 'Número de Lote (opcional)',
    'quantity': 'Cantidad',
    'expiration_date_optional': 'Fecha de Vencimiento (opcional)',
    'purchase_price_optional': 'Precio de Compra (opcional)',
    'specific_price_this_lote': 'Precio específico para este lote',
    'notes_optional': 'Notas (opcional)',
    'observations_about_lote': 'Observaciones sobre este lote',
    'auto_generate_if_empty': 'Se generará automáticamente si está vacío',
    'optional_non_perishable': 'Opcional para productos no perecederos',
  };

  // ENGLISH
  static const Map<String, String> _englishTranslations = {
    // Dashboard
    'dashboard': 'Dashboard',
    'good_morning': 'Good morning',
    'good_afternoon': 'Good afternoon',
    'good_evening': 'Good evening',
    'today_summary': 'Today\'s Summary',
    'sales_today': 'Sales Today',
    'products': 'Products',
    'low_stock': 'Low Stock',
    'reports': 'Reports',
    'sales': 'sales',
    'active_products': 'active products',
    'require_attention': 'require attention',
    'detailed_analysis': 'detailed analysis',
    'quick_actions': 'Quick Actions',
    'new_sale': 'New Sale',
    'add_product': 'Add Product',
    'inventory': 'Inventory',
    'recent_sales': 'Recent Sales',
    'view_all': 'View all',
    'no_sales_recorded': 'No sales recorded',
    'sales_will_appear': 'Sales will appear here once you start recording them',
    'notifications': 'Notifications',
    'system_working': 'System working properly',
    'store_ready': 'Your store is ready to operate',
    'close': 'Close',
    'loading_data': 'Loading data...',
    'error_loading_data': 'Error loading data',
    'retry': 'Retry',
    'no_data_available': 'No data available',
    'try_refresh': 'Try refreshing or adding some products',
    'reload': 'Reload',
    'language': 'Language',
    'change_language': 'Change Language',
    'select_language': 'Select Language',
    
    // Products
    'products_list': 'Products List',
    'search_products': '🔍 Search products...',
    'filters': 'Filters',
    'category': 'Category',
    'all_categories': 'All categories',
    'status': 'Status',
    'low_stock_only': 'Low stock products only',
    'clear_all': 'Clear All',
    'apply': 'Apply',
    'no_products_found': 'No products found',
    'try_change_filters': 'Try changing the filters or search terms',
    'no_products_registered': 'No products registered',
    'add_first_product_desc': 'Add your first product to start managing your inventory',
    'clear_filters': 'Clear Filters',
    'add_first_product': 'Add First Product',
    'edit_product': 'Edit Product',
    'add_batch': 'Add Batch',
    'edit': 'Edit',
    'code': 'Code',
    'sale_price': 'Sale Price',
    'current_stock': 'Current Stock',
    'minimum_stock': 'Minimum Stock',
    'description': 'Description',
    
    // Forms
    'product_name': 'Product Name',
    'product_name_required': 'Product name is required',
    'product_description': 'Description (optional)',
    'additional_description': 'Additional product description',
    'barcode': 'Barcode (optional)',
    'coming_soon_scanner': 'Coming soon: Code scanner',
    'purchase_price': 'Purchase Price',
    'sale_price_required': 'Sale price is required',
    'enter_valid_price': 'Enter a valid price',
    'price_greater_zero': 'Price must be greater than 0',
    'minimum_stock_label': 'Minimum Stock',
    'enter_valid_number': 'Enter a valid number',
    'cannot_be_negative': 'Cannot be negative',
    'unit_of_measure': 'Unit of Measure',
    'batch_number': 'Batch Number (optional)',
    'initial_quantity': 'Initial Quantity',
    'initial_quantity_required': 'Initial quantity is required',
    'enter_valid_quantity': 'Enter a valid quantity',
    'quantity_cannot_negative': 'Quantity cannot be negative',
    'expiration_date': 'Expiration Date (optional)',
    'select_date': 'Select date',
    'cancel': 'Cancel',
    'save': 'Save',
    'save_product': 'Save Product',
    'save_changes': 'Save Changes',
    'no_changes': 'No Changes',
    
    // Inventory
    'batch': 'Batch',
    'batches': 'Batches',
    'expired': 'Expired',
    'expiring_soon': 'Expiring Soon',
    'current_quantity': 'Current Quantity',
    'notes': 'Notes',
    'batch_info': 'Batch Information',
    'select_product': 'Select Product',
    'selected_product': 'Selected Product',
    'additional_info': 'Additional Information',
    'batch_purchase_price': 'Purchase Price (optional)',
    'batch_purchase_price_help': 'Specific purchase price for this batch',
    'batch_notes': 'Notes (optional)',
    'batch_notes_hint': 'Observations about this batch...',
    'add_batch_button': 'Add Batch',
    'quantity_required': 'Quantity is required',
    'valid_quantity': 'Enter a valid quantity',
    'quantity_greater_zero': 'Quantity must be greater than 0',
    'must_select_product': 'Must select a product',
    'batch_added_successfully': 'Batch added successfully',
    'error_adding_batch': 'Error adding batch',
    'auto_generated_note': 'If not specified, will be auto-generated',
    'optional_perishable': 'Optional for non-perishable products',
    'product_info': 'Product Information',
    'total_stock': 'Total Stock',
    'no_batches_product': 'No batches for this product',
    'editing_product': 'Editing',
    'inventory_management': 'Inventory Management',
    
    // Reports
    'reports_analysis': 'Reports and Analytics',
    'analyze_business': 'Analyze your business performance',
    'export_reports': 'Export reports',
    
    // Navigation
    'home': 'Home',
    'point_of_sale': 'Point of Sale',
    
    // Messages
    'product_added_successfully': 'Product added successfully',
    'product_updated_successfully': 'Product updated successfully',
    'error_adding_product': 'Error adding product',
    'error_updating_product': 'Error updating product',
    'unsaved_changes': 'Unsaved changes',
    'sure_exit': 'Are you sure you want to exit? Changes made will be lost.',
    'exit_without_saving': 'Exit without saving',
    'note_about_stock': 'Note about Stock',
    'stock_modification_note': 'To modify product stock, you must add or edit batches from the inventory section.',
    
    // Units of measure
    'unit': 'unit',
    'kilogram': 'kilogram',
    'gram': 'gram',
    'liter': 'liter',
    'milliliter': 'milliliter',
    'package': 'package',
    'box': 'box',
    
    // Others
    'today': 'Today',
    'yesterday': 'Yesterday',
    'days': 'days',
    'refresh': 'Refresh',
    'app_name': 'Store Control',
    'coming_soon': 'Coming Soon',
    
    // New inventory translations
    'add_lote': 'Add Batch',
    'lote_info': 'Batch Information',
    'lote_number_optional': 'Batch Number (optional)',
    'quantity': 'Quantity',
    'expiration_date_optional': 'Expiration Date (optional)',
    'purchase_price_optional': 'Purchase Price (optional)',
    'specific_price_this_lote': 'Specific price for this batch',
    'notes_optional': 'Notes (optional)',
    'observations_about_lote': 'Observations about this batch',
    'auto_generate_if_empty': 'Will be auto-generated if empty',
    'optional_non_perishable': 'Optional for non-perishable products',
  };

  // ITALIANO
  static const Map<String, String> _italianTranslations = {
    // Dashboard
    'dashboard': 'Pannello di Controllo',
    'good_morning': 'Buongiorno',
    'good_afternoon': 'Buon pomeriggio',
    'good_evening': 'Buonasera',
    'today_summary': 'Riassunto di Oggi',
    'sales_today': 'Vendite Oggi',
    'products': 'Prodotti',
    'low_stock': 'Stock Basso',
    'reports': 'Rapporti',
    'sales': 'vendite',
    'active_products': 'prodotti attivi',
    'require_attention': 'richiedono attenzione',
    'detailed_analysis': 'analisi dettagliata',
    'quick_actions': 'Azioni Rapide',
    'new_sale': 'Nuova Vendita',
    'add_product': 'Aggiungi Prodotto',
    'inventory': 'Inventario',
    'recent_sales': 'Vendite Recenti',
    'view_all': 'Vedi tutto',
    'no_sales_recorded': 'Nessuna vendita registrata',
    'sales_will_appear': 'Le vendite appariranno qui una volta che inizierai a registrarle',
    'notifications': 'Notifiche',
    'system_working': 'Sistema funzionante correttamente',
    'store_ready': 'Il tuo negozio è pronto per operare',
    'close': 'Chiudi',
    'loading_data': 'Caricamento dati...',
    'error_loading_data': 'Errore nel caricamento dati',
    'retry': 'Riprova',
    'no_data_available': 'Nessun dato disponibile',
    'try_refresh': 'Prova ad aggiornare o aggiungere alcuni prodotti',
    'reload': 'Ricarica',
    'language': 'Lingua',
    'change_language': 'Cambia Lingua',
    'select_language': 'Seleziona Lingua',
    
    // Products
    'products_list': 'Lista Prodotti',
    'search_products': '🔍 Cerca prodotti...',
    'filters': 'Filtri',
    'category': 'Categoria',
    'all_categories': 'Tutte le categorie',
    'status': 'Stato',
    'low_stock_only': 'Solo prodotti con stock basso',
    'clear_all': 'Cancella Tutto',
    'apply': 'Applica',
    'no_products_found': 'Nessun prodotto trovato',
    'try_change_filters': 'Prova a cambiare i filtri o i termini di ricerca',
    'no_products_registered': 'Nessun prodotto registrato',
    'add_first_product_desc': 'Aggiungi il tuo primo prodotto per iniziare a gestire il tuo inventario',
    'clear_filters': 'Cancella Filtri',
    'add_first_product': 'Aggiungi Primo Prodotto',
    'edit_product': 'Modifica Prodotto',
    'add_batch': 'Aggiungi Lotto',
    'edit': 'Modifica',
    'code': 'Codice',
    'sale_price': 'Prezzo di Vendita',
    'current_stock': 'Stock Attuale',
    'minimum_stock': 'Stock Minimo',
    'description': 'Descrizione',
    
    // Forms
    'product_name': 'Nome Prodotto',
    'product_name_required': 'Il nome del prodotto è obbligatorio',
    'product_description': 'Descrizione (opzionale)',
    'additional_description': 'Descrizione aggiuntiva del prodotto',
    'barcode': 'Codice a Barre (opzionale)',
    'coming_soon_scanner': 'Prossimamente: Scanner codici',
    'purchase_price': 'Prezzo di Acquisto',
    'sale_price_required': 'Il prezzo di vendita è obbligatorio',
    'enter_valid_price': 'Inserisci un prezzo valido',
    'price_greater_zero': 'Il prezzo deve essere maggiore di 0',
    'minimum_stock_label': 'Stock Minimo',
    'enter_valid_number': 'Inserisci un numero valido',
    'cannot_be_negative': 'Non può essere negativo',
    'unit_of_measure': 'Unità di Misura',
    'batch_number': 'Numero Lotto (opzionale)',
    'initial_quantity': 'Quantità Iniziale',
    'initial_quantity_required': 'La quantità iniziale è obbligatoria',
    'enter_valid_quantity': 'Inserisci una quantità valida',
    'quantity_cannot_negative': 'La quantità non può essere negativa',
    'expiration_date': 'Data di Scadenza (opzionale)',
    'select_date': 'Seleziona data',
    'cancel': 'Annulla',
    'save': 'Salva',
    'save_product': 'Salva Prodotto',
    'save_changes': 'Salva Modifiche',
    'no_changes': 'Nessuna Modifica',
    
    // Inventory
    'batch': 'Lotto',
    'batches': 'Lotti',
    'expired': 'Scaduto',
    'expiring_soon': 'In Scadenza',
    'current_quantity': 'Quantità Attuale',
    'notes': 'Note',
    'batch_info': 'Informazioni Lotto',
    'select_product': 'Seleziona Prodotto',
    'selected_product': 'Prodotto Selezionato',
    'additional_info': 'Informazioni Aggiuntive',
    'batch_purchase_price': 'Prezzo di Acquisto (opzionale)',
    'batch_purchase_price_help': 'Prezzo di acquisto specifico per questo lotto',
    'batch_notes': 'Note (opzionale)',
    'batch_notes_hint': 'Osservazioni su questo lotto...',
    'add_batch_button': 'Aggiungi Lotto',
    'quantity_required': 'La quantità è obbligatoria',
    'valid_quantity': 'Inserisci una quantità valida',
    'quantity_greater_zero': 'La quantità deve essere maggiore di 0',
    'must_select_product': 'Devi selezionare un prodotto',
    'batch_added_successfully': 'Lotto aggiunto con successo',
    'error_adding_batch': 'Errore nell\'aggiungere il lotto',
    'auto_generated_note': 'Se non specificato, sarà generato automaticamente',
    'optional_perishable': 'Opzionale per prodotti non deperibili',
    'product_info': 'Informazioni Prodotto',
    'total_stock': 'Stock Totale',
    'no_batches_product': 'Nessun lotto per questo prodotto',
    'editing_product': 'Modificando',
    'inventory_management': 'Gestione Inventario',
    
    // Reports
    'reports_analysis': 'Rapporti e Analisi',
    'analyze_business': 'Analizza le prestazioni del tuo business',
    'export_reports': 'Esporta rapporti',
    
    // Navigation
    'home': 'Home',
    'point_of_sale': 'Punto Vendita',
    
    // Messages
    'product_added_successfully': 'Prodotto aggiunto con successo',
    'product_updated_successfully': 'Prodotto aggiornato con successo',
    'error_adding_product': 'Errore nell\'aggiungere il prodotto',
    'error_updating_product': 'Errore nell\'aggiornare il prodotto',
    'unsaved_changes': 'Modifiche non salvate',
    'sure_exit': 'Sei sicuro di voler uscire? Le modifiche apportate andranno perse.',
    'exit_without_saving': 'Esci senza salvare',
    'note_about_stock': 'Nota sullo Stock',
    'stock_modification_note': 'Per modificare lo stock del prodotto, devi aggiungere o modificare i lotti dalla sezione inventario.',
    
    // Units of measure
    'unit': 'unità',
    'kilogram': 'chilogrammo',
    'gram': 'grammo',
    'liter': 'litro',
    'milliliter': 'millilitro',
    'package': 'confezione',
    'box': 'scatola',
    
    // Others
    'today': 'Oggi',
    'yesterday': 'Ieri',
    'days': 'giorni',
    'refresh': 'Aggiorna',
    'app_name': 'Controllo Negozio',
    'coming_soon': 'Prossimamente',
    
    // Nuove traduzioni inventario
    'add_lote': 'Aggiungi Lotto',
    'lote_info': 'Informazioni Lotto',
    'lote_number_optional': 'Numero Lotto (opzionale)',
    'quantity': 'Quantità',
    'expiration_date_optional': 'Data di Scadenza (opzionale)',
    'purchase_price_optional': 'Prezzo di Acquisto (opzionale)',
    'specific_price_this_lote': 'Prezzo specifico per questo lotto',
    'notes_optional': 'Note (opzionale)',
    'observations_about_lote': 'Osservazioni su questo lotto',
    'auto_generate_if_empty': 'Sarà generato automaticamente se vuoto',
    'optional_non_perishable': 'Opzionale per prodotti non deperibili',
  };
}

// Clase helper para información de idiomas
class _LanguageInfo {
  final String name;
  final String flag;
  
  const _LanguageInfo(this.name, this.flag);
}