import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class FlipCard extends StatefulWidget {
  final NutritionInfo nutrition;

  const FlipCard({super.key, required this.nutrition});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    _isFront ? _controller.forward() : _controller.reverse();
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          final showFront = _animation.value <= pi / 2;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: showFront
                ? _FrontFace(nutrition: widget.nutrition)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _BackFace(nutrition: widget.nutrition),
                  ),
          );
        },
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  final NutritionInfo nutrition;

  const _FrontFace({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasData = nutrition.caloriesPer100g != null ||
        nutrition.carbsG != null ||
        nutrition.proteinG != null;

    if (!hasData) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.08), width: 0.5),
        ),
        child: Center(
          child: Text(
            'No nutrition information available',
            style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      height: 140,
      decoration: BoxDecoration(
        // ✅ Uses theme surface — white in light, gray-800 in dark
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.onSurface.withOpacity(0.08), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.set_meal,
                  color: colorScheme.onPrimaryContainer, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nutrition Facts',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (nutrition.caloriesPer100g != null)
                    Text(
                      '${nutrition.caloriesPer100g!.toStringAsFixed(0)} kcal / 100g',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to see details →',
                    style: TextStyle(
                        color: colorScheme.primary.withOpacity(0.7),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  final NutritionInfo nutrition;

  const _BackFace({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = <_NutritionRow>[
      if (nutrition.caloriesPer100g != null)
        _NutritionRow(
            'Calories', '${nutrition.caloriesPer100g!.toStringAsFixed(0)} kcal'),
      if (nutrition.carbsG != null)
        _NutritionRow('Carbs', '${nutrition.carbsG!.toStringAsFixed(1)} g'),
      if (nutrition.proteinG != null)
        _NutritionRow('Protein', '${nutrition.proteinG!.toStringAsFixed(1)} g'),
      if (nutrition.fatG != null)
        _NutritionRow('Fat', '${nutrition.fatG!.toStringAsFixed(1)} g'),
      if (nutrition.fiberG != null)
        _NutritionRow('Fiber', '${nutrition.fiberG!.toStringAsFixed(1)} g'),
      if (nutrition.sugarG != null)
        _NutritionRow('Sugar', '${nutrition.sugarG!.toStringAsFixed(1)} g'),
      if (nutrition.sodiumMg != null)
        _NutritionRow('Sodium', '${nutrition.sodiumMg!.toStringAsFixed(0)} mg'),
    ];

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.primary.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'Per 100g',
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.45), fontSize: 11),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colorScheme.onSurface.withOpacity(0.08)),
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        items[i].label,
                        style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12),
                      ),
                      Text(
                        items[i].value,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow {
  final String label;
  final String value;
  _NutritionRow(this.label, this.value);
}