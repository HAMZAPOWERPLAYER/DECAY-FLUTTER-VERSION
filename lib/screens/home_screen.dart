import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/companion_form.dart';
import '../components/controls.dart';
import '../components/quiet_text.dart';
import '../components/screen.dart';
import '../companion.dart';
import '../presence.dart';
import '../theme.dart';

/// Transition design spec — ported from `src/components/transition-spec.ts`.
const int decayTransitionMs = 2500; // stage change
const int deathRevealMs = 3500; // final visit → certificate (quietest moment)

/// Entry / routing hub — ported from `src/app/index.tsx`.
///
/// Routes to onboarding → home → certificate based on state.
class HomeRouter extends StatefulWidget {
  const HomeRouter({super.key, required this.controller});

  final CompanionController controller;

  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> with WidgetsBindingObserver {
  bool _passingReveal = false;
  bool _passingStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onState);
    _onState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onState);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onState();
  }

  void _onState() {
    if (!mounted) return;
    final controller = widget.controller;
    final decay = controller.decay;
    if (decay.dead &&
        controller.state.plantedAt != null &&
        controller.state.passedAt == null &&
        !_passingStarted) {
      _passingStarted = true;
      HapticFeedback.lightImpact();
      setState(() => _passingReveal = true);
      Timer(const Duration(milliseconds: deathRevealMs), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/certificate');
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (!controller.ready) return const Screen(child: SizedBox.expand());
    final state = controller.state;
    final decay = controller.decay;
    final needsOnboarding = !state.onboarded;
    final isDead = state.plantedAt != null && decay.dead;

    if (needsOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
      });
      return const Screen(child: SizedBox.expand());
    }
    if (_passingReveal) return const PassingReveal();
    if (isDead && state.passedAt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/certificate');
      });
      return const Screen(child: SizedBox.expand());
    }
    return _CompanionHome(controller: controller);
  }
}

class _CompanionHome extends StatefulWidget {
  const _CompanionHome({required this.controller});

  final CompanionController controller;

  @override
  State<_CompanionHome> createState() => _CompanionHomeState();
}

class _CompanionHomeState extends State<_CompanionHome>
    with WidgetsBindingObserver {
  late final PresenceTracker _presence = PresenceTracker(widget.controller);
  bool _stayed = false;
  Timer? _whisperTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _presence.addListener(_onPresence);
    widget.controller.addListener(_onCompanion);
    _setActive(true);
    widget.controller.updateAudio(active: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presence.removeListener(_onPresence);
    widget.controller.removeListener(_onCompanion);
    _whisperTimer?.cancel();
    _presence.dispose();
    widget.controller.updateAudio(active: false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    _setActive(resumed);
    widget.controller.updateAudio(active: resumed);
  }

  void _setActive(bool active) => _presence.setActive(active);

  void _onCompanion() {
    if (mounted) setState(() {});
  }

  void _onPresence() {
    if (!_presence.stayed) {
      _whisperTimer?.cancel();
      setState(() => _stayed = false);
      return;
    }
    setState(() => _stayed = true);
    _whisperTimer?.cancel();
    _whisperTimer = Timer(const Duration(milliseconds: 4400), () {
      if (mounted) setState(() => _stayed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = useScreenPadding(context);
    final width = MediaQuery.sizeOf(context).width;
    final formSize = width * 0.56 < 240 ? width * 0.56 : 240.0;

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: padding.top,
          bottom: padding.bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CompanionForm(stage: widget.controller.decay.stage, size: formSize),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    height: 20,
                    child: AnimatedOpacity(
                      opacity: _stayed ? 1 : 0,
                      duration: Duration(
                        milliseconds: _stayed ? 1400 : 1800,
                      ),
                      curve: Curves.easeIn,
                      child: const Label(
                        'you stayed.',
                        style: TextStyle(fontSize: 12, letterSpacing: 1.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: QuietPressable(
                onPressed: () => Navigator.of(context).pushNamed('/settings'),
                label: 'Settings',
                style: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                child: Opacity(
                  opacity: 0.7,
                  child: Tiny('settings'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// The slowest moment — 3.5s, no swipe, no button.
class PassingReveal extends StatefulWidget {
  const PassingReveal({super.key});

  @override
  State<PassingReveal> createState() => _PassingRevealState();
}

class _PassingRevealState extends State<PassingReveal> {
  bool _showLine = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1900), () {
      if (mounted) setState(() => _showLine = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final formSize = width * 0.56 < 240 ? width * 0.56 : 240.0;

    return Screen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1, end: 0.08),
            duration: const Duration(milliseconds: 2220),
            curve: Curves.easeInOut,
            builder: (context, value, _) => Opacity(
              opacity: value,
              child: CompanionForm(stage: 5, size: formSize),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 20,
            child: AnimatedOpacity(
              opacity: _showLine ? 1 : 0,
              duration: const Duration(milliseconds: 1500),
              child: const Label(
                'passed quietly',
                style: TextStyle(fontSize: 12, letterSpacing: 2.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
