import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_price_scanner/features/history/data/models/scan_history_model.dart';
import 'package:grocery_price_scanner/features/history/domain/entities/scan_history_entry.dart';
import 'package:grocery_price_scanner/features/history/presentation/bloc/history_bloc.dart';
import 'package:grocery_price_scanner/features/history/presentation/bloc/history_event.dart';
import 'package:grocery_price_scanner/features/product/presentation/bloc/product_event.dart';
import 'package:grocery_price_scanner/features/product/presentation/bloc/product_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/pages/product_result_page.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // ✅ FIX: create controller ONCE, never recreate it
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late AnimationController _slideController;
  bool _isResultSheetVisible = false;
  String? _lastScannedBarcode;

  // ✅ FIX: three-state permission model
  // null = not checked yet, true = granted, false = denied
  bool? _hasPermission;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: observe app lifecycle to restart camera when returning to foreground
    WidgetsBinding.instance.addObserver(this);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkPermissionAndStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ✅ FIX: restart/stop camera with app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    switch (state) {
      case AppLifecycleState.resumed:
        // App came back to foreground — re-check permission and restart
        _checkPermissionAndStart();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // App going to background — stop camera to release resource
        _scannerController.stop();
        break;
      default:
        break;
    }
  }

  Future<void> _checkPermissionAndStart() async {
    // ✅ FIX: check current status FIRST without requesting
    // This is the key — on re-entry we already have permission,
    // so we skip the dialog and just start the camera
    final status = await Permission.camera.status;

    if (status.isGranted) {
      if (mounted) setState(() => _hasPermission = true);
      // ✅ FIX: always try to start — safe to call even if already running
      try {
        await _scannerController.start();
      } catch (_) {
        // already started — ignore
      }
      return;
    }

    // Not granted yet — request permission (only shows dialog on first time
    // or when denied but not permanently)
    final requested = await Permission.camera.request();

    if (!mounted) return;

    if (requested.isGranted) {
      setState(() => _hasPermission = true);
      try {
        await _scannerController.start();
      } catch (_) {}
    } else if (requested.isPermanentlyDenied) {
      setState(() => _hasPermission = false);
      _showPermanentlyDeniedDialog();
    } else {
      setState(() => _hasPermission = false);
      _showDeniedDialog();
    }
  }

  void _showDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera permission required'),
        content: const Text(
            'Camera access is needed to scan barcodes. Please grant permission to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _checkPermissionAndStart();
            },
            child: const Text('Grant permission'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera permission required'),
        content: const Text(
            'Camera access is permanently denied. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isResultSheetVisible) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode == _lastScannedBarcode) return;
    _lastScannedBarcode = barcode;
    _showResultSheet(barcode);
  }

// scanner_page.dart — replace _showResultSheet and _ScanResultSheet
  void _showResultSheet(String barcode) {
    if (_isResultSheetVisible) return;
    setState(() => _isResultSheetVisible = true);

    _scannerController.stop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      // ✅ Add this to prevent rebuilding
      elevation: 0,
      enableDrag: true,
      isDismissible: true,
      builder: (sheetContext) => _ScanResultSheet(barcode: barcode),
    ).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _isResultSheetVisible = false;
        _lastScannedBarcode = null;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_isResultSheetVisible) {
          _scannerController.start();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // _hasPermission == null means still checking
    final isChecking = _hasPermission == null;
    final hasPermission = _hasPermission == true;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera / Permission state ──────────────────────
          if (isChecking)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (!hasPermission)
            _PermissionDeniedView(onRetry: _checkPermissionAndStart)
          else
            MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
            ),

          // ── Scan frame overlay ─────────────────────────────
          if (hasPermission)
            Positioned.fill(
              child: CustomPaint(painter: _ScannerOverlayPainter()),
            ),

          // ── Top bar ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.scanBarcode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasPermission)
                    _TorchButton(controller: _scannerController),
                ],
              ),
            ),
          ),

          // ── Bottom hint ────────────────────────────────────
          if (hasPermission)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    AppStrings.placeBarcode,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Extracted widgets — cleaner build method
