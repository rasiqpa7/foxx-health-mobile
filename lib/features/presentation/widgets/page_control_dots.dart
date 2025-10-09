import 'package:flutter/material.dart';

class PageControlDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double dotSize;
  final double spacing;
  final Color activeColor;
  final Color inactiveColor;
  final double inactiveOpacity;

  const PageControlDots({
    super.key,
    required this.count,
    required this.activeIndex,
    this.dotSize = 8,
    this.spacing = 8,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.black,
    this.inactiveOpacity = 0.30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 16,
      child: Stack(
        children: [
          // Center the indicator bar
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(count * 2 - 1, (i) {
                    if (i.isOdd) {
                      return SizedBox(width: spacing);
                    }
                    final index = i ~/ 2;
                    final isActive = index == activeIndex;
                    final color = isActive ? activeColor : inactiveColor;
                    final opacity = isActive ? 1.0 : inactiveOpacity;
                    return Opacity(
                      opacity: opacity,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: ShapeDecoration(
                          color: color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}