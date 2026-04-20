import 'package:get_it/get_it.dart';
import 'package:grocery_price_scanner/features/history/domain/usecases/add_history_entry.dart';
import 'package:grocery_price_scanner/features/product/domain/usecases/get_price_history.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import '../network/network_info.dart';

// Features - Product
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/datasources/product_local_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product_by_barcode.dart';
import '../../features/product/domain/usecases/get_prices_for_product.dart';
import '../../features/product/domain/usecases/get_product_with_prices.dart';
import '../../features/product/domain/usecases/track_product.dart';
import '../../features/product/domain/usecases/untrack_product.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';

// Features - History
import '../../features/history/data/datasources/history_remote_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_history.dart';
import '../../features/history/domain/usecases/search_history.dart';
import '../../features/history/domain/usecases/delete_history_entry.dart';
import '../../features/history/domain/usecases/clear_history.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

// Features - Scanner
import '../../features/scanner/data/datasources/scanner_local_datasource.dart';
import '../../features/scanner/data/repositories/scanner_repository_impl.dart';
import '../../features/scanner/domain/repositories/scanner_repository.dart';
import '../../features/scanner/domain/usecases/save_scan_to_history.dart';
import '../../features/scanner/domain/usecases/get_scan_history.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';

// Features - Stores
import '../../features/stores/data/datasources/store_remote_datasource.dart';
import '../../features/stores/data/repositories/store_repository_impl.dart';
import '../../features/stores/domain/repositories/store_repository.dart';
import '../../features/stores/domain/usecases/get_stores.dart';
import '../../features/stores/domain/usecases/update_price.dart';
import '../../features/stores/presentation/bloc/store_bloc.dart';

// Features - Onboarding
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Features - Splash
import '../../features/splash/presentation/bloc/splash_bloc.dart';

// Router
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ────────────────────────────────────────────────────────────
  // EXTERNAL / THIRD-PARTY
  // ────────────────────────────────────────────────────────────

  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl<Connectivity>()));

  // Hive Boxes
  final productsCacheBox = await Hive.openBox('products_cache');
  sl.registerLazySingleton<Box>(() => productsCacheBox,
      instanceName: 'products_cache');

  final pricesCacheBox = await Hive.openBox('prices_cache');
  sl.registerLazySingleton<Box>(() => pricesCacheBox,
      instanceName: 'prices_cache');

  final scanHistoryBox = await Hive.openBox('scan_history_local');
  sl.registerLazySingleton<Box>(() => scanHistoryBox,
      instanceName: 'scan_history_local');

  // ────────────────────────────────────────────────────────────
  // DATA SOURCES
  // ────────────────────────────────────────────────────────────

  // Product
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSource(),
  );

  // History
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSource(sl<SupabaseClient>()),
  );

  // Scanner
  sl.registerLazySingleton<ScannerLocalDataSource>(
    () => ScannerLocalDataSource(),
  );

  // Stores
  sl.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSource(sl<SupabaseClient>()),
  );

  // ────────────────────────────────────────────────────────────
  // REPOSITORIES
  // ────────────────────────────────────────────────────────────

  // Product
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
      localDataSource: sl<ProductLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // History
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      remoteDataSource: sl<HistoryRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Scanner
  sl.registerLazySingleton<ScannerRepository>(
    () => ScannerRepositoryImpl(
      localDataSource: sl<ScannerLocalDataSource>(),
    ),
  );

  // Stores
  sl.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
      remoteDataSource: sl<StoreRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ────────────────────────────────────────────────────────────
  // USE CASES - Product
  // ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetProductByBarcode(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPricesForProduct(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => GetProductWithPrices(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => TrackProduct(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => UntrackProduct(sl<ProductRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPriceHistory(sl<ProductRepository>()), // ✅ Add this
  );
  // ────────────────────────────────────────────────────────────
  // USE CASES - History
  // ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetHistory(sl<HistoryRepository>()),
  );
  sl.registerLazySingleton(
    () => SearchHistory(sl<HistoryRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteHistoryEntry(sl<HistoryRepository>()),
  );
  sl.registerLazySingleton(
    () => ClearHistory(sl<HistoryRepository>()),
  );
// Add this with other history use cases
sl.registerLazySingleton(
  () => AddHistoryEntry(sl<HistoryRepository>()),
);
  // ────────────────────────────────────────────────────────────
  // USE CASES - Scanner
  // ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => SaveScanToHistory(sl<ScannerRepository>()),
  );
  sl.registerLazySingleton(
    () => GetScanHistory(sl<ScannerRepository>()),
  );

  // ────────────────────────────────────────────────────────────
  // USE CASES - Stores
  // ────────────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetStores(sl<StoreRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdatePrice(sl<StoreRepository>()),
  );

  // ────────────────────────────────────────────────────────────
  // BLoCs - Factory (new instance each time)
  // ────────────────────────────────────────────────────────────
  sl.registerFactory(
    () => ProductBloc(
      getProductWithPrices: sl<GetProductWithPrices>(),
      trackProduct: sl<TrackProduct>(),
      untrackProduct: sl<UntrackProduct>(),
      getPriceHistory: sl<GetPriceHistory>(),
    ),
  );

  sl.registerFactory(
    () => HistoryBloc(
      getHistory: sl<GetHistory>(),
      searchHistory: sl<SearchHistory>(),
      deleteHistoryEntry: sl<DeleteHistoryEntry>(),
      clearHistory: sl<ClearHistory>(),
      addHistoryEntry: sl<AddHistoryEntry>(),
    ),
  );

  sl.registerFactory(
    () => ScannerBloc(
      saveScanToHistory: sl<SaveScanToHistory>(),
    ),
  );

  sl.registerFactory(
    () => StoreBloc(
      getStores: sl<GetStores>(),
    ),
  );

  // BLoCs - Singleton (one instance for app lifetime)
  sl.registerLazySingleton(() => OnboardingBloc());
  sl.registerLazySingleton(() => SplashBloc());

  // Router - Singleton
  sl.registerLazySingleton(() => AppRouter());
}
