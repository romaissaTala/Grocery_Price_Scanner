import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive FIRST
  await Hive.initFlutter();
  
  // Register adapters BEFORE opening boxes
  // You need to implement these adapters properly
  // Hive.registerAdapter(ProductModelAdapter());
  // Hive.registerAdapter(PriceModelAdapter());
  
  // Now open boxes with proper types
  await Hive.openBox<dynamic>('products_cache');
  await Hive.openBox<dynamic>('prices_cache');
  await Hive.openBox<dynamic>('scan_history_local');

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Dependency Injection
  await setupDependencies();

  runApp(const GroceryPriceScannerApp());
}