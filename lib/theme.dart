import 'dart:ui';

/// Design tokens, ported from the original `src/theme/index.ts`.
class AppColors {
  const AppColors._();

  /// deep charcoal-black → deep navy, almost void
  static const voidTop = Color(0xFF0B0D12);
  static const voidBottom = Color(0xFF12151C);

  /// warm off-white, never pure white
  static const ink = Color(0xFFF0EDE6);
  static const inkDim = Color(0x99F0EDE6); // rgba(240, 237, 230, 0.60)
  static const inkFaint = Color(0x5CF0EDE6); // rgba(240, 237, 230, 0.36)
  static const inkGhost = Color(0x29F0EDE6); // rgba(240, 237, 230, 0.16)
  static const hairline = Color(0x1AF0EDE6); // rgba(240, 237, 230, 0.10)

  static const gold = Color(0xFFE8C888);
  static const amber = Color(0xFFD9A86A);
  static const teal = Color(0xFF8FA3B0);
  static const lavender = Color(0xFFA594C4);
}

class AppFonts {
  const AppFonts._();

  static const serif = 'Fraunces';
  static const sans = 'SourceSans3';
}

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const huge = 72.0;
}

class StageVisual {
  const StageVisual({
    required this.stage,
    required this.name,
    required this.tint,
    required this.core,
    required this.opacity,
    required this.scale,
    required this.breath,
    required this.breathAmplitude,
    required this.cracks,
    required this.flicker,
  });

  final int stage;
  final String name;

  /// colour the glow is tinted toward
  final Color tint;

  /// colour of the bright centre
  final Color core;
  final double opacity;
  final double scale;

  /// seconds for one full breath
  final double breath;

  /// how much the form swells with each breath
  final double breathAmplitude;

  /// opacity of the fracture overlay
  final double cracks;
  final bool flicker;
}

final List<StageVisual> stageVisuals = [
  StageVisual(
    stage: 0,
    name: 'Vibrant',
    tint: AppColors.gold,
    core: const Color(0xFFFFF7E8),
    opacity: 1,
    scale: 1,
    breath: 5.5,
    breathAmplitude: 0.05,
    cracks: 0,
    flicker: false,
  ),
  StageVisual(
    stage: 1,
    name: 'Dimming',
    tint: const Color(0xFFD8C1A2),
    core: const Color(0xFFF6E9D8),
    opacity: 0.88,
    scale: 0.97,
    breath: 6.5,
    breathAmplitude: 0.038,
    cracks: 0,
    flicker: false,
  ),
  StageVisual(
    stage: 2,
    name: 'Fading',
    tint: const Color(0xFFB3B9B6),
    core: const Color(0xFFE8E9E6),
    opacity: 0.7,
    scale: 0.93,
    breath: 7.5,
    breathAmplitude: 0.028,
    cracks: 0.12,
    flicker: false,
  ),
  StageVisual(
    stage: 3,
    name: 'Cracking',
    tint: AppColors.teal,
    core: const Color(0xFFD5DEE4),
    opacity: 0.55,
    scale: 0.88,
    breath: 8.5,
    breathAmplitude: 0.02,
    cracks: 0.6,
    flicker: false,
  ),
  StageVisual(
    stage: 4,
    name: 'Barely Holding On',
    tint: AppColors.lavender,
    core: const Color(0xFFDCD4EA),
    opacity: 0.34,
    scale: 0.8,
    breath: 10,
    breathAmplitude: 0.014,
    cracks: 0.3,
    flicker: true,
  ),
  StageVisual(
    stage: 5,
    name: 'Passing',
    tint: const Color(0xFF7A7488),
    core: const Color(0xFFB8B2C4),
    opacity: 0.12,
    scale: 0.72,
    breath: 12,
    breathAmplitude: 0.01,
    cracks: 0.18,
    flicker: true,
  ),
];

StageVisual stageVisual(int stage) {
  return stageVisuals[stage.clamp(0, stageVisuals.length - 1)];
}

/// Seasons of Light — extremely subtle time-of-day tint on background glow.
Color seasonTint(DateTime now) {
  final hour = now.hour;
  // Warm amber around sunset (17-20), cool lavender at late night (0-4), neutral else
  if (hour >= 17 && hour <= 20) return const Color(0x0FE8C888); // 0.06
  if (hour >= 0 && hour <= 4) return const Color(0x0DA594C4); // 0.05
  return const Color(0x08F0EDE6); // 0.03
}
