import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// The living companion form — ported from `src/components/companion-form.tsx`.
///
/// Layered glow artwork, tinted per decay stage, breathing on a stage-tuned
/// rhythm, with seven drifting lights around it.
class CompanionForm extends StatefulWidget {
  const CompanionForm({
    super.key,
    required this.stage,
    required this.size,
    this.ambient = 1,
  });

  final int stage;

  /// overall width of the form, in points
  final double size;

  /// scale of the drifting lights around it
  final double ambient;

  @override
  State<CompanionForm> createState() => _CompanionFormState();
}

class _CompanionFormState extends State<CompanionForm>
    with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  late final AnimationController _flicker = AnimationController(
    vsync: this,
    value: 1,
    duration: const Duration(milliseconds: 1000),
  );
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 34),
  );

  StageVisual get _visual => stageVisual(widget.stage);

  @override
  void initState() {
    super.initState();
    _syncAnimations();
  }

  @override
  void didUpdateWidget(CompanionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage != widget.stage) _syncAnimations();
  }

  void _syncAnimations() {
    final visual = _visual;
    _breath.duration = Duration(milliseconds: (visual.breath * 1000).round());
    _breath.repeat(reverse: true);

    if (visual.flicker) {
      _flicker.repeat();
    } else {
      _flicker.animateTo(1, duration: const Duration(milliseconds: 500));
    }

    if (!_drift.isAnimating) _drift.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    _flicker.dispose();
    _drift.dispose();
    super.dispose();
  }

  double _flickerValue() {
    if (!_visual.flicker) return 1;
    // Irregular dip-and-recover, mirroring the Reanimated sequence:
    // hold → dip to 0.3 → recover → dip to 0.55 → recover.
    final t = _flicker.value;
    if (t < 0.40) return 1;
    if (t < 0.43) return 1 - ((t - 0.40) / 0.03) * 0.7; // dip to 0.3
    if (t < 0.49) return 0.3 + ((t - 0.43) / 0.06) * 0.7; // recover
    if (t < 0.76) return 1;
    if (t < 0.79) return 1 - ((t - 0.76) / 0.03) * 0.45; // dip to 0.55
    return 0.55 + ((t - 0.79) / 0.21) * 0.45; // recover
  }

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    final size = widget.size;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var index = 0; index < 7; index++)
              _DriftingLight(
                index: index,
                bounds: size / 2,
                alpha: math.min(1, visual.opacity * 1.1) * widget.ambient,
              ),
            AnimatedBuilder(
              animation: Listenable.merge([_breath, _flicker, _drift]),
              builder: (context, _) {
                final breath = Curves.easeInOutSine.transform(_breath.value);
                final flicker = _flickerValue();
                final drift = Curves.easeInOut.transform(_drift.value);
                final opacity = visual.opacity * (0.86 + 0.14 * breath) * flicker;
                return Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -5 + drift * 10),
                    child: Transform.rotate(
                      angle: (drift * 7 - 3.5) * math.pi / 180,
                      child: Transform.scale(
                        scale: 1 + visual.breathAmplitude * breath,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _TintedAsset(
                              asset: 'assets/images/glow-bloom.png',
                              tint: visual.tint,
                              opacity: 0.55,
                            ),
                            _TintedAsset(
                              asset: 'assets/images/glow-body.png',
                              tint: visual.tint,
                              opacity: 0.95,
                            ),
                            // bright centre, inset 31% and 38% of the form
                            FractionallySizedBox(
                              widthFactor: 0.38,
                              heightFactor: 0.38,
                              alignment: const Alignment(-0.38, -0.38),
                              child: _TintedAsset(
                                asset: 'assets/images/glow-core.png',
                                tint: visual.core,
                                opacity: 0.9,
                              ),
                            ),
                            if (visual.cracks > 0)
                              _TintedAsset(
                                asset: 'assets/images/cracks.png',
                                tint: AppColors.voidTop,
                                opacity: visual.cracks,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TintedAsset extends StatelessWidget {
  const _TintedAsset({
    required this.asset,
    required this.tint,
    required this.opacity,
  });

  final String asset;
  final Color tint;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        color: tint,
        colorBlendMode: BlendMode.srcIn,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _DriftingLight extends StatefulWidget {
  const _DriftingLight({
    required this.index,
    required this.bounds,
    required this.alpha,
  });

  final int index;
  final double bounds;
  final double alpha;

  @override
  State<_DriftingLight> createState() => _DriftingLightState();
}

class _DriftingLightState extends State<_DriftingLight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final _LightSeed _seed;

  @override
  void initState() {
    super.initState();
    final angle = widget.index * 2.399963;
    final radius = 0.3 + (((widget.index * 53) % 97) / 97) * 0.22;
    _seed = _LightSeed(
      x: math.cos(angle) * radius * widget.bounds,
      y: math.sin(angle) * radius * widget.bounds * 0.92,
      diameter: (2 + (widget.index % 3)).toDouble(),
      delay: Duration(milliseconds: widget.index * 1400),
      duration: Duration(milliseconds: 9000 + widget.index * 1300),
    );
    _controller = AnimationController(
      vsync: this,
      duration: _seed.duration,
    );
    Future<void>.delayed(_seed.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final opacity = Curves.easeInOutSine.transform(_controller.value);
          return Align(
            alignment: Alignment.center,
            child: Transform.translate(
              // Base position: x/y from centre; drift: -16 → +16
              offset: Offset(_seed.x, _seed.y - 16 + opacity * 32),
              child: Opacity(
                opacity: opacity * widget.alpha * 0.7,
                child: Container(
                  width: _seed.diameter,
                  height: _seed.diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LightSeed {
  const _LightSeed({
    required this.x,
    required this.y,
    required this.diameter,
    required this.delay,
    required this.duration,
  });

  final double x;
  final double y;
  final double diameter;
  final Duration delay;
  final Duration duration;
}
