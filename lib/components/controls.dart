import 'package:flutter/material.dart';

import '../theme.dart';
import 'quiet_text.dart';

/// Everything is a link, not a button — pressed state is just a dimming.
/// Ported from `src/components/controls.dart`.
class QuietPressable extends StatefulWidget {
  const QuietPressable({
    super.key,
    required this.child,
    required this.onPressed,
    this.label,
    this.style,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? label;
  final EdgeInsetsGeometry? style;

  @override
  State<QuietPressable> createState() => _QuietPressableState();
}

class _QuietPressableState extends State<QuietPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: Padding(
          padding: widget.style ?? EdgeInsets.zero,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.45 : 1,
            duration: Duration(milliseconds: _pressed ? 120 : 320),
            curve: Curves.easeOutQuad,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class QuietDivider extends StatelessWidget {
  const QuietDivider({super.key, this.insetLeft = AppSpacing.lg});

  final double insetLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: insetLeft),
      child: const DividerLine(),
    );
  }
}

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: AppColors.hairline,
      width: double.infinity,
    );
  }
}

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.note,
    this.onPressed,
    this.first = false,
  });

  final String title;
  final String? note;
  final VoidCallback? onPressed;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!first) const QuietDivider(),
        QuietPressable(
          onPressed: onPressed,
          label: title,
          style: const EdgeInsets.symmetric(vertical: 18, horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Body(title, tone: Tone.ink, style: const TextStyle(fontSize: 16, height: 24 / 16)),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Tiny(note!, style: const TextStyle(fontSize: 12, height: 17 / 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuietToggle extends StatefulWidget {
  const QuietToggle({
    super.key,
    required this.value,
    required this.onChange,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChange;
  final String label;

  @override
  State<QuietToggle> createState() => _QuietToggleState();
}

class _QuietToggleState extends State<QuietToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: widget.value ? 1 : 0,
  );

  @override
  void didUpdateWidget(QuietToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.animateTo(
        widget.value ? 1 : 0,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const offTrack = Color(0x14F0EDE6); // rgba(240, 237, 230, 0.08)
    const offBorder = Color(0x29F0EDE6); // 0.16
    const onTrack = Color(0x4DE8C888); // 0.30
    const onBorder = Color(0x8CE8C888); // 0.55
    const offKnob = Color(0x8CF0EDE6); // 0.55

    return Semantics(
      toggled: widget.value,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChange(!widget.value),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Body(
                  widget.label,
                  tone: Tone.ink,
                  style: const TextStyle(fontSize: 16, height: 24 / 16),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  return Container(
                    width: 44,
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      color: Color.lerp(offTrack, onTrack, t),
                      border: Border.all(
                        color: Color.lerp(offBorder, onBorder, t)!,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(1 + t * 20, 0),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(offKnob, AppColors.gold, t),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
