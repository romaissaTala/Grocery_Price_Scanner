import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavShell extends StatelessWidget {
  final Widget child;
  const AppBottomNavShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/scanner')) return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/stores')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _NotchNavBar(
        selectedIndex: _selectedIndex(context),
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/scanner');
              break;
            case 1:
              context.go('/history');
              break;
            case 2:
              context.go('/stores');
              break;
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// The floating notch bar
// ─────────────────────────────────────────────
class _NotchNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _NotchNavBar({required this.selectedIndex, required this.onTap});

  @override
  State<_NotchNavBar> createState() => _NotchNavBarState();
}

class _NotchNavBarState extends State<_NotchNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bubblePos; // 0.0 → 1.0 across 3 items
  late int _prevIndex;

  static const _items = [
    _NavItem(Icons.qr_code_scanner_outlined, Icons.qr_code_scanner, 'Scan'),
    _NavItem(Icons.history_outlined, Icons.history, 'History'),
    _NavItem(Icons.storefront_outlined, Icons.storefront, 'Stores'),
  ];

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bubblePos = Tween<double>(
      begin: widget.selectedIndex.toDouble(),
      end: widget.selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(_NotchNavBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _bubblePos = Tween<double>(
        begin: _prevIndex.toDouble(),
        end: widget.selectedIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ));
      _prevIndex = widget.selectedIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    // Bar colors — dark pill on light bg, slightly lighter surface on dark bg
    final barColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFF1A1A2E);
    final bubbleColor = colorScheme.primary; // your green

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: SizedBox(
          height: 72,
          child: AnimatedBuilder(
            animation: _bubblePos,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final barWidth = constraints.maxWidth;
                  final itemWidth = barWidth / _items.length;
                  final bubbleX = _bubblePos.value * itemWidth + itemWidth / 2;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Bar with notch ──────────────────────────
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 58,
                        child: CustomPaint(
                          painter: _NotchPainter(
                            notchCenterX: bubbleX,
                            notchRadius: 26,
                            barColor: barColor,
                            borderRadius: 29,
                          ),
                        ),
                      ),

                      // ── Nav items ───────────────────────────────
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 58,
                        child: Row(
                          children: List.generate(_items.length, (i) {
                            final isSelected = i == widget.selectedIndex;
                            // hide icon under the bubble
                            final isBubbleSlot =
                                (_bubblePos.value - i).abs() < 0.5;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => widget.onTap(i),
                                behavior: HitTestBehavior.opaque,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isBubbleSlot ? 0.0 : 1.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _items[i].icon,
                                        size: 22,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // ── Floating bubble ─────────────────────────
                      Positioned(
                        bottom: 30,
                        left: bubbleX - 26,
                        child: GestureDetector(
                          onTap: () => widget.onTap(widget.selectedIndex),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: bubbleColor.withOpacity(0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _items[widget.selectedIndex].activeIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CustomPainter — draws bar with a circular notch
// ─────────────────────────────────────────────
class _NotchPainter extends CustomPainter {
  final double notchCenterX;
  final double notchRadius;
  final Color barColor;
  final double borderRadius;

  const _NotchPainter({
    required this.notchCenterX,
    required this.notchRadius,
    required this.barColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = barColor;
    final r = borderRadius;
    final nr = notchRadius + 4; // notch slightly larger than bubble
    final cx = notchCenterX;
    const top = 0.0;
    final bottom = size.height;
    final right = size.width;

    final path = Path();

    // Start at top-left arc
    path.moveTo(r, top);

    // Top edge left of notch
    final notchLeft = cx - nr;
    final notchRight = cx + nr;

    path.lineTo(notchLeft - 4, top);

    // Notch arc (cut into top of bar)
    path.arcToPoint(
      Offset(notchRight + 4, top),
      radius: Radius.circular(nr),
      clockwise: false,
    );

    // Top edge right of notch → top-right arc
    path.lineTo(right - r, top);
    path.arcToPoint(Offset(right, r), radius: Radius.circular(r));

    // Right edge
    path.lineTo(right, bottom - r);
    path.arcToPoint(Offset(right - r, bottom), radius: Radius.circular(r));

    // Bottom edge
    path.lineTo(r, bottom);
    path.arcToPoint(Offset(0, bottom - r), radius: Radius.circular(r));

    // Left edge
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, top), radius: Radius.circular(r));

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NotchPainter old) =>
      old.notchCenterX != notchCenterX || old.barColor != barColor;
}

// ─────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
