class AppConstants {
  static const String appName = 'Grocery Scanner';
  static const String appVersion = '1.0.0';
  
  // =============================================
  // SUPABASE CONFIGURATION
  // REPLACE THESE WITH YOUR ACTUAL SUPABASE CREDENTIALS
  // =============================================
  
  /// Your Supabase project URL
  /// Get it from: https://supabase.com/dashboard/project/[YOUR_PROJECT_ID]/settings/api
  /// Format: https://xxxxx.supabase.co
  static const String supabaseUrl = 'https://daebgxnwxbscnmfjttcj.supabase.co';
  
  /// Your Supabase Anon/Public Key
  /// Get it from: https://supabase.com/dashboard/project/[YOUR_PROJECT_ID]/settings/api
  /// This key is safe to use in client-side applications
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRhZWJneG53eGJzY25tZmp0dGNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3NDQ5MjEsImV4cCI6MjA5MTMyMDkyMX0.dWAVBHRshuQ0mlbymNIPP4YhgwopAhBMNTMiOb3_q6E';
  
  // =============================================
  // SHARED PREFERENCES KEYS
  // =============================================
  
  /// Key for storing whether onboarding has been completed
  static const String keyOnboardingDone = 'onboarding_done';
  
  /// Key for storing the current user ID
  static const String keyUserId = 'user_id';
  
  /// Key for storing the session token
  static const String keySessionToken = 'session_token';
  
  /// Key for storing user's preferred theme (light/dark/system)
  static const String keyThemeMode = 'theme_mode';
  
  /// Key for storing user's preferred language
  static const String keyLanguage = 'language';
  
  /// Key for storing user's preferred city for store filtering
  static const String keyPreferredCity = 'preferred_city';
  
  /// Key for storing notification preferences
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  /// Key for storing last app version run (for showing whats new)
  static const String keyLastVersion = 'last_version';
  
  // =============================================
  // API & NETWORK CONFIGURATION
  // =============================================
  
  /// Connection timeout in seconds
  static const int connectionTimeout = 30;
  
  /// Receive timeout in seconds
  static const int receiveTimeout = 30;
  
  /// Base URL for API endpoints (if using custom API)
  static const String apiBaseUrl = 'https://api.grocery-scanner.com/v1';
  
  // =============================================
  // CACHE CONFIGURATION
  // =============================================
  
  /// Cache duration in days
  static const int cacheDuration = 7;
  
  /// Maximum number of items to keep in cache per product
  static const int maxCacheItemsPerProduct = 10;
  
  /// Maximum number of recent scans to keep locally
  static const int maxRecentScans = 100;
  
  /// Hive box names
  static const String hiveBoxProducts = 'products_cache';
  static const String hiveBoxPrices = 'prices_cache';
  static const String hiveBoxScans = 'scan_history_local';
  static const String hiveBoxSettings = 'app_settings';
  
  // =============================================
  // PAGINATION
  // =============================================
  
  /// Default number of items per page
  static const int pageSize = 20;
  
  /// Maximum number of items per page (for admin/special cases)
  static const int maxPageSize = 100;
  
  // =============================================
  // BARCODE VALIDATION
  // =============================================
  
  /// Minimum allowed barcode length
  static const int minBarcodeLength = 8;
  
  /// Maximum allowed barcode length
  static const int maxBarcodeLength = 14;
  
  /// Supported barcode formats
  static const List<String> supportedBarcodeFormats = [
    'EAN-13',
    'EAN-8',
    'UPC-A',
    'UPC-E',
    'CODE-128',
    'CODE-39',
    'QR Code',
  ];
  
  // =============================================
  // CURRENCY CONFIGURATION
  // =============================================
  
  /// Default currency code (DZD = Algerian Dinar)
  static const String defaultCurrency = 'DZD';
  
  /// Default currency symbol
  static const String defaultCurrencySymbol = 'DA';
  
  /// Number of decimal places for prices
  static const int priceDecimals = 0;
  
  /// Whether to show currency symbol before or after amount
  static const bool currencySymbolBefore = false;
  
  // =============================================
  // LOCATION CONFIGURATION
  // =============================================
  
  /// Default city for filtering stores
  static const String defaultCity = 'Alger';
  
  /// List of supported cities in Algeria
  static const List<String> supportedCities = [
    'Alger',
    'Oran',
    'Constantine',
    'Annaba',
    'Blida',
    'Tizi Ouzou',
    'Sétif',
    'Djelfa',
    'Béjaïa',
    'Tlemcen',
  ];
  
  /// Radius for nearby store search in kilometers
  static const int nearbyStoreRadiusKm = 10;
  
  // =============================================
  // PRICE ALERT CONFIGURATION
  // =============================================
  
