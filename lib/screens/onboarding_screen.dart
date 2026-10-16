import 'package:flutter/material.dart';

import '../components/companion_form.dart';
import '../components/controls.dart';
import '../components/quiet_text.dart';
import '../components/screen.dart';
import '../companion.dart';
import '../theme.dart';

class _Step {
  const _Step(this.line, this.note);
  final String line;
  final String note;
}

const List<_Step> _steps = [
  _Step(
    'A small companion is about to live on your phone.',
    'not a pet. not a game. only something present.',
  ),
  _Step(
    'It lives while you come back and stay a while.',
    'staying counts. passing through does not.',
  ),
  _Step(
    'Left alone, it fades — and it does not come back.',
    'there is no undo and no restart. only beginning again from the beginning.',
  ),
  _Step(
    'This is about presence, not performance.',
    'it will not keep score of you.',
  ),
];

/// 3 quiet slides + Begin — ported from `src/app/onboarding.tsx`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final CompanionController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  int get _total => _steps.length + 1;

  void _begin() {
    widget.controller.plant();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _advance() {
    if (_step < _total - 1) {
      setState(() => _step++);
    } else {
      _begin();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.state.onboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/');
      });
      return const Screen(child: SizedBox.expand());
    }

    final padding = useScreenPadding(context);
    final width = MediaQuery.sizeOf(context).width;
    final formSize = width * 0.52 < 210 ? width * 0.52 : 210.0;
    final isLast = _step == _total - 1;

    return Screen(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _advance,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: padding.top,
            bottom: padding.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _total; i++)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _step ? AppColors.inkFaint : AppColors.inkGhost,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: isLast
                      ? TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 2400),
                          curve: Curves.easeOutQuad,
                          builder: (context, value, _) => Opacity(
                            opacity: value,
                            child: CompanionForm(stage: 0, size: formSize, ambient: 0.7),
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeIn,
                          child: Column(
                            key: ValueKey(_step),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Serif(
                                _steps[_step].line,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 27,
                                  height: 42 / 27,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 320),
                                child: Tiny(
                                  _steps[_step].note,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 20 / 13,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: isLast
                      ? QuietPressable(
                          onPressed: _begin,
                          label: 'Begin',
                          style: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: AppSpacing.lg,
                          ),
                          child: const Label(
                            'BEGIN',
                            tone: Tone.gold,
                            style: TextStyle(fontSize: 13, letterSpacing: 4),
                          ),
                        )
                      : const Label('CONTINUE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
