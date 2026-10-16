import 'package:flutter/material.dart';

import '../theme.dart';

/// Void background with vertical gradient — ported from `src/components/screen.dart`.
class Screen extends StatelessWidget {
  const Screen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.voidTop,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.voidTop, AppColors.voidBottom],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Vertical padding that respects the notch without drawing attention to it.
class ScreenPadding {
  const ScreenPadding({required this.top, required this.bottom});
  final double top;
  final double bottom;
}

ScreenPadding useScreenPadding(BuildContext context) {
  final padding = MediaQuery.paddingOf(context);
  return ScreenPadding(
    top: padding.top < 20 ? 20 : padding.top,
    bottom: padding.bottom < 20 ? 20 : padding.bottom,
  );
}