// ──────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  size: 36, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera access needed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grant camera permission to scan product barcodes',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Grant permission'),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _TorchButton extends StatefulWidget {
  final MobileScannerController controller;
  const _TorchButton({required this.controller});

  @override
  State<_TorchButton> createState() => _TorchButtonState();
}

class _TorchButtonState extends State<_TorchButton> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller.toggleTorch();
        setState(() => _isOn = !_isOn);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isOn
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isOn ? Icons.flash_on : Icons.flash_off,
          size: 20,
          color: _isOn ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Scanner overlay — corners only, no fill square
// ──────────────────────────────────────────────
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dimmed background with cutout
    final dimPaint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final cutoutSize = size.width * 0.75;
    final cutout = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.44),
      width: cutoutSize,
      height: cutoutSize,
    );

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(12))),
    );
    canvas.drawPath(path, dimPaint);

    // Animated-style corner brackets
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cs = 28.0; // corner size
    final l = cutout.left;
    final t = cutout.top;
    final r = cutout.right;
    final b = cutout.bottom;

    // Top-left
    canvas.drawLine(Offset(l, t + cs), Offset(l, t + 8), cornerPaint);
    canvas.drawLine(Offset(l + 8, t), Offset(l + cs, t), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(r - cs, t), Offset(r - 8, t), cornerPaint);
    canvas.drawLine(Offset(r, t + 8), Offset(r, t + cs), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(l, b - cs), Offset(l, b - 8), cornerPaint);
    canvas.drawLine(Offset(l + 8, b), Offset(l + cs, b), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(r - cs, b), Offset(r - 8, b), cornerPaint);
    canvas.drawLine(Offset(r, b - cs), Offset(r, b - 8), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────
// Bottom sheet
// ──────────────────────────────────────────────
// In scanner_page.dart — pass scrollController into FoundView
class _ScanResultSheet extends StatelessWidget {
  final String barcode;
  const _ScanResultSheet({required this.barcode});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final handleColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.2);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.7, 0.95],
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Column(
              children: [
                // Drag handle — not scrollable
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: _ProductSheetContent(
                    barcode: barcode,
                    // ✅ Pass scrollController so FoundView can connect to it
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductSheetContent extends StatelessWidget {
  final String barcode;
  final ScrollController scrollController;

  const _ProductSheetContent({
    required this.barcode,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()..add(LoadProductByBarcode(barcode)),
      child: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          // ✅ Save to history when product is found
          if (state is ProductFound) {
            _saveToHistory(context, barcode, state.product);
          }
        },
        builder: (context, state) {
          print('Current state in sheet: $state'); // Debug print

          if (state is ProductLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Looking up product...',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is ProductNotFound) return _SheetNotFound();
          if (state is ProductError) {
            print('Error state: ${state.message}'); // Debug print
            return _SheetError(message: state.message);
          }
          if (state is ProductFound) {
            print(
                'Found state - product: ${state.product.name}'); // Debug print
            print('Prices count: ${state.prices.length}'); // Debug print
            return FoundView(
              state: state,
              scrollController: scrollController,
            );
          }
          // Show loading indicator for initial state
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
void _saveToHistory(BuildContext context, String barcode, product) {
  final userId = '68d8e4a0-983a-4bc6-8a17-caadd83682eb'; // Use a real UUID

  // ✅ Create ScanHistoryModel instead of ScanHistoryEntry
  final historyEntry = ScanHistoryModel(
    userId: userId,
    productId: product.id,
    barcode: barcode,
    productName: product.name,
    productImageUrl: product.imageUrl,
    scannedAt: DateTime.now(),
    isBatch: false,
    folderName: 'General',
    notes: null,
  );

  final historyBloc = sl<HistoryBloc>();
  historyBloc.add(AddHistoryEntryEvent(historyEntry));
}
}

class _SheetNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Product not found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          Text('This barcode is not in our database yet.',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SheetError extends StatelessWidget {
  final String message;
  const _SheetError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
