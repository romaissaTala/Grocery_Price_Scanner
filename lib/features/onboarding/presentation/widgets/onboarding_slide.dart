import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              // ✅ FIX: primaryContainer adapts to light/dark automatically
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              // ✅ FIX: onPrimaryContainer is always readable on primaryContainer
              color: colorScheme.onPrimaryContainer,
              size: 52,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              // ✅ FIX: onSurface = black in light, white in dark — automatic
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              // ✅ FIX: onSurface with opacity = muted text, works in both themes
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
