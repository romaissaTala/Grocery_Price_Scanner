import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_box.dart';

class ShimmerPriceList extends StatelessWidget {
  const ShimmerPriceList({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ShimmerBox(
            width: double.infinity,
            height: 70,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}