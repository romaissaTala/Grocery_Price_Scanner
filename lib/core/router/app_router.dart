import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/product/presentation/pages/product_result_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/stores/presentation/pages/stores_page.dart';
import '../widgets/app_bottom_nav.dart';


class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppBottomNavShell(child: child),
        routes: [
          GoRoute(
            path: '/scanner',
            name: 'scanner',
            builder: (context, state) => const ScannerPage(),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: '/stores',
            name: 'stores',
            builder: (context, state) => const StoresPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/product/:barcode',
        name: 'product',
        builder: (context, state) {
          final barcode = state.pathParameters['barcode']!;
          return ProductResultPage(barcode: barcode);
        },
      ),
    ],
  );
}