  /// Minimum price drop percentage to trigger notification
  static const int minPriceDropPercent = 10;
  
  /// How often to check for price changes (in hours)
  static const int priceCheckIntervalHours = 24;
  
  // =============================================
  // UI CONFIGURATION
  // =============================================
  
  /// Default animation duration in milliseconds
  static const int defaultAnimationDuration = 300;
  
  /// Long animation duration in milliseconds
  static const int longAnimationDuration = 500;
  
  /// Border radius for cards
  static const double cardBorderRadius = 16.0;
  
  /// Border radius for buttons
  static const double buttonBorderRadius = 12.0;
  
  /// Default padding
  static const double defaultPadding = 16.0;
  
  /// Small padding
  static const double smallPadding = 8.0;
  
  /// Large padding
  static const double largePadding = 24.0;
  
  // =============================================
  // IMAGE CONFIGURATION
  // =============================================
  
  /// Maximum image size in bytes (5MB)
  static const int maxImageSizeBytes = 5 * 1024 * 1024;
  
  /// Supported image formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  
  /// Default product image URL placeholder
  static const String defaultProductImage = 'https://via.placeholder.com/200';
  
  // =============================================
  // FALLBACK MESSAGES
  // =============================================
  
  /// Message shown when product is not found
  static const String productNotFoundMessage = 'Product not found in database';
  
  /// Message shown when no price data is available
  static const String noPriceDataMessage = 'No price data available for this product';
  
  /// Message shown when network is unavailable
  static const String networkUnavailableMessage = 'No internet connection. Please check your network settings.';
  
  /// Message shown when server is down
  static const String serverErrorMessage = 'Server error. Please try again later.';
  
  // =============================================
  // DEEP LINKS & SHARING
  // =============================================
  
  /// Deep link scheme
  static const String deepLinkScheme = 'grocery-scanner';
  
  /// Deep link host
  static const String deepLinkHost = 'product';
  
  /// Share message template when sharing a product
  static const String shareMessageTemplate = 'Check out this product on Grocery Scanner: ';
  
  // =============================================
  // APP STORE / PLAY STORE LINKS (for updates/ratings)
  // =============================================
  
  /// Play Store link (Android)
  static const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.grocery.scanner';
  
  /// App Store link (iOS)
  static const String appStoreLink = 'https://apps.apple.com/app/idYOUR_APP_ID';
  
  // =============================================
  // FEATURE FLAGS
  // =============================================
  
  /// Enable batch scanning feature
  static const bool enableBatchScan = true;
  
  /// Enable price history charts
  static const bool enablePriceHistory = true;
  
  /// Enable push notifications
  static const bool enableNotifications = true;
  
  /// Enable analytics
  static const bool enableAnalytics = true;
  
  /// Enable crash reporting
  static const bool enableCrashReporting = true;
  
  // =============================================
  // ANALYTICS (if using Firebase or similar)
  // =============================================
  
  /// Analytics screen names
  static const String analyticsScreenScanner = 'scanner';
  static const String analyticsScreenProduct = 'product_detail';
  static const String analyticsScreenHistory = 'history';
  static const String analyticsScreenStores = 'stores';
  static const String analyticsScreenOnboarding = 'onboarding';
  
  /// Analytics events
  static const String analyticsEventScan = 'barcode_scan';
  static const String analyticsEventProductView = 'product_view';
  static const String analyticsEventPriceCompare = 'price_compare';
  static const String analyticsEventTrackProduct = 'track_product';
  
  // =============================================
  // ERROR CODES
  // =============================================
  
  static const int errorCodeNetwork = 1001;
  static const int errorCodeServer = 1002;
  static const int errorCodeNotFound = 1003;
  static const int errorCodeUnauthorized = 1004;
  static const int errorCodeInvalidBarcode = 1005;
  static const int errorCodeCache = 1006;
  static const int errorCodeDatabase = 1007;
  
  // =============================================
  // HELPER METHODS
  // =============================================
  
  /// Get formatted currency symbol with amount
  static String formatCurrency(double amount, {String? currency}) {
    final String symbol = currency == 'DZD' ? defaultCurrencySymbol : currency ?? defaultCurrencySymbol;
    if (currencySymbolBefore) {
      return '$symbol${amount.toStringAsFixed(priceDecimals)}';
    } else {
      return '${amount.toStringAsFixed(priceDecimals)} $symbol';
    }
  }
  
  /// Validate if a barcode is in correct format
  static bool isValidBarcode(String barcode) {
    if (barcode.isEmpty) return false;
    if (barcode.length < minBarcodeLength || barcode.length > maxBarcodeLength) return false;
    return RegExp(r'^[0-9]+$').hasMatch(barcode);
  }
  
  /// Get cache expiration duration
  static Duration get cacheExpiration => Duration(days: cacheDuration);
